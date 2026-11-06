# Enterprise Operations & T-SQL Analytics VeloPulse 360

Welcome to the **AdventureWorks T-SQL Analytics Suite**, an enterprise-grade data engineering and analytical SQL project. This repository contains a structured collection of parameterised T-SQL stored procedures and business intelligence scripts engineered against the `AdventureWorks2019` relational database.

The project models real-world business scenarios across four key organizational pillars: **Sales Analytics**, **Production & Inventory Control**, **Purchasing & Supply Chain Management**, and **Human Resources & Workforce Analytics**.

---

## 📁 Repository Structure

```text
AdventureWorks-T-SQL-Analytics-Suite/
│
├── 01_Sales_Analytics/
│   ├── 01_usp_OrderByStatus.sql
│   ├── 02_usp_ListAllOrders.sql
│   ├── 03_usp_OnlineOfflineOrders.sql
│   ├── 04_usp_TopCustomers.sql
│   ├── 05_usp_BestSellingProductsLastQuarter.sql
│   ├── 06_usp_SalesByProductCategory.sql
│   └── 07_usp_MonthlyTrend.sql
│
├── 02_Production_Inventory/
│   ├── 01_usp_RunningLowStock.sql
│   └── 02_usp_TotalCapital.sql
│
├── 03_Purchasing_SupplyChain/
│   ├── 01_usp_VendorLeadTime.sql
│   ├── 02_usp_CostVariance.sql
│   └── 03_usp_PurchaseOrderStatusApproval.sql
│
├── 04_HumanResources_Analytics/
│   ├── 01_usp_HeadcountTenureAnalysis.sql
│   ├── 02_usp_HistoricalSalaryGrowth.sql
│   └── 03_usp_JobCandidatePipeline.sql
│
└── README.md
```

---

## 📊 Business Domains & Stored Procedures

### 1. Sales & Commercial Analytics

This module addresses core revenue questions, customer lifetime performance, channel distribution, and temporal trend analysis.

* **`dbo.usp_OrderByStatus`**
  * **Business Scenario:** Operational monitoring of order volume across fulfillment stages (In Process, Shipped, Cancelled, etc.) for a specified date range.
  * **Tables:** `Sales.SalesOrderHeader`
  * **Parameters:** `@StartDate DATE`, `@EndDate DATE`

* **`dbo.usp_ListAllOrders`**
  * **Business Scenario:** Isolates high-value transactions above a dynamic monetary threshold for auditing and VIP order fulfillment.
  * **Tables:** `Sales.SalesOrderHeader`
  * **Parameters:** `@HighValueThreshold MONEY`

* **`dbo.usp_OnlineOfflineOrders`**
  * **Business Scenario:** Compares digital e-commerce channel performance against direct salesperson-driven sales volume and revenue totals.
  * **Tables:** `Sales.SalesOrderHeader`

* **`dbo.usp_topcustomers`**
  * **Business Scenario:** Identifies the top 10 revenue-generating customers across any customizable timeframe to support CRM strategy.
  * **Tables:** `Sales.SalesOrderHeader`, `Sales.Customer`, `Person.Person`
  * **Parameters:** `@StartDate DATE`, `@EndDate DATE`

* **`dbo.usb_BestSellingProductsLastQuarter`**
  * **Business Scenario:** Tracks unit sales velocity and gross line revenue by product for any specified historical year and quarter.
  * **Tables:** `Sales.SalesOrderDetail`, `Sales.SalesOrderHeader`, `Production.Product`
  * **Parameters:** `@Year INT = 2013`, `@Quarter INT = 3`

* **`dbo.usp_SalesByProductCategory`**
  * **Business Scenario:** Analyzes top-level product category and subcategory sales performance with optional hierarchy filtering.
  * **Tables:** `Production.Product`, `Sales.SalesOrderDetail`, `Production.ProductSubcategory`, `Production.ProductCategory`
  * **Parameters:** `@CategoryID INT = NULL`, `@SubCategoryID INT = NULL`

* **`dbo.usp_MonthlyTrend`**
  * **Business Scenario:** Evaluates monthly sales growth trajectories and seasonal revenue patterns across a target calendar year.
  * **Tables:** `Sales.SalesOrderHeader`
  * **Parameters:** `@TargetYear INT`

---

### 2. Production & Inventory Operations

This module focuses on warehouse asset valuation and operational stock boundary tracking.

* **`dbo.usp_RunningLowStock`**
  * **Business Scenario:** Triggers low-stock alerts for products falling below their dynamic `SafetyStockLevel` across warehouse locations.
  * **Tables:** `Production.ProductInventory`, `Production.Product`, `Production.Location`

* **`dbo.usp_TotalCapital`**
  * **Business Scenario:** Calculates capital investment tied up in physical inventory by evaluating current stock quantities against standard product costs.
  * **Tables:** `Production.ProductInventory`, `Production.Product`, `Production.Location`, `Production.ProductCostHistory`

---

### 3. Purchasing & Supply Chain Management

This module measures vendor fulfillment efficiency, procurement cost variances, and internal buying authorization workflows.

* **`dbo.usb_VendorLeadTime`**
  * **Business Scenario:** Evaluates supplier fulfillment speed by calculating average delivery lead times in days across all purchase orders.
  * **Tables:** `Purchasing.Vendor`, `Purchasing.PurchaseOrderHeader`

* **`dbo.usp_costVaraince`**
  * **Business Scenario:** Ranks top material spend concentration and evaluates cost variance between actual supplier purchase price and standard cost.
  * **Tables:** `Purchasing.Vendor`, `Purchasing.PurchaseOrderHeader`, `Purchasing.PurchaseOrderDetail`, `Production.Product`

* **`dbo.usp_PurcahseOrderStausApporval`**
  * **Business Scenario:** Audits internal purchase order approval workflows, summarizing order volume and total financial value by buyer and status.
  * **Tables:** `Purchasing.PurchaseOrderHeader`, `HumanResources.Employee`, `Person.Person`

---

### 4. Human Resources & Workforce Analytics

This module delivers metrics on staffing headcounts, organizational tenure, payroll compensation distribution, and talent acquisition conversion.

* **`dbo.usp_HeadcountTenureAnalysis`**
  * **Business Scenario:** Summarizes departmental headcount, company tenure, and accrued leave liabilities (vacation and sick leave hours).
  * **Tables:** `HumanResources.Department`, `HumanResources.EmployeeDepartmentHistory`, `HumanResources.Employee`
  * **Parameters:** `@departmentName NVARCHAR(50) = NULL`

* **`dbo.usp_HistoricalSalesGrowth`**
  * **Business Scenario:** Evaluates departmental compensation tiers, tracking average and maximum hourly pay rates across active assignments.
  * **Tables:** `HumanResources.Department`, `HumanResources.EmployeeDepartmentHistory`, `HumanResources.EmployeePayHistory`
  * **Parameters:** `@MinAvgRate DECIMAL(10,2) = 0.00`

* **`dbo.usp_JobCandidatePipeline`**
  * **Business Scenario:** Tracks recruitment pipeline conversion rates by classifying external candidates versus hired employees.
  * **Tables:** `HumanResources.JobCandidate`
  * **Parameters:** `@IsHired INT = NULL`

---

## 🛠️ Prerequisites & Setup

1. **SQL Server & SSMS:** SQL Server 2019 (or newer) with SQL Server Management Studio (SSMS).
2. **Database:** Restore the official `AdventureWorks2019.bak` database file.
3. **Deployment:** Execute script files sequentially or in domain groups to compile all stored procedures into the `dbo` schema.

---

## 💻 Sample Execution Script

```sql
USE AdventureWorks2019;
GO

-- 1. Check Sales Performance for 2013 Q3
EXEC dbo.usb_BestSellingProductsLastQuarter @Year = 2013, @Quarter = 3;

-- 2. Audit Warehouses for Low-Stock Items
EXEC dbo.usp_RunningLowStock;

-- 3. Review Vendor Performance Lead Times
EXEC dbo.usb_VendorLeadTime;

-- 4. Evaluate HR Departmental Headcount & Leave Liabilities
EXEC dbo.usp_HeadcountTenureAnalysis @departmentName = 'Sales';
```
