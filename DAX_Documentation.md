### 1. Daily Consumption 
```dax
Daily Consumption = 
VAR TotalQty = [Total_Qty_Sold_All_Company]
VAR SelectedDays = CALCULATE(COUNTROWS(Date_Table), ALLSELECTED(Date_Table))
RETURN DIVIDE(TotalQty, SelectedDays, 0)
```
### 2.
