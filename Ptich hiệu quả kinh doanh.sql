USE AdventureWorks2019
--- Doanh thu hàng tháng/quý/năm của Adventure Works thay đổi như thế nào, và những giai đoạn nào có doanh thu cao nhất?
SELECT 
    YEAR(OrderDate) AS Year, 
    MONTH(OrderDate) AS Month, 
    SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month

--- Những sản phẩm nào (TOP 10 sản phẩm) có doanh thu cao nhất và mang lại lợi nhuận lớn nhất trong năm qua?
SELECT TOP 10
    b.Name AS ProductName, 
    SUM(a.OrderQty) AS TotalSold, 
    SUM(a.LineTotal) AS TotalRevenue, 
    SUM(a.LineTotal - (COALESCE(b.StandardCost, 0) * a.OrderQty)) AS TotalProfit
FROM Sales.SalesOrderDetail a
LEFT JOIN Production.Product b ON a.ProductID = b.ProductID
WHERE YEAR(a.ModifiedDate) = 2014
GROUP BY b.Name
ORDER BY TotalProfit DESC

--- Những sản phẩm nào tồn kho lâu nhất và có tốc độ tiêu thụ thấp nhất trong năm 2014?
SELECT 
    b.Name AS ProductName, 
    a.Quantity AS StockQuantity, 
    ISNULL(SUM(c.OrderQty), 0) AS TotalSold
FROM Production.ProductInventory a
LEFT JOIN Production.Product b ON a.ProductID = b.ProductID
LEFT JOIN Sales.SalesOrderDetail c ON a.ProductID = c.ProductID 
    AND c.ModifiedDate >= '2014-1-1'
GROUP BY b.Name, a.Quantity
ORDER BY TotalSold ASC, StockQuantity DESC

--- Khu vực nào mang lại doanh thu cao nhất, và khu vực nào cần được cải thiện?
SELECT 
    b.Name AS TerritoryName, 
    SUM(a.TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader a
JOIN Sales.SalesTerritory b ON a.TerritoryID = b.TerritoryID
GROUP BY b.Name
ORDER BY TotalRevenue DESC

--- Khách hàng trung thành và khách hàng mới có xu hướng mua sắm như thế nào về giá trị trung bình của đơn hàng?
SELECT 
    c.CustomerID,
    c.PersonID,
    c.StoreID,
    c.TerritoryID,
    CASE 
        WHEN COUNT(a.SalesOrderID) > 1 THEN 'Returning Customer'
        ELSE 'New Customer'
    END AS CustomerType,
    AVG(a.TotalDue) AS AverageOrderValue
FROM Sales.SalesOrderHeader a
LEFT JOIN Sales.Customer c ON a.CustomerID = c.CustomerID
WHERE YEAR(a.OrderDate) = 2014
GROUP BY 
    c.CustomerID, c.PersonID, c.StoreID, c.TerritoryID
ORDER BY CustomerType ASC, AverageOrderValue DESC

--- Top 10 khách hàng chi tiêu nhiều nhất trong năm qua là ai, và họ thường mua những sản phẩm gì?
WITH CustomerRevenue AS (
    SELECT 
        a.CustomerID, 
        SUM(a.TotalDue) AS TotalSpent
    FROM Sales.SalesOrderHeader a
    WHERE YEAR(a.OrderDate) = 2014  
    GROUP BY a.CustomerID
),
CustomerProducts AS (
    SELECT 
        a.CustomerID,
        c.Name AS ProductName,
        COUNT(b.ProductID) AS ProductCount
    FROM Sales.SalesOrderHeader a
    LEFT JOIN Sales.SalesOrderDetail b ON a.SalesOrderID = b.SalesOrderID
    LEFT JOIN Production.Product c ON b.ProductID = c.ProductID
    WHERE YEAR(a.OrderDate) = 2014
    GROUP BY a.CustomerID, c.Name
)
SELECT TOP 10 
    d.CustomerID, 
    d.TotalSpent, 
    (SELECT TOP 1 e.ProductName 
     FROM CustomerProducts e
     WHERE e.CustomerID = d.CustomerID
     ORDER BY e.ProductCount DESC) AS FrequentlyPurchasedProduct
FROM CustomerRevenue d
ORDER BY d.TotalSpent DESC

--- Doanh thu từ các sản phẩm được giảm giá trong năm 2014 có hiệu quả hơn so với các sản phẩm không giảm giá không?
SELECT 
    CASE 
        WHEN UnitPriceDiscount > 0 THEN 'Discounted' 
        ELSE 'Non-Discounted' 
    END AS DiscountStatus, 
    SUM(LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail 
WHERE ModifiedDate >= '2014-01-01'
GROUP BY 
    CASE 
        WHEN UnitPriceDiscount > 0 THEN 'Discounted' 
        ELSE 'Non-Discounted' 
    END

--- Trong mỗi danh mục, sản phẩm nào được bán chạy nhất, và tỷ lệ lợi nhuận của chúng là bao nhiêu?
SELECT 
    a.Name AS CategoryName, 
    c.Name AS ProductName, 
    SUM(d.OrderQty) AS TotalSold, 
    SUM(d.LineTotal - (c.StandardCost * d.OrderQty)) AS TotalProfit
FROM Production.ProductCategory a
LEFT JOIN Production.ProductSubcategory b ON a.ProductCategoryID = b.ProductCategoryID
LEFT JOIN Production.Product c ON b.ProductSubcategoryID = c.ProductSubcategoryID
LEFT JOIN Sales.SalesOrderDetail d ON c.ProductID = d.ProductID
GROUP BY a.Name, c.Name 
ORDER BY a.Name, TotalSold DESC

