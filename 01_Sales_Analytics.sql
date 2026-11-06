--High-value orders: “List all orders above a value I choose.
CREATE OR ALTER PROCEDURE dbo.usp_ListAllOrders 
@HighValueThreshold MONEY 
AS 
BEGIN
SET NOCOUNT ON;
SELECT SalesOrderID,
       CustomerID,
       OrderDate,
       TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue>@HighValueThreshold
ORDER BY TotalDue DESC; 
END 
GO
EXEC dbo.usp_ListAllOrders @HighValueThreshold =150000;
================================================================================
--Online vs salesperson orders: “How much came from online orders vs. orders handled by a salesperson?”

CREATE OR ALTER PROCEDURE dbo.usp_OnlineOfflineOrders
AS 
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CASE OnlineOrderFlag
            WHEN 1 THEN 'Online'
            ELSE 'Offline'
        END AS OrderType,
        SUM(TotalDue) AS TotalRevenue,
        COUNT(*) AS TotalOrders
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        OnlineOrderFlag;
END;
GO

EXEC dbo.usp_onlineofflineorders;

===================================================================================================================
--Top customers: “Who are our top 10 customers by spend in a period?”
CREATE OR ALTER PROCEDURE dbo.usp_topcustomers
@StartDate DATE,
@EndDate   DATE
AS
  BEGIN
    SET NOCOUNT ON;
      SELECT TOP 10 c.CustomerID,
                    p.FirstName,
                    p.LastName,
                    Sum(h.TotalDue) TotalRevenue
        FROM Sales.SalesOrderHeader AS h
             LEFT JOIN Sales.Customer AS c
             ON h.CustomerID = c.CustomerID
             LEFT JOIN Person.Person AS p
             ON p.BusinessEntityID = c.PersonID
       WHERE h.OrderDate > = @StartDate AND h.OrderDate <= @EndDate
    GROUP BY c.CustomerID,p.FirstName,p.LastName
    ORDER BY TotalRevenue DESC;
  END
GO

EXEC dbo.usp_topcustomers @StartDate = '2010-01-01', @EndDate = '2014-12-31';
========================================================================================================================================
---Best-selling products: “Which products sold the most units last quarter"?
CREATE OR ALTER PROCEDURE dbo.usb_BestSellingProductsLastQuarter 
@Year INT = 2013,
@Quarter INT = 3
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @StartDate DATE = DATEFROMPARTS(@Year, (@Quarter - 1) * 3 + 1, 1);
    DECLARE @EndDate DATE = EOMONTH(DATEFROMPARTS(@Year, @Quarter * 3, 1));
	SELECT 
        p.Name AS ProductName,
        SUM(d.OrderQty) AS TotalUnitsSold,
        SUM(d.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail AS d
    INNER JOIN Sales.SalesOrderHeader AS h ON d.SalesOrderID = h.SalesOrderID
    INNER JOIN Production.Product AS p ON d.ProductID = p.ProductID
    WHERE h.OrderDate >= @StartDate AND h.OrderDate <= @EndDate
    GROUP BY p.Name
    ORDER BY TotalUnitsSold DESC;
    END
    GO

EXEC dbo.usb_BestSellingProductsLastQuarter @Year = 2013 ,@Quarter = 3
=======================================================================================================================
--Sales by product category: “How does revenue split across bikes, components, clothing, and accessories?”
CREATE OR ALTER PROCEDURE dbo.usp_SalesByProductCategory 
@CategoryID int = NULL,
@SubCategoryID int = NULL 
AS 
BEGIN
SET nocount ON ;
SELECT p.ProductID,
       p.Name AS ProductName,
       pc.ProductCategoryID,
       pc.Name AS ProductCategoryName,
       ps.ProductSubcategoryID,
       ps.Name AS ProductSubcategoryName,
       od.SalesOrderID,
       SUM(od.LineTotal) AS SalesAmount
FROM Production.Product AS p
INNER JOIN Sales.SalesOrderDetail AS od ON p.ProductID = od.ProductID
INNER JOIN Production.ProductSubcategory AS ps ON p.ProductSubCategoryID = ps.ProductSubCategoryID
INNER JOIN production.productCategory AS pc ON ps.productCategoryID = pc.productCategoryID
WHERE (@CategoryID IS NULL
       OR pc.ProductCategoryID = @CategoryID)
  AND (@SubCategoryID IS NULL
       OR ps.ProductSubCategoryID = @SubCategoryID)
GROUP BY p.ProductID,
         p.Name,
         pc.ProductCategoryID,
         pc.Name,
         ps.ProductSubcategoryID,
         ps.Name,
         od.SalesOrderID
ORDER BY SalesAmount DESC; 
END;
GO

EXEC dbo.usp_SalesByProductCategory 
EXEC dbo.usp_SalesByProductCategory @CategoryID= 1;
EXEC dbo.usp_SalesByProductCategory @SubCategoryID = 2;
EXEC dbo.usp_SalesByProductCategory @CategoryID= 1 , @SubCategoryID = 1;
====================================================================================================================
--Monthly trend: “Show sales per month for a year.”
CREATE OR ALTER PROCEDURE dbo.usp_MonthlyTrend 
@TargetYear int 
AS 
BEGIN
SET Nocount ON;
SELECT 
    YEAR(OrderDate) AS [YEAR],
    MONTH(OrderDate) AS [Month],
    DATENAME(MONTH, OrderDate) AS MonthName,
    SUM(TotalDue) AS MonthlySales
FROM Sales.SalesOrderHeader
WHERE YEAR(ORDERDATE) = @Targetyear
GROUP BY 
    YEAR(OrderDate),
    MONTH(OrderDate),
    DATENAME(MONTH, OrderDate)
ORDER BY 
    [Year] ASC,
    [Month] ASC; 
END;
GO

EXEC dbo.usp_MonthlyTrend @TargetYear = 2012
===========================================================================================================
