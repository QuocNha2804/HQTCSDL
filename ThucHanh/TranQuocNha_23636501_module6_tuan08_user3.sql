USE [AdventureWorks2008R2]
GO
SELECT*
FROM [Sales].[SalesOrderHeader]
GO
--b)  Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của  nhân 
--viên có BusinessEntityID=1
UPDATE [HumanResources].[Employee]
SET [JobTitle] = 'Sale Manager'
WHERE [BusinessEntityID] = 1