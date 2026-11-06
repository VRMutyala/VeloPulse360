-- 1.Low-Stock Inventory Alert
--Business Scenario: Which products are running low in stock across our warehouse locations and need immediate reordering?
--Tables : Production.ProductInventory, Production.Product, Production.Location
CREATE OR ALTER PROCEDURE dbo.usp_RunningLowStock 
AS BEGIN
SET nocount ON;
SELECT i.ProductID,
       i.Quantity,
       p.[Name] AS ProductName,
       l.LocationID,
       l.[Name] AS LocationName
FROM Production.ProductInventory AS i
INNER JOIN Production.Product AS p ON i.ProductID = p.ProductID
LEFT JOIN Production.Location AS l ON l.LocationID = i.LocationID
WHERE i.Quantity < p.SafetyStockLevel
ORDER BY i.Quantity ASC; 
END 
GO

EXEC dbo.usp_RunningLowStock
=====================================================================================================
--2. Inventory Valuation by Location Procedure
--Business Scenario: What is the total capital tied up in inventory across each of our warehouse locations?
--Tables: Production.ProductInventory, Production.Product, Production.Location, Production.ProductCostHistory
CREATE OR ALTER PROCEDURE dbo.usp_TotalCapital 
AS BEGIN
SET NOCOUNT ON;
SELECT 
        l.LocationID,
        l.[Name] AS LocationName,
        SUM(CAST(i.Quantity AS DECIMAL(18, 2)) * h.StandardCost) AS Totalcapital
FROM Production.ProductInventory AS i
INNER JOIN Production.Product AS p ON i.ProductID = p.ProductID
INNER JOIN Production.Location AS l ON l.LocationID = i.LocationID
INNER JOIN Production.ProductCostHistory AS h ON h.ProductID = p.ProductID
GROUP BY l.LocationID,
         l.[Name]
ORDER BY Totalcapital DESC END GO

EXEC dbo.usp_TotalCapital;
=====================================================================================================
