--I) Câu lệnh SELECT sử dụng các hàm thống kê với các mệnh đề Group by và 
--Having: 
USE AdventureWorks2008R2
--1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có 
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó 
--SubTotal =SUM(OrderQty*UnitPrice). 
SELECT OD.[SalesOrderID], [OrderDate], Sumtotal = SUM([UnitPrice] * [OrderQty])
FROM [Sales].[SalesOrderHeader] OH JOIN [Sales].[SalesOrderDetail] OD ON OH.[SalesOrderID] = OD.[SalesOrderID]
WHERE MONTH([OrderDate]) = 6 AND YEAR([OrderDate]) = 2008
GROUP BY OD.[SalesOrderID], [OrderDate]
HAVING SUM([UnitPrice] * [OrderQty]) > 70000
--2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia 
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory, 
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin 
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền 
--(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice) 
SELECT [Sales].[SalesTerritory].[TerritoryID], CountofCust = COUNT([Sales].[Customer].[CustomerID]), SubTotal = SUM([UnitPrice]*[OrderQty])
FROM [Sales].[Customer] JOIN [Sales].[SalesTerritory] ON Sales.Customer.TerritoryID = Sales.SalesTerritory.TerritoryID JOIN [Sales].[SalesOrderHeader] ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
WHERE [CountryRegionCode] = N'US'
GROUP BY [Sales].[SalesTerritory].[TerritoryID]
--3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng 
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm 
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice) 
SELECT [SalesOrderID], [CarrierTrackingNumber], SubTotal = SUM([OrderQty]*[UnitPrice])
FROM [Sales].[SalesOrderDetail]
WHERE [CarrierTrackingNumber] LIKE '4BD%'
GROUP BY [SalesOrderID], [CarrierTrackingNumber]
--4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán 
--trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
 SELECT [Production].[Product].[ProductID], [Name], AverageOfQty = AVG([OrderQty])
 FROM [Sales].[SalesOrderDetail] JOIN [Production].[Product] ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
 WHERE [UnitPrice]<25
 GROUP BY  [Production].[Product].[ProductID], [Name]
 HAVING AVG([OrderQty]) >5
--5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm 
--JobTitle, CountOfPerson=Count(*) 
SELECT [JobTitle], CountOfPerson = COUNT(*)
FROM [HumanResources].[Employee]
GROUP BY [JobTitle]
HAVING COUNT(*) > 20
--6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên 
--kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm 
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal 
--(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và 
--[Purchasing].[PurchaseOrderDetail]) 
SELECT [BusinessEntityID], Vendor_Name = [Name], [ProductID], SumOfQty = SUM([OrderQty]),[SubTotal]
FROM [Purchasing].[Vendor] JOIN [Purchasing].[PurchaseOrderHeader] ON Purchasing.Vendor.BusinessEntityID = Purchasing.PurchaseOrderHeader.VendorID JOIN [Purchasing].[PurchaseOrderDetail] ON Purchasing.PurchaseOrderHeader.PurchaseOrderID = Purchasing.PurchaseOrderDetail.PurchaseOrderID
WHERE [Name] LIKE '%Bicycles'
GROUP BY [BusinessEntityID], [Name], [ProductID],[SubTotal]
HAVING SUM([OrderQty]) > 800000
--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng 
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và 
--SubTotal 
SELECT [Production].[Product].[ProductID], Product_Name = [Name], CountOfOrderID = COUNT([Sales].[SalesOrderDetail].[SalesOrderID])
FROM [Sales].[SalesOrderDetail] JOIN [Production].[Product] ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID JOIN [Sales].[SalesOrderHeader] ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE YEAR([OrderDate]) = 2008 AND DATEPART(q,[OrderDate]) =1
GROUP BY [Production].[Product].[ProductID], [Name]
HAVING COUNT([Sales].[SalesOrderDetail].[SalesOrderID]) > 500
--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +'   '+ LastName 
--as FullName), Số hóa đơn (CountOfOrders). 
SELECT [PersonID], fullName = [FirstName] +' '+ [LastName], CountOfOrder = COUNT([SalesOrderID])
FROM [Sales].[Customer] JOIN [Person].[Person] ON  Sales.Customer.PersonID = Person.Person.BusinessEntityID JOIN [Sales].[SalesOrderHeader] ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
WHERE YEAR([OrderDate]) IN (2007,2008)
GROUP BY [PersonID],[FirstName] +' '+ [LastName]
HAVING COUNT([SalesOrderID]) > 25
--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng 
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name, 
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader, 
--Sales.SalesOrderDetail  và Production.Product) 
SELECT [Production].[Product].[ProductID], [Name], CountOfOrderQty = SUM([OrderQty]), nam = YEAR([Sales].[SalesOrderHeader].[OrderDate])
FROM [Sales].[SalesOrderHeader] JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID JOIN [Production].[Product] ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
WHERE [Name] LIKE 'Bike%' OR [Name] LIKE 'Sport%'
GROUP BY [Production].[Product].[ProductID], [Name],YEAR([Sales].[SalesOrderHeader].[OrderDate])
HAVING SUM([OrderQty])>500
--10) Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông 
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung 
--bình (AvgofRate). Dữ liệu từ các bảng
-- [HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory]. 

SELECT [HumanResources].[Department].[DepartmentID], [Name], AvgofRate = AVG([Rate])
FROM [HumanResources].[Department] JOIN [HumanResources].[EmployeeDepartmentHistory] ON HumanResources.Department.DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID JOIN [HumanResources].[Employee] ON  HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID JOIN [HumanResources].[EmployeePayHistory] ON  HumanResources.Employee.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
GROUP BY [HumanResources].[Department].[DepartmentID], [Name]
HAVING AVG([Rate]) > 30