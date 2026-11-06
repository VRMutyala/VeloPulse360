USE AdventureWorks2019;
GO

--------------------------------------------------------------------------------
-- 1. Sales & Customer Analytics View
--------------------------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_SalesAnalytics AS
SELECT 
    h.SalesOrderID,
    h.OrderDate,
    YEAR(h.OrderDate) AS OrderYear,
    MONTH(h.OrderDate) AS OrderMonth,
    DATENAME(MONTH, h.OrderDate) AS MonthName,
    h.CustomerID,
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
    CASE h.Status
        WHEN 1 THEN 'In Process'
        WHEN 2 THEN 'Approved'
        WHEN 3 THEN 'BackOrdered'
        WHEN 4 THEN 'Rejected'
        WHEN 5 THEN 'Shipped'
        WHEN 6 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS OrderStatus,
    CASE h.OnlineOrderFlag
        WHEN 1 THEN 'Online'
        ELSE 'Offline'
    END AS OrderChannel,
    d.ProductID,
    pr.Name AS ProductName,
    pc.Name AS ProductCategoryName,
    ps.Name AS ProductSubcategoryName,
    d.OrderQty,
    d.UnitPrice,
    d.LineTotal AS LineRevenue,
    h.TotalDue AS OrderTotalRevenue
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID
INNER JOIN Production.Product AS pr ON d.ProductID = pr.ProductID
LEFT JOIN Production.ProductSubcategory AS ps ON pr.ProductSubCategoryID = ps.ProductSubCategoryID
LEFT JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN Sales.Customer AS c ON h.CustomerID = c.CustomerID
LEFT JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID;
GO

--------------------------------------------------------------------------------
-- 2. Production & Inventory Operations View
--------------------------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_InventoryOperations AS
SELECT 
    i.ProductID,
    p.Name AS ProductName,
    p.ProductNumber,
    l.LocationID,
    l.Name AS LocationName,
    i.Quantity AS CurrentStockLevel,
    p.SafetyStockLevel,
    p.StandardCost,
    CAST(i.Quantity AS DECIMAL(18, 2)) * p.StandardCost AS TotalCapitalValue,
    CASE 
        WHEN i.Quantity < p.SafetyStockLevel THEN 'Low Stock - Reorder'
        ELSE 'Sufficient Stock'
    END AS StockStatus
FROM Production.ProductInventory AS i
INNER JOIN Production.Product AS p ON i.ProductID = p.ProductID
INNER JOIN Production.Location AS l ON i.LocationID = l.LocationID;
GO

--------------------------------------------------------------------------------
-- 3. Purchasing & Supply Chain View
--------------------------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_PurchasingSupplyChain AS
SELECT 
    poh.PurchaseOrderID,
    poh.OrderDate,
    poh.ShipDate,
    DATEDIFF(DAY, poh.OrderDate, poh.ShipDate) AS FulfillmentLeadTimeDays,
    CASE poh.Status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Approved'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS PurchaseOrderStatus,
    v.BusinessEntityID AS VendorID,
    v.Name AS VendorName,
    p.ProductID,
    p.Name AS ProductName,
    pod.OrderQty,
    pod.UnitPrice AS ActualUnitPrice,
    p.StandardCost AS ExpectedStandardCost,
    pod.LineTotal AS TotalSpend,
    (pod.UnitPrice - p.StandardCost) * pod.OrderQty AS CostVarianceAmount,
    CONCAT(buyer.FirstName, ' ', buyer.LastName) AS BuyerName,
    e.JobTitle AS BuyerJobTitle
FROM Purchasing.PurchaseOrderHeader AS poh
INNER JOIN Purchasing.Vendor AS v ON poh.VendorID = v.BusinessEntityID
INNER JOIN Purchasing.PurchaseOrderDetail AS pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
INNER JOIN Production.Product AS p ON pod.ProductID = p.ProductID
LEFT JOIN HumanResources.Employee AS e ON poh.EmployeeID = e.BusinessEntityID
LEFT JOIN Person.Person AS buyer ON e.BusinessEntityID = buyer.BusinessEntityID;
GO

--------------------------------------------------------------------------------
-- 4. Human Resources Analytics View
--------------------------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_HumanResourcesAnalytics AS
SELECT 
    e.BusinessEntityID AS EmployeeID,
    CONCAT(p.FirstName, ' ', p.LastName) AS EmployeeName,
    d.DepartmentID,
    d.Name AS DepartmentName,
    d.GroupName AS DepartmentGroup,
    e.JobTitle,
    e.HireDate,
    DATEDIFF(MONTH, e.HireDate, GETDATE()) / 12.0 AS TenureYears,
    e.VacationHours,
    e.SickLeaveHours,
    eph.Rate AS HourlyPayRate,
    jc.JobCandidateID,
    CASE 
        WHEN jc.JobCandidateID IS NOT NULL THEN 'Hired / Internal Match'
        ELSE 'Active Employee'
    END AS CandidateStatus
FROM HumanResources.Employee AS e
INNER JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh ON e.BusinessEntityID = edh.BusinessEntityID
INNER JOIN HumanResources.Department AS d ON edh.DepartmentID = d.DepartmentID
LEFT JOIN HumanResources.EmployeePayHistory AS eph ON e.BusinessEntityID = eph.BusinessEntityID
LEFT JOIN HumanResources.JobCandidate AS jc ON e.BusinessEntityID = jc.BusinessEntityID
WHERE edh.EndDate IS NULL; -- Only active department assignments
GO
=============================================================================================================
SELECT * FROM dbo.vw_SalesAnalytics;
SELECT * FROM dbo.vw_InventoryOperations;
SELECT * FROM dbo.vw_PurchasingSupplyChain ;
SELECT * FROM dbo.vw_HumanResourcesAnalytics;