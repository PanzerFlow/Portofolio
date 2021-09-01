/*
AdventureWorks Data Warehouse 2017 Exploration

Data Source:
	AdventureWorksDW2017 is a Sample Database provided by Microsoft 
	Adventure Works Cycles the fictitious company on which the AdventureWorks sample databases are based, is a large, multinational manufacturing company. 
	The company manufactures and sells metal and composite bicycles to North American, European and Asian commercial markets.
	Link to download the .bak file can be found below
		https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2017.bak
	Data Dictionary 
Skills used: 
	Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions
Supporting Material used: 
	Data Dictionary - https://dataedo.com/samples/html/Data_warehouse/doc/AdventureWorksDW_4/home.html

*/

--Restoring the database using the .bak file from the link above
USE [master]
RESTORE DATABASE [AdventureWorksDW2017] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\Backup\AdventureWorksDW2017.bak' WITH  FILE = 1
,  MOVE N'AdventureWorksDW2017' TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\AdventureWorksDW2017.mdf'
,  MOVE N'AdventureWorksDW2017_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\AdventureWorksDW2017_log.ldf',  NOUNLOAD,  STATS = 5

GO

---- Select Data that we are going to be starting with
SELECT TOP 100 *
FROM [AdventureWorksDW2017].[dbo].[FactInternetSales]


-- Total Sales Per Product (Bicycles)
-- Show amount of revenue each product genreates
-- Single Join, Aggregate Functions
SELECT 
	DP.EnglishProductName
	,DP.EnglishDescription
	,SUM(FIS.SalesAmount) AS TotalSalesAmount
	,COUNT(FIS.SalesAmount) AS TotalItemSolde
FROM [AdventureWorksDW2017].[dbo].[FactInternetSales] AS FIS
INNER JOIN [AdventureWorksDW2017].[dbo].DimProduct AS DP
ON FIS.ProductKey = DP.ProductKey
GROUP BY 
	DP.EnglishProductName
	,DP.EnglishDescription
ORDER BY SUM(FIS.SalesAmount) DESC


-- Total Sales Per Region 
-- Show amount of revenue attributed to each region (Customer Region)
-- Multi Joins, Aggregate Functions
SELECT 
	DG.[City]
	,DG.[StateProvinceName]
	,DG.[EnglishCountryRegionName]
	,SUM(FIS.SalesAmount) AS TotalSalesAmount
FROM [AdventureWorksDW2017].[dbo].[FactInternetSales] AS FIS
INNER JOIN [AdventureWorksDW2017].[dbo].DimCustomer AS DC
ON FIS.CustomerKey = DC.CustomerKey
INNER JOIN [AdventureWorksDW2017].[dbo].DimGeography AS DG
ON DC.GeographyKey = DG.GeographyKey
GROUP BY
	DG.[City]
	,DG.[StateProvinceName]
	,DG.[EnglishCountryRegionName]
ORDER BY
	SUM(FIS.SalesAmount) DESC

--% of Sales from Promotion Events
--CTE and Case Statement
;WITH CTE AS
	(SELECT 
		FIS.PromotionKey
		,DP.EnglishPromotionName
		,DP.EnglishPromotionType
		,SUM(FIS.SalesAmount) AS SalesAmount
	FROM [AdventureWorksDW2017].[dbo].[FactInternetSales] AS FIS
	LEFT OUTER JOIN [AdventureWorksDW2017].[dbo].DimPromotion AS DP
	ON FIS.PromotionKey = DP.PromotionKey
	GROUP BY 
		FIS.PromotionKey
		,DP.EnglishPromotionName
		,DP.EnglishPromotionType)

SELECT 
	CAST(
		SUM(CASE WHEN EnglishPromotionName <> 'No Discount' THEN SalesAmount END ) /SUM(SalesAmount) *100
		AS decimal(5,2)) AS PercentSalesFromPromotion
FROM CTE 


--Same as above but using tempoary table
--Temp Tables 
IF OBJECT_ID(N'tempdb..#SalesByPromo') IS NOT NULL BEGIN DROP TABLE #SalesByPromo END

SELECT 
	FIS.PromotionKey
	,DP.EnglishPromotionName
	,DP.EnglishPromotionType
	,SUM(FIS.SalesAmount) AS SalesAmount
INTO #SalesByPromo --Createing temp table on the fly
FROM [AdventureWorksDW2017].[dbo].[FactInternetSales] AS FIS
LEFT OUTER JOIN [AdventureWorksDW2017].[dbo].DimPromotion AS DP
ON FIS.PromotionKey = DP.PromotionKey
GROUP BY 
	FIS.PromotionKey
	,DP.EnglishPromotionName
	,DP.EnglishPromotionType

SELECT 
	CAST(
		SUM(CASE WHEN EnglishPromotionName <> 'No Discount' THEN SalesAmount END ) /SUM(SalesAmount) *100
		AS decimal(5,2)) AS PercentSalesFromPromotion
FROM #SalesByPromo 

--Daily Sales from Internet with a Running Total
--Windows Functions and CTE
;WITH DailySalesTable AS
	(SELECT 
	OrderDate
	,SUM(FIS.SalesAmount) AS DailySales
	FROM [AdventureWorksDW2017].[dbo].[FactInternetSales] AS FIS
	INNER JOIN AdventureWorksDW2017.dbo.DimDate AS DD
	ON FIS.OrderDateKey = DD.DateKey
	GROUP BY 
	OrderDate)

SELECT 
OrderDate
,SUM(DailySales) OVER (ORDER BY OrderDate) AS CumulativeSales 
FROM DailySalesTable
