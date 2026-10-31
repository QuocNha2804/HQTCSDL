--1)  Tạo  view  dbo.vw_Products  hiển  thị  danh  sách  các  sản  phẩm  từ  bảng 
--Production.Product và bảng  Production.ProductCostHistory. Thông tin  bao gồm 
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
USE [AdventureWorks2008R2]
--
CREATE VIEW Products_View
AS
SELECT Production.Product.ProductID, Production.Product.Name, Color, Size, Style, Production.Product.StandardCost, EndDate, StartDate
FROM [Production].[Product] JOIN [Production].[ProductCostHistory] ON Production.ProductCostHistory.ProductID = Production.Product.ProductID



--2)  Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt 
--hàng trong quí 1 năm 2008  và có tổng trị giá >10000, thông tin gồm ProductID, 
--Product_Name, CountOfOrderID và SubTotal.

CREATE VIEW List_Products_View
AS
SELECT ProductID, Name, CountOfOrderID = COUNT(ProductID), SubTotal = SUM([ListPrice])
FROM [Production].[Product]
WHERE MONTH([SellStartDate]) IN (7,2,3) AND YEAR([SellStartDate])=2008
GROUP BY ProductID, Name
HAVING SUM([ListPrice]) > 10000

--3)  Tạo view dbo.vw_CustomerTotals  hiển thị tổng tiền bán được (total sales) từ cột 
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm 
--CustomerID,  YEAR(OrderDate)  AS  OrderYear,  MONTH(OrderDate)  AS 
--OrderMonth,  SUM(TotalDue).
CREATE VIEW CustomerTotals_View
AS
SELECT [Sales].[Customer].CustomerID,  YEAR(OrderDate)  AS  OrderYear,  MONTH(OrderDate)  AS OrderMonth,  SUM(TotalDue) AS TotalDue
FROM [Sales].[Customer] JOIN [Sales].[SalesOrderHeader] ON Sales.Customer.CustomerID =
Sales.SalesOrderHeader.CustomerID
GROUP BY [Sales].[Customer].CustomerID,YEAR(OrderDate),MONTH(OrderDate)
--4)  Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân 
--viên  theo  từng  năm.  Thông  tin gồm  SalesPersonID,  OrderYear,  sumOfOrderQty
CREATE VIEW Toltal_Quantity_View
AS 
SELECT SalesPersonID,  YEAR([Sales].[SalesOrderHeader].OrderDate) AS OrderYear,  sumOfOrderQty = SUM([OrderQty])
FROM [Sales].[Customer] JOIN [Sales].[SalesOrderHeader] ON Sales.Customer.CustomerID =Sales.SalesOrderHeader.CustomerID JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderHeader.SalesOrderID= Sales.SalesOrderDetail.SalesOrderId
GROUP BY SalesPersonID,  YEAR([Sales].[SalesOrderHeader].OrderDate)

SELECT* FROM [dbo].Toltal_Quantity_View
--5)  Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn 
--đặt hàng từ năm 2007 đến 2008, thông tin  gồm  mã khách (PersonID) , họ tên 
--(FirstName +'  '+ LastName as FullName), Số hóa đơn  (CountOfOrders).
CREATE VIEW ListCustomer_View 
AS
SELECT PersonID, HoTen = [FirstName] +' '+[LastName], CountofOrder= COUNT(*)
FROM [Person].[Person] JOIN [Sales].[Customer] ON Sales.Customer.PersonID =Person.Person.BusinessEntityID JOIN [Sales].[SalesOrderHeader] ON Sales.Customer.CustomerID =Sales.SalesOrderHeader.CustomerID JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderHeader.SalesOrderID= Sales.SalesOrderDetail.SalesOrderID
WHERE YEAR([OrderDate]) between 2007 and 2008
GROUP BY PersonID, [FirstName] +' '+[LastName]
HAVING COUNT(*) >25
--6)  Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với 
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên  50 sản phẩm, thông 
--tin  gồm  ProductID,  Name,  SumOfOrderQty,  Year.  (dữ  liệu  lấy  từ  các  bảng
--Sales.SalesOrderHeader,          Sales.SalesOrderDetail,          và
--Production.Product)
CREATE VIEW ListProduct_view
AS
SELECT [Production].[Product].[ProductID],[Name] , SumOfQty = SUM([OrderQty]), nam = YEAR([OrderDate])
FROM [Sales].[SalesOrderHeader] JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID JOIN [Production].[Product] ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
WHERE [Name] LIKE 'Bike%' OR [Name] LIKE 'Sport%'
GROUP BY [Production].[Product].[ProductID],[Name], YEAR([OrderDate])
HAVING SUM([OrderQty]) > 50
--7)  Tạo view List_department_View chứa  danh sách  các  phòng  ban  có lương  (Rate: 
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID), 
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng 
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
CREATE VIEW List_department
AS
SELECT [HumanResources].[Department].[DepartmentID], [Name], AvgOfRate = AVG([Rate])
FROM [HumanResources].[Department] JOIN [HumanResources].[EmployeeDepartmentHistory] ON HumanResources.Department.DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID JOIN [HumanResources].[Employee] ON  HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID JOIN [HumanResources].[EmployeePayHistory] ON  HumanResources.Employee.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
GROUP BY [HumanResources].[Department].[DepartmentID], [Name]
HAVING AVG([Rate]) > 30
--8)  Tạo view  Sales.vw_OrderSummary  với từ khóa  WITH ENCRYPTION gồm 
--OrderYear  (năm  của  ngày  lập),  OrderMonth  (tháng  của  ngày  lập),  OrderTotal 
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view  này
CREATE VIEW OrderSummary_view
WITH ENCRYPTION
AS
SELECT OrderYear = YEAR([OrderDate]), OrderMonth = MONTH([OrderDate]), OrderToTal = SUM([OrderQty] * [UnitPrice])
FROM [Sales].[SalesOrderHeader] JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
GROUP BY YEAR([OrderDate]),MONTH([OrderDate])
--9)  Tạo  view  Production.vwProducts  với  từ  khóa  WITH  SCHEMABINDING 
--gồm ProductID, Name, StartDate,EndDate,ListPrice  của  bảng Product và bảng 
--ProductCostHistory.  Xem  thông  tin  của  View.  Xóa  cột  ListPrice  của  bảng 
--Product. Có xóa được không? Vì sao?
CREATE VIEW Production.vwProducts
WITH SCHEMABINDING
AS
SELECT [Production].[Product].[ProductID], [Name], [StartDate], [EndDate], [ListPrice]
FROM [Production].[Product] JOIN [Production].[ProductCostHistory] ON Production.Product.ProductID = Production.ProductCostHistory.ProductID
---
SELECT *
FROM  Production.vwProducts
--Khoông xóa được vì đang sủ dụng SCHEMABINDING, View đang phụ thuộc vào cột ListPrice, nếutrước muốn xóa thì phải xóa view trước 

--10) Tạo  view  view_Department  với  từ  khóa  WITH  CHECK  OPTION  chỉ  chứa  các 
--phòng  thuộc  nhóm  có  tên  (GroupName)  là  “Manufacturing”  và  “Quality 
--Assurance”, thông tin gồm: DepartmentID, Name,  GroupName.
--a.  Chèn thêm một phòng ban mới thuộc nhóm không  thuộc hai nhóm 
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có 
--chèn được không? Giải thích.
--b.  Chèn  thêm  một  phòng  mới  thuộc  nhóm  “Manufacturing”  và  một 
--phòng thuộc nhóm “Quality  Assurance”.
--c.  Dùng câu lệnh Select xem kết quả trong bảng  Department.
CREATE VIEW view_Department
AS
SELECT [DepartmentID], [Name], [GroupName]
FROM [HumanResources].[Department]
WHERE [GroupName] IN ('Manufacturing','“Quality Assurance')
WITH CHECK OPTION
---a
INSERT INTO view_Department ([Name], [GroupName])
VALUES ('Nhan su','a')
--Không chèn được do đang sủ dụng WITH CHECK OPTION, nó kiểm tra điều kiện WHERE trước khi chèn dữ liệu mới váo 
--b
INSERT INTO view_Department ([Name], [GroupName])
VALUES ('Nhan su','Manufacturing')
--Chèn được vì Manufacturing nằm trong CHECK WITH OPTION
--c
SELECT *
FROM [HumanResources].[Department]