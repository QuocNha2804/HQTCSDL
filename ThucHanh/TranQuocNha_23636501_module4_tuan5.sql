--1)  Viết  một  thủ  tục  tính  tổng  tiền  thu  (TotalDue)  của  mỗi  khách  hàng  trong  một 
--tháng bất kỳ của  một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, 
--thông tin gồm: CustomerID, SumOfTotalDue  =Sum(TotalDue)
USE [AdventureWorks2008R2]
GO
----
CREATE PROC C_TotalDue @YEAR INT, @MONTH INT
AS
BEGIN
	SELECT [CustomerID], YEARS = YEAR([OrderDate]), MONTHS = MONTH([OrderDate]), SumOfTotalDue = SUM([TotalDue])
	FROM [Sales].[SalesOrderHeader]
	GROUP BY [CustomerID], YEAR([OrderDate]),MONTH([OrderDate])
	HAVING  YEAR([OrderDate]) = @YEAR AND MONTH([OrderDate]) = @MONTH
END;
GO
---
EXEC C_TotalDue 2005,7
GO

--2)  Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của 
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số 
--@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.
SELECT *
FROM [Sales].[SalesOrderHeader]
WHERE YEAR([OrderDate]) = 2008
GO
--3)  Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có 
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice). 
SELECT [ProductID], [ListPrice]
	FROM [Production].[Product]
	GO
	--WHERE [ListPrice] < @MaxPrice
--
CREATE PROC P_List  @MaxPrice INT 
AS
BEGIN
	SELECT [ProductID], [ListPrice]
	FROM [Production].[Product]
	WHERE [ListPrice] < @MaxPrice
	ORDER BY [ListPrice] DESC
END;
GO
--

--
EXEC  P_List 7000000.0
GO
--4)  Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán 
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên  đó. Mức thưởng mới 
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó: 
--SumOfSubTotal =sum(SubTotal) 
--NewBonus = Bonus+ sum(SubTotal)*0.01 

--BONUS


--
CREATE PROC NewBonus @SalePersonID INT
AS
BEGIN
	IF NOT EXISTS (SELECT [BusinessEntityID] FROM [Sales].[SalesPerson] WHERE [BusinessEntityID] = @SalePersonID)
	BEGIN 
		PRINT N'Nhan vien khong ton tai'
		RETURN -1;
	END
	UPDATE [Sales].[SalesPerson]
	SET [Bonus] = [Bonus] + (SELECT SUM([SubTotal])*0.01
							FROM [Sales].[SalesOrderHeader]
							GROUP BY [SalesPersonID]
							HAVING [SalesPersonID] = @SalePersonID)
	RETURN 0;
END;
GO
	
--5)  Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng 
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)
CREATE PROC ProductCategory @Year INT
AS
BEGIN 
	SELECT TOP 1 [Production].[ProductCategory].[ProductCategoryID], [Production].[ProductCategory].[Name], SumOfQty = SUM([OrderQty])
	FROM [Production].[ProductCategory]
	JOIN [Production].[ProductSubcategory] ON Production.ProductCategory.ProductCategoryID =Production.ProductSubcategory.ProductCategoryID
	JOIN [Production].[Product] ON Production.ProductSubcategory.ProductSubcategoryID =Production.Product.ProductSubcategoryID
	JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderDetail.ProductID =Production.Product.ProductID
	--WHERE YEAR([Production].[ProductCategory].[ModifiedDate])
	GROUP BY  [Production].[ProductCategory].[ProductCategoryID], [Production].[ProductCategory].[Name]
	ORDER BY  SUM([OrderQty]) DESC
END;
GO
---
EXEC ProductCategory 2001
GO
---
--6)  Tạo thủ tục đặt tên là TongThu  có tham số vào là mã nhân viên, tham số đầu ra 
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả 
--về trạng thái thành công hay thất bại của thủ  tục.
CREATE PROC TongThu @MaNhanVien NVARCHAR(10), @tongTriGia INT OUTPUT
AS
BEGIN
	SET @tongTriGia =0
	IF NOT EXISTS(SELECT TOP 1* FROM [Sales].[Customer] WHERE [PersonID] = @MaNhanVien)
	BEGIN
		PRINT N'Nhan vien khong ton tai'
		RETURN -1;		
	END
	SELECT @tongTriGia = SUM([UnitPrice])
	FROM [Sales].[Customer] JOIN [Sales].[SalesOrderHeader] ON  Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID JOIN [Sales].[SalesOrderDetail] ON  Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID

	IF (@tongTriGia IS NULL)
	BEGIN
		SET @tongTriGia =0
	END
	PRINT N'Thuc hien thanh cong'
END;
GO
--


--7)  Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
--năm đã cho.
CREATE PROC cuaHang @nam INT
AS
BEGIN
SELECT [Name], SoTien = SUM()
FROM [Sales].[Store] JOIN [Sales].[Customer] ON  Sales.Store.BusinessEntityID = Sales.Customer.StoreID JOIN [Sales].[SalesOrderHeader] ON  Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
WHERE YEAR([OrderDate]) = @nam
END;
GO

--8)  Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin 
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not 
--null và các field là khóa  ngoại.
CREATE PROC Sp_InsertProduct @ProductID INT, @name NVARCHAR(50), @ProductModelID INT
AS
BEGIN
	INSERT INTO [Production].[Product] ([ProductID],[Name] , [ProductModelID])
	VALUES(@ProductID,  @name,  @ProductModelID)
END;
GO
--9)  Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader 
--khi  biết  SalesOrderID.  Lưu  ý  :  trước  khi  xóa  mẫu  tin  trong 
--Sales.SalesOrderHeader  thì  phải  xóa  các  mẫu  tin  của  hoá  đơn  đó  trong 
--Sales.SalesOrderDetail. 
CREATE PROC XoaHD @SO_ID INT
AS
BEGIN
	IF NOT EXISTS (SELECT [SalesOrderID] FROM [Sales].[SalesOrderHeader] WHERE [SalesOrderID] = @SO_ID)
	BEGIN
		PRINT N'Hoa don khong ton tai'
		RETURN -1;
	END
	DELETE [Sales].[SalesOrderDetail]
	WHERE [SalesOrderID] = @SO_ID

	DELETE [Sales].[SalesOrderHeader]
	WHERE [SalesOrderID] = @SO_ID

	PRINT N'Xoa thanh cong'
	RETURN 0;
END;
GO

--10)  Viết  thủ  tục  Sp_Update_Product  có  tham  số  ProductId  dùng  để  tăng  listprice
--lên 10%  nếu  sản phẩm này tồn  tại,  ngược  lại  hiện  thông  báo  không  có  sản  phẩm
--này.
CREATE PROC Sp_Update_Product @ProductID INT
AS
BEGIN
	IF EXISTS(SELECT [ProductID] FROM [Production].[Product] WHERE [ProductID] = @ProductID)
	BEGIN
		UPDATE [Production].[Product]
		SET [ListPrice] = [ListPrice] * 1.1
		PRINT N'Tang thanh cong'
	END
	ELSE
	BEGIN
		PRINT N'Khong co san pham nay'
	END
END;
GO