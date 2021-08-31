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
	Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
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
	