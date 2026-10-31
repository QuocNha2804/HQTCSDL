----TUAN 05 FUNCTOIN

use[AdventureWorks2008R2] 
GO
----
--1)  Viết hàm tên  CountOfEmployees  (dạng scalar function) với tham số @mapb, 
--giá  trị  truyền  vào  lấy  từ  field  [DepartmentID],  hàm  trả  về  số  nhân  viên  trong 
--phòng ban  tương  ứng. Áp  dụng hàm  đã viết  vào câu truy  vấn  liệt kê danh  sách các
--phòng ban với  số nhân viên  của  mỗi phòng ban, thông  tin gồm: [DepartmentID],
--Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--(Dữ liệu lấy từ bảng 
--[HumanResources].[EmployeeDepartmentHistory] và 
--[HumanResources].[Department])
ALTER FUNCTION CountOfEmployees (@mapb int )
RETURNS INT
AS
BEGIN
	DECLARE @n int
	SELECT   @n = COUNT(*)
	FROM [HumanResources].[Department] JOIN [HumanResources].[EmployeeDepartmentHistory] ON HumanResources.Department.DepartmentID =HumanResources.EmployeeDepartmentHistory.DepartmentID
	WHERE @mapb = [HumanResources].[Department].[DepartmentID]
	GROUP BY [HumanResources].[Department].[DepartmentID]
	RETURN @n
END;
GO
---

SELECT [DepartmentID], [Name], countOfEmp= dbo.CountOfEmployees([DepartmentID])
FROM [HumanResources].[Department]
ORDER BY countOfEmp DESC
GO
--2)  Viết  hàm  tên  là  InventoryProd  (dạng  scalar  function)  với  tham  số  vào  là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu 
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])

CREATE FUNCTION InventoryProd (@ProductID int, @LocationID int)
RETURNS INT
AS
BEGIN
	DECLARE @sLTon int
	SELECT @sLTon = SUM([Quantity])
	FROM [Production].[ProductInventory]
	WHERE [ProductID] = @ProductID AND [LocationID] = @LocationID
	GROUP BY [ProductID]
	RETURN @sLTon
END;
---
PRINT CONCAT(N'So luong ton cua ProductID 1 va LocationID 1 la ', dbo.InventoryProd(1,1))
GO
--3)  Viết hàm tên SubTotalOfEmp  (dạng scalar function) trả về tổng doanh thu của 
--một  nhân  v[ProductID]iên  trong  một  tháng  tùy  ý  trong  một  năm  tùy  ý,  với  tham  số  vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
CREATE FUNCTION SubTotalOfEmp (@EmplID INT, @MonthOrder INT, @YearOrder INT)
RETURNS INT
AS
BEGIN
	DECLARE @doanhThu INT
	SELECT @doanhThu = SUM([TotalDue])
	FROM [Sales].[SalesOrderHeader]
	WHERE @EmplID = [SalesPersonID] AND @MonthOrder = MONTH([OrderDate]) AND @YearOrder = YEAR([OrderDate])
	GROUP BY [SalesPersonID]
	RETURN @doanhThu
END;
--
PRINT CONCAT(N'Tong doanh thu cua nhan vien 279 trong thang 7 nam 2005 la: ',dbo.SubTotalOfEmp(279,07,2005))
GO