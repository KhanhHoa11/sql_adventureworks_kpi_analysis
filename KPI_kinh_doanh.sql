USE AdventureWorks2019
-- Tính toán một số chỉ số KPI cho công ty
--- Lợi nhuận ròng từng năm
SELECT 
    Revenue.Year,
    Revenue.Revenue - COGS.COGS - SalesCost.SalesCost AS NetProfit
FROM (
    (SELECT YEAR(SalesOrderHeader.OrderDate) AS Year, SUM(SalesOrderDetail.LineTotal) AS Revenue
     FROM Sales.SalesOrderDetail
     LEFT JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
     WHERE SalesOrderHeader.Status = 5
     GROUP BY YEAR(SalesOrderHeader.OrderDate)) AS Revenue
LEFT JOIN 
    (SELECT YEAR(SalesOrderHeader.OrderDate) AS Year, SUM(SalesOrderDetail.LineTotal - Product.StandardCost) AS COGS
     FROM Sales.SalesOrderDetail
     LEFT JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
     LEFT JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
     WHERE SalesOrderHeader.Status = 5
     GROUP BY YEAR(SalesOrderHeader.OrderDate)) AS COGS
ON Revenue.Year = COGS.Year
LEFT JOIN 
    (SELECT YEAR(SalesOrderHeader.OrderDate) AS Year, 0 AS SalesCost
     FROM Sales.SalesOrderHeader
     WHERE SalesOrderHeader.Status = 5
     GROUP BY YEAR(SalesOrderHeader.OrderDate)) AS SalesCost
ON Revenue.Year = SalesCost.Year
)
ORDER BY Revenue.Year DESC

--- Tỷ suất lợi nhuận/ Doanh thu (ROS)
SELECT 
    Revenue.Year,
    (Revenue.Revenue - COGS.COGS - SalesCost.SalesCost) / Revenue.Revenue * 100 AS ROS
FROM (
    (SELECT YEAR(SalesOrderHeader.OrderDate) AS Year, SUM(SalesOrderDetail.LineTotal) AS Revenue
     FROM Sales.SalesOrderDetail
     LEFT JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
     WHERE SalesOrderHeader.Status = 5
     GROUP BY YEAR(SalesOrderHeader.OrderDate)) AS Revenue
LEFT JOIN 
    (SELECT YEAR(SalesOrderHeader.OrderDate) AS Year, SUM(SalesOrderDetail.LineTotal - Product.StandardCost) AS COGS
     FROM Sales.SalesOrderDetail
     LEFT JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
     LEFT JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
     WHERE SalesOrderHeader.Status = 5
     GROUP BY YEAR(SalesOrderHeader.OrderDate)) AS COGS
ON Revenue.Year = COGS.Year
LEFT JOIN 
    (SELECT YEAR(SalesOrderHeader.OrderDate) AS Year, 0 AS SalesCost
     FROM Sales.SalesOrderHeader
     WHERE SalesOrderHeader.Status = 5
     GROUP BY YEAR(SalesOrderHeader.OrderDate)) AS SalesCost
ON Revenue.Year = SalesCost.Year
)
ORDER BY Revenue.Year DESC

--- Tỷ lệ quay vòng hàng tồn kho
SELECT 
    YEAR(SalesOrderHeader.OrderDate) AS Year,
    SUM(SalesOrderDetail.LineTotal - Product.StandardCost) AS COGS,
    AVG(Product.StandardCost) AS AvgInventory,
    SUM(SalesOrderDetail.LineTotal - Product.StandardCost) / AVG(Product.StandardCost) AS InventoryTurnover
FROM Sales.SalesOrderDetail
LEFT JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
LEFT JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
WHERE SalesOrderHeader.Status = 5
GROUP BY YEAR(SalesOrderHeader.OrderDate)
ORDER BY YEAR(SalesOrderHeader.OrderDate) DESC
