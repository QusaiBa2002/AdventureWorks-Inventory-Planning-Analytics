CREATE OR ALTER VIEW dbo.vw_FactProductInventory_FIFO AS
WITH ProductMinDates AS (
    SELECT 
        ProductKey,
        MIN(MovementDate) AS InitialDate
    FROM dbo.FactProductInventory
    GROUP BY ProductKey
),
CombinedReceipts AS (
    SELECT 
        ProductKey, 
        MovementDate AS ReceiptDate, 
        UnitsIn
    FROM dbo.FactProductInventory 
    WHERE UnitsIn > 0

    UNION ALL

    SELECT 
        p.ProductKey, 
        p.InitialDate AS ReceiptDate, 
        f.UnitsBalance AS UnitsIn
    FROM ProductMinDates p
    JOIN dbo.FactProductInventory f 
        ON p.ProductKey = f.ProductKey AND p.InitialDate = f.MovementDate
    WHERE f.UnitsBalance > 0
),
ReceiptsWithRunningTotal AS (
    SELECT 
        ProductKey,
        ReceiptDate,
        SUM(UnitsIn) OVER (
            PARTITION BY ProductKey 
            ORDER BY ReceiptDate DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeUnitsIn
    FROM CombinedReceipts
),
RankedMatches AS (
    SELECT 
        s.ProductKey,
        s.DateKey,
        s.MovementDate,
        s.UnitCost,
        s.UnitsIn,
        s.UnitsOut,
        s.UnitsBalance,
        r.ReceiptDate AS FIFOOldestStockDate,
        ROW_NUMBER() OVER (
            PARTITION BY s.ProductKey, s.MovementDate 
            ORDER BY r.ReceiptDate DESC
        ) AS Rn
    FROM dbo.FactProductInventory s
    LEFT JOIN ReceiptsWithRunningTotal r 
        ON s.ProductKey = r.ProductKey
        AND r.ReceiptDate <= s.MovementDate
        AND r.CumulativeUnitsIn >= s.UnitsBalance
)
SELECT 
    ProductKey,
    DateKey,
    MovementDate,
    UnitCost,
    UnitsIn,
    UnitsOut,
    UnitsBalance,
    FIFOOldestStockDate,
    DATEDIFF(DAY, ISNULL(FIFOOldestStockDate, MovementDate), MovementDate) AS FIFO_Stock_Age_Days,
    
    -- تعديل شروط الشرائح لمنع تحويل كل المخزون إلى Dead Stock
    CASE 
        WHEN UnitsBalance = 0 THEN 'No Stock'
        WHEN DATEDIFF(DAY, ISNULL(FIFOOldestStockDate, MovementDate), MovementDate) <= 90 THEN '0-90 Days (Healthy)'
        WHEN DATEDIFF(DAY, ISNULL(FIFOOldestStockDate, MovementDate), MovementDate) <= 365 THEN '91-365 Days (Watch)'
        WHEN DATEDIFF(DAY, ISNULL(FIFOOldestStockDate, MovementDate), MovementDate) <= 730 THEN '1-2 Years (Slow)'
        ELSE 'Over 2 Years (Dead Stock)'
    END AS FIFO_Stock_Aging_Category,

    CASE 
        WHEN UnitsBalance = 0 THEN 0
        WHEN DATEDIFF(DAY, ISNULL(FIFOOldestStockDate, MovementDate), MovementDate) <= 90 THEN 1
        WHEN DATEDIFF(DAY, ISNULL(FIFOOldestStockDate, MovementDate), MovementDate) <= 365 THEN 2
        WHEN DATEDIFF(DAY, ISNULL(FIFOOldestStockDate, MovementDate), MovementDate) <= 730 THEN 3
        ELSE 4
    END AS FIFO_Aging_Sort

FROM RankedMatches
WHERE Rn = 1;
