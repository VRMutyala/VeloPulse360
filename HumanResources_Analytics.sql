--Scenario 1: Departmental Headcount & Tenure Analysis
--Business Question: "What is the distribution of active employees across our departments, and what is their average tenure and leave balance?"
--Why it matters: Management needs visibility into staffing levels, workforce stability, and accrued liabilities like vacation and sick leave hours.
--Tables Involved:
--HumanResources.Employee (Hire dates, vacation, and sick hours),
--HumanResources.EmployeeDepartmentHistory (Links employees to departments; checks for active assignments where EndDate IS NULL)
--HumanResources.Department (Department names and groups)
CREATE OR ALTER PROCEDURE dbo.usp_HeadcountTenureAnalysis 
@departmentName nvarchar(50) = NULL
AS 
BEGIN
SET nocount ON;
SELECT d.[Name] AS DepartmetName,
       d.GroupName,
       COUNT(e.BusinessEntityID) AS ActiveHeadCount,
       AVG(DATEDIFF(MONTH, e.HireDate, GETDATE()))/12.0 AS AverageTenure,
       SUM(CAST(e.VacationHours AS int)) AS TotalVactionHours,
       Avg(CAST(e.VacationHours AS decimal (10, 2))) AS AvgvactionHours,
       SUM(CAST(e.SickLeaveHours AS int)) AS TotalsickLeaveHours,
       Avg(CAST(e.SickLeaveHours AS decimal (10, 2))) AS AvgsickLeaveHours
FROM HumanResources.Department AS d
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS edh ON d.DepartmentID = edh.DepartmentID
LEFT JOIN HumanResources.Employee AS e ON edh.BusinessEntityID = e.BusinessEntityID
WHERE edh.EndDate IS NULL
  AND (@departmentName IS NULL or d.[Name] = @departmentName)
GROUP BY d.[Name],
         d.GroupName
ORDER BY ActiveHeadCount DESC;
END 
GO

EXEC dbo.usp_HeadcountTenureAnalysis
EXEC dbo.usp_HeadcountTenureAnalysis @departmentName = 'Sales'
EXEC dbo.usp_HeadcountTenureAnalysis @departmentName = 'Marketing'
EXEC dbo.usp_HeadcountTenureAnalysis @departmentName = 'Purchasing'
=====================================================================================================================
--Scenario 2: Historical Salary Growth & Departmental Compensation
--Business Question: "What is the current average and maximum salary across each department, and how have pay rates evolved?"
--Why it matters: HR and finance teams use salary distribution analytics to monitor payroll budgeting, compensation parity, and departmental wage expenses.
--Core Tables Involved:
--HumanResources.EmployeePayHistory (Historical pay rates and change dates)
--HumanResources.EmployeeDepartmentHistory (Department assignments)
--HumanResources.Department (Department names)
CREATE OR ALTER PROCEDURE dbo.usp_HistoricalSalesGrowth
@MinAvgRate DECIMAL(10,2) = 0.00
AS BEGIN
SET nocount ON;
SELECT d.DepartmentID,
       d.[Name] AS DepartmentName,
       SUM(eph.rate) AS TotalRates,
       AVG(eph.rate) AS AverageRates,
       MAX(eph.rate) AS MaxRates
FROM HumanResources.Department AS d
INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh ON d.DepartmentID = edh.DepartmentID
INNER JOIN HumanResources.EmployeePayHistory AS eph ON edh.BusinessEntityID = eph.BusinessEntityID
WHERE edh.EndDate IS NULL
GROUP BY d.DepartmentID,d.[Name]
HAVING AVG(eph.rate) >= @MinAvgRate
ORDER BY AverageRates DESC; 
END 
GO

EXEC dbo.usp_HistoricalSalesGrowth @MinAvgRate = 20.00
================================================================================================================
--Scenario 3: Job Candidate Hiring Pipeline
--Business Question: "How many job applicants apply for specific job titles, and what is the breakdown of recruitment interest?"
--Why it matters: Talent acquisition teams track application volumes to measure the popularity and recruitment bottlenecks of various organizational roles.
--Core Tables Involved:
--HumanResources.JobCandidate (Applicant details and targeted job information)
--What the Stored Procedure Should Do:
--Aggregate applicant counts grouped by application status or targeted job descriptions.
-- Scenario 3: Job Candidate Hiring Pipeline
-- Business Question: "How many job applicants apply, and what is the breakdown of candidates who successfully converted to employees versus open applications?"
CREATE OR ALTER PROCEDURE dbo.usp_JobCandidatePipeline 
    @IsHired INT = NULL 
AS 
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CASE 
            WHEN BusinessEntityID IS NOT NULL THEN 'Hired / Internal Match'
            ELSE 'External Applicant Only'
        END AS CandidateStatus,
        COUNT(JobCandidateID) AS TotalApplicants
    FROM HumanResources.JobCandidate
    WHERE (@IsHired IS NULL 
           OR (@IsHired = 1 AND BusinessEntityID IS NOT NULL) 
           OR (@IsHired = 0 AND BusinessEntityID IS NULL))
    GROUP BY 
        CASE 
            WHEN BusinessEntityID IS NOT NULL THEN 'Hired / Internal Match'
            ELSE 'External Applicant Only'
        END;
END;
GO

EXEC dbo.usp_JobCandidatePipeline;          
EXEC dbo.usp_JobCandidatePipeline @IsHired = 0; 