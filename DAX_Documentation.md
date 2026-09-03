PAGE 1 => => => Stoke_Aging 
### 1.Ending Inventory Value
```dax 
Ending Inventory Value =
VAR MaxDate = MAX(Date_Table[Date])
RETURN
SUMX(
    VALUES(Inventory_FIFO[ProductKey]),
    VAR LastDatee = CALCULATE(MAX(Inventory_FIFO[MovementDate]), Date_Table[Date] <= MaxDate, Inventory_FIFO[UnitsBalance] > 0)
    RETURN CALCULATE(SUM(Inventory_FIFO[Total _Cost Inventore]), Inventory_FIFO[MovementDate] = LastDatee, REMOVEFILTERS(Date_Table))
)
```
### 1.2 Total_Unite_Inventore 
```dax 
Total_Unite_Inventore = var maxdate = MAX(Date_Table[Date])
RETURN SUMX(VALUES(Inventory_FIFO[ProductKey]),var last_date = CALCULATE(MAX(Inventory_FIFO[MovementDate]),Date_Table[Date] <= maxdate ,
 Inventory_FIFO[UnitsBalance] >0 )
 RETURN
 CALCULATE(SUM(Inventory_FIFO[UnitsBalance]),Inventory_FIFO[MovementDate] = last_date , REMOVEFILTERS(Date_Table)))
 ```

### 1.3 Dead Stock Units 
```dax
Dead Stock Units = 
CALCULATE([Total_Unite_Inventore], Inventory_FIFO[FIFO_Stock_Aging_Category] = "Over 2 Years (Dead Stock)")
```
### 1.4 % Dead Stock PCT_Value 
```dax
% Dead Stock PCT_Value = DIVIDE([Dead Stock Value], [Ending Inventory Value], 0)
```
### 1.5 Healthy Stock Value  & Watch Stock Value & Slow Moving Value & Dead Stock Value
```dax
Healthy Stock Value = CALCULATE([Ending Inventory Value], Inventory_FIFO[FIFO_Stock_Aging_Category] = "0-90 Days (Healthy)")
Watch Stock Value = CALCULATE([Ending Inventory Value], Inventory_FIFO[FIFO_Stock_Aging_Category] = "91-365 Days (Watch)")
Slow Moving Value = CALCULATE([Ending Inventory Value], Inventory_FIFO[FIFO_Stock_Aging_Category] = "1-2 Years (Slow)")
Dead Stock Value = CALCULATE([Ending Inventory Value], Inventory_FIFO[FIFO_Stock_Aging_Category] = "Over 2 Years (Dead Stock)")
```
### 2. PAGE(2) => => =>  Inventory Turnover & Rotational Velocity
```dax
Total_COGS = SUM(FactInternetSales[TotalProductCost]) + SUM(FactResellerSales[TotalProductCost])
```
### 2.1 Average Inventory
```dax
Average Inventory (Period) = 
VAR DatesWithData = VALUES(Date_Table[Date])
RETURN AVERAGEX(DatesWithData, CALCULATE(SUM(Inventory_FIFO[Total _Cost Inventore])))
```
### 2.2 Inventory Turnover
```dax
Inventory_Turnover = DIVIDE([Total_COGS], [Average Inventory (Period)], 0)
```
### 2.3 Days Sales of Inventory (DSI)
```dax
DSI = DIVIDE(CALCULATE(COUNTROWS(Date_Table), ALLSELECTED(Date_Table)), [Inventory_Turnover], 0)
```
### 2.4 Product Rotational Speed Range
```dax
Product Rotational Speed Range = 
VAR CurrentDSI = [DSI]
VAR CurrentSales = [Total_Sales_Company]
RETURN
SWITCH(TRUE(),
    ISBLANK(CurrentSales) || CurrentSales <= 0, "Non-Moving (Dead)",
    CurrentDSI <= 60, "Fast Moving",
    CurrentDSI <= 180, "Medium Moving",
    CurrentDSI <= 365, "Slow Moving", "Non-Moving (Dead)"
) 
```
### 2.5 ABC Cumulative Sales Pareto
```dax
ABC_Cumulative_%Sales = 
VAR Current_Sales = [Total_Sales_Company]
VAR Sales_Per_Product = CALCULATE([Total_Sales_Company], ALLSELECTED(DimProduct))
VAR Product_Key = SELECTEDVALUE(DimProduct[ProductKey])
VAR CumulativeSales = CALCULATE([Total_Sales_Company], FILTER(ALLSELECTED(DimProduct), [Total_Sales_Company] > Current_Sales || ([Total_Sales_Company] = Current_Sales && DimProduct[ProductKey] <= Product_Key)))
VAR Cumulative_PCT = DIVIDE(CumulativeSales, Sales_Per_Product, 0)
RETURN
SWITCH(TRUE(), ISBLANK(Current_Sales) || Current_Sales = 0, "Dead_Stock", Cumulative_PCT <= 0.80, "A", Cumulative_PCT <= 0.95, "B", "C")
```

### 3. PAGE(3)  => => =>  Safety Stock, ROP & Lead Time Planning 
1. Total Quantity Sold All Company
```dax
Total_Qty_Sold_All_Company = SUM(FactInternetSales[OrderQuantity]) + SUM(FactResellerSales[OrderQuantity])
```
2. Daily Consumption
```dax
Daily Consumption = 
VAR TotalQty = [Total_Qty_Sold_All_Company]
VAR SelectedDays = CALCULATE(COUNTROWS(Date_Table), ALLSELECTED(Date_Table))
RETURN DIVIDE(TotalQty, SelectedDays, 0)
```
3. Statistical Safety Stock
```dax
Safety_Stock_Statistical = 
VAR ServiceFactor_95 = 1.65
VAR LeadTimeDays = 8
VAR CurrentMaxDate = MAX('Date_Table'[Date])
VAR HistoricalWindow = DATESBETWEEN('Date_Table'[Date], CurrentMaxDate - 90, CurrentMaxDate)
VAR StdDev_DailyDemand = CALCULATE(STDEVX.P(FILTER(VALUES('Date_Table'[Date]), [Daily consumption] > 0), [Daily consumption]), HistoricalWindow)
RETURN COALESCE(ServiceFactor_95 * StdDev_DailyDemand * SQRT(LeadTimeDays), 0)
```
4. Days on Hand (DOH)
```dax
DOH = 
VAR Daily = [Daily Consumption]
VAR Stock = [Total_Unite_Inventore]
RETURN
SWITCH(
    TRUE(), 
    ISBLANK(Stock) || Stock <= 0, 0, 
    ISBLANK(Daily) || Daily = 0, 999, 
    DIVIDE(Stock, Daily, 0)
)
```
5. Reorder Point (ROP)
```dax
Reorder_Point = 
VAR Lead_Time = 14
VAR Safety_Stock_Val = [Safety_Stock_Statistical]
VAR Daily_Sales = [Daily Consumption]
RETURN (Daily_Sales * Lead_Time) + Safety_Stock_Val
```
### 4. PAGE(4) => => =>  GMROI & Stockout Rate Analysis 
1. GMROI
```dax
GMROI = DIVIDE([Gross_Profit_Company], [Average Inventory (Period)], 0)
```
2. Stockout Rate Percentage
```dax
Stockout_Rate_% = 
VAR CurrentDates = VALUES(Date_Table[Date])
VAR TotalDays = COUNTROWS(CurrentDates)
VAR Calculatio = 
    AVERAGEX(
        KEEPFILTERS(VALUES(Inventory_FIFO[ProductKey])),
        VAR ProductStockoutDays = 
            COUNTROWS(
                FILTER(
                    CurrentDates,
                    VAR CurrentDate = Date_Table[Date]
                    VAR StockBalance = CALCULATE(SUM(Inventory_FIFO[UnitsBalance]), Inventory_FIFO[MovementDate] = CurrentDate)
                    RETURN ISBLANK(StockBalance) || StockBalance = 0
                )
            )
        RETURN DIVIDE(ProductStockoutDays, TotalDays, 0)
    )
RETURN IF(ISBLANK(Calculatio), 0, Calculatio)
```















