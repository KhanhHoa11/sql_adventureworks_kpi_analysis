USE AdventureWorks2019;
WITH Monetary_Raw AS (
    SELECT
        CustomerID,
        SUM(SubTotal) AS TotalRevenue,
        PERCENT_RANK() OVER (ORDER BY SUM(SubTotal) ASC) AS PercentRank_Rev
    FROM Sales.SalesOrderHeader 
    WHERE Status = 5 
    GROUP BY CustomerID),

Monetary_Category AS (
    SELECT
        CustomerID,
        TotalRevenue,
        CASE
            WHEN PercentRank_Rev <= 0.25 THEN 1
            WHEN PercentRank_Rev <= 0.5 THEN 2
            WHEN PercentRank_Rev <= 0.75 THEN 3
            ELSE 4
        END AS Monetary
    FROM Monetary_Raw),

Frequency_Raw AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
        PERCENT_RANK() OVER (ORDER BY COUNT(DISTINCT SalesOrderNumber) ASC) AS PercentRank_Freq
    FROM Sales.SalesOrderHeader 
    WHERE Status = 5
    GROUP BY CustomerID),

Frequency_Category AS (
    SELECT
        CustomerID,
        TotalOrders,
        CASE
            WHEN PercentRank_Freq <= 0.25 THEN 1
            WHEN PercentRank_Freq <= 0.5 THEN 2
            WHEN PercentRank_Freq <= 0.75 THEN 3
            ELSE 4
        END AS Frequency
    FROM Frequency_Raw),

Recency_Raw AS (
    SELECT
        CustomerID,
        DATEDIFF(DAY, MAX(OrderDate), '2014-06-30') AS DaysSinceLastPurchase,
        PERCENT_RANK() OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2014-06-30') DESC) AS PercentRank_Rec
    FROM Sales.SalesOrderHeader
    WHERE Status = 5
    GROUP BY CustomerID),

Recency_Category AS (
    SELECT
        CustomerID,
        DaysSinceLastPurchase,
        CASE
            WHEN PercentRank_Rec <= 0.25 THEN 1
            WHEN PercentRank_Rec <= 0.5 THEN 2
            WHEN PercentRank_Rec <= 0.75 THEN 3
            ELSE 4
        END AS Recency
    FROM Recency_Raw),

RFM_Scores AS (
    SELECT
        m.CustomerID,
        m.TotalRevenue,
        f.TotalOrders,
        r.DaysSinceLastPurchase,
        m.Monetary,
        f.Frequency,
        r.Recency,
        CONCAT(r.Recency, f.Frequency, m.Monetary) AS RFM_Score
    FROM Monetary_Category m
    LEFT JOIN Frequency_Category f ON m.CustomerID = f.CustomerID
    LEFT JOIN Recency_Category r ON m.CustomerID = r.CustomerID)
SELECT
    *,
    CASE
        WHEN RFM_Score = '444' THEN 'Best Customer'
        WHEN RFM_Score LIKE '1%1' THEN 'Lost Cheap Customer'
        WHEN RFM_Score LIKE '1%4' THEN 'Lost Big Customer'
        WHEN RFM_Score LIKE '2%4' THEN 'Almost Big Customer'
        WHEN RFM_Score LIKE '%4' THEN 'Big Spender'
        WHEN RFM_Score LIKE '%4%' THEN 'Loyal Customer'
        WHEN RFM_Score LIKE '2%' THEN 'Almost Lost'
        ELSE 'Other'
    END AS CustomerCategory
FROM RFM_Scores
ORDER BY RFM_Score DESC
