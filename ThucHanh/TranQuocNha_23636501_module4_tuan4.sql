USE [AdventureWorks2008R2]
GO
--1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm 
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt 
--hàng” 
DECLARE @tongSoHD INT;
SELECT @tongSoHD = COUNT([SalesOrderID])
FROM [Production].[Product] JOIN [Sales].[SalesOrderDetail] ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
WHERE [Production].[Product].[ProductID] = 778

IF( @tongSoHD > 500)
	PRINT N'San pham 778 co tren 500 don hang'
ELSE
	PRINT N'San pham 778 co it don dat hang'
GO
--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách 
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008),   nếu 
--@n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008” 
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào 
--trong năm 2008” 
DECLARE @makh INT, @nam INT, @n INT;
SET @makh = 1;
SET @nam = 2008;
SELECT @n = COUNT([SalesOrderID])
FROM [Sales].[Customer] JOIN [Sales].[SalesOrderHeader] ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
WHERE YEAR([OrderDate]) = @nam

SET @n = ISNULL(@n, 0); -- DAM BAO n khong null

IF (@n > 0)
	PRINT N'Khach hang ' + CAST(@makh AS NVARCHAR(10)) + N' co ' + CAST(@n AS NVARCHAR(10))+ N' hoa don trong nam ' + CAST(@nam AS NVARCHAR(10))
ELSE 
	PRINT N'Khach hang ' + CAST(@makh AS NVARCHAR(10)) + N' khong co hoa don nao trong nam ' + CAST(@nam AS NVARCHAR(10))
--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng 
--tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như sau: 
-- Những hóa đơn có SubTotal<100000 thì không giảm, 
-- SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal 
-- SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal 
-- SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
SELECT [SalesOrderID], SubTotal=SUM([LineTotal]), 
CASE
	WHEN SUM([LineTotal]) < 100000 THEN 0
	WHEN SUM([LineTotal]) >= 100000 AND SUM([LineTotal]) < 120000 THEN SUM([LineTotal]) * 0.05
	WHEN SUM([LineTotal]) >= 120000 AND SUM([LineTotal]) < 150000 THEN SUM([LineTotal]) * 0.1
	WHEN SUM([LineTotal]) >= 150000 THEN SUM([LineTotal]) * 0.15
END AS Discount
FROM [Sales].[SalesOrderDetail]
GROUP BY [SalesOrderID]
HAVING SUM([LineTotal]) > 100000
GO
--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của 
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho 
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
--gán  giá  trị  tương  ứng  của  field  [OnOrderQty]  cho  biến  @soluongcc,  nếu 
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung 
--cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
--cung cấp sản phẩm 4 với số lượng là 5” 
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor]) 
DECLARE @mancc INT, @masp INT, @soluongcc INT;
SET @mancc = 1580;
SET @masp = 1;
SELECT  @soluongcc = [OnOrderQty]
FROM [Purchasing].[ProductVendor]
WHERE [ProductID] = @masp AND [BusinessEntityID] = @mancc

IF (@soluongcc IS NULL)
	PRINT N'Nha cung cap ' + CAST(@mancc AS NVARCHAR(10)) + N' khong cung cap san pham ' + CAST(@masp AS NVARCHAR(10))
ELSE
	SET @soluongcc = ISNULL(@soluongcc, 0);
	PRINT N'Nha cung cap ' + CAST(@mancc AS NVARCHAR(10)) + N' cung cap san pham ' + CAST(@masp AS NVARCHAR(10)) + N' voi so luong la ' + CAST(@soluongcc AS NVARCHAR(10))
GO
--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong 
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng. 
WHILE (SELECT SUM(Rate) FROM 
[HumanResources].[EmployeePayHistory])<6000 
BEGIN 
UPDATE [HumanResources].[EmployeePayHistory] 
SET Rate = Rate*1.1 
IF (SELECT MAX(Rate)FROM 
[HumanResources].[EmployeePayHistory]) > 150 
BREAK 
ELSE 
CONTINUE 
END 