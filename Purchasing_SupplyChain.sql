--Scenario 1: Vendor On-Time Delivery & Lead Time Performance
--Business Question: Which vendors consistently ship raw materials past the expected due date, and what is their average fulfillment lead time?
--Tables: Purchasing.Vendor ,Purchasing.PurchaseOrderHeader
CREATE OR ALTER PROCEDURE dbo.usb_VendorLeadTime 
AS
BEGIN
SET nocount ON;
SELECT v.BusinessEntityID,
       v.[Name] AS VendorName,
       COUNT(poh.PurchaseOrderID) AS TotalOrdersProcessed,
       AVG(DATEDIFF(DAY, poh.orderDate, poh.ShipDate)) AS AverageFulfillmentLeadTime
FROM Purchasing.Vendor AS v
LEFT JOIN Purchasing.PurchaseOrderHeader AS poh ON v.BusinessEntityID = poh.VendorID
GROUP BY v.BusinessEntityID,
         v.[Name]
ORDER BY AverageFulfillmentLeadTime DESC; 
END
GO

EXEC  dbo.usb_VendorLeadTime;
=============================================================================================
--Scenario 2: Top Purchased Raw Materials & Cost Variance
--Business Question: "What are our highest-cost raw materials, and which suppliers provide them at the highest total spend?"
--Tables:Purchasing.PurchaseOrderDetail,Purchasing.PurchaseOrderHeader,Production.Product,Purchasing.Vendor (Vendor names)

CREATE OR ALTER PROCEDURE dbo.usp_costVaraince 
AS BEGIN
SET nocount ON ;
SELECT TOP 20 
       v.BusinessEntityID,
       v.[Name] AS VendorName,
       p.[Name] AS ProductName,
       p.ProductID,
       p.[Name] AS ProductName,
       SUM(pod.OrderQty) AS TotalQuantityOrdered,
       SUM(pod.LineTotal) AS TotalSpend,
       AVG(pod.UnitPrice) AS AverageUnitPrice,
       p.StandardCost AS ExpectedUnitPrice,
       SUM((pod.uniTprice - p.standardCost) * pod.OrderQty) AS TotalCostVarianceAmount
FROM Purchasing.Vendor AS v
INNER JOIN Purchasing.PurchaseOrderHeader AS poh ON v.BusinessEntityID = poh.VendorID
INNER JOIN Purchasing.PurchaseOrderDetail AS pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
INNER JOIN Production.Product AS p ON p.productID = pod.productID
GROUP BY 
       v.BusinessEntityID,
       v.[Name],
       p.ProductID,
       p.[Name],
       p.StandardCost
ORDER BY TotalSpend DESC; 
END
GO
EXEC dbo.usp_costVaraince
====================================================================================================
--Scenario 3: Purchase Order Status & Approval Workflow Monitoring
--Business Question: "How many purchase orders are currently pending approval, rejected, or fully approved across our buying staff?"
--Tables:Purchasing.PurchaseOrderHeader,HumanResources.Employee,Person.Person
CREATE OR ALTER PROCEDURE dbo.usp_PurcahseOrderStausApporval 
AS 
BEGIN
SET nocount ON;
SELECT CASE poh.Status
           WHEN 1 THEN 'Pending'
           WHEN 2 THEN 'Approved'
           WHEN 3 THEN 'Rejected'
           WHEN 4 THEN 'Cancelled'
           ELSE 'Unknow'
       END AS PurchaseOrderStatus,
       e.JobTitle,
       COALESCE (p.FirstName,'N/A') AS BuyerFirstName,
       COALESCE (p.LastName, 'N/A') AS BuyerLastName,
       COUNT(poh.PurchaseOrderID) AS TotalPurchaseOrders,
       SUM(poh.TotalDue) AS TotalOrderValue
           
FROM Purchasing.PurchaseOrderHeader AS poh
LEFT JOIN HumanResources.Employee AS e ON poh.EmployeeID = e.BusinessEntityID
LEFT JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY 
poh.Status,
e.JobTitle,
p.FirstName,
p.LastName
ORDER BY TotalPurchaseOrders DESC
END
GO
EXEC dbo.usp_PurcahseOrderStausApporval;
=========================================================================================================
