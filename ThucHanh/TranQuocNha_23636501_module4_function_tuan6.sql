--TUAN 06 FUNCTION
use[AdventureWorks2008R2] 
GO
--4)  Viết hàm SumOfOrder  với hai tham số @thang và @nam trả về danh sách các 
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ    2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).

CREATE FUNCTION SumOfOrder(@thang INT, @nam INT)
RETURNS TABLE
AS 
	RETURN (SELECT OH.[SalesOrderID], [OrderDate], SubToTal = SUM([OrderQty] * [UnitPrice])
			FROM [Sales].[SalesOrderHeader] OH JOIN [Sales].[SalesOrderDetail] OD ON OH.SalesOrderID = OD.SalesOrderID
			WHERE @thang = MONTH([OrderDate]) AND  @nam = YEAR([OrderDate])
			GROUP BY OH.[SalesOrderID], [OrderDate]
			HAVING SUM([OrderQty] * [UnitPrice]) > 70000)
GO
----
SELECT *
FROM dbo.SumOfOrder(5,2007)
GO
--5)  Viết hàm tên  NewBonus  tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
--mức  thưởng  hiện  tại  tăng  thêm  1%  tổng  doanh  thu,  thông  tin  bao  gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--  SumOfSubTotal  =sum(SubTotal),
--  NewBonus = Bonus+ sum(SubTotal)*0.01
CREATE FUNCTION NewBonus ()
RETURNS TABLE
AS 
	RETURN(SELECT [SalesOrderID], SumOfSubTotal = SUM([SubTotal]), NewBonus = SUM([SubTotal]) * 0.01
			FROM [Sales].[SalesOrderHeader] 
			GROUP BY [SalesOrderID])
GO
---
SELECT *
FROM dbo.NewBonus()
GO
--6)  Viết  hàm  tên  SumOfProduct  với  tham  số  đầu  vào  là  @MaNCC  (VendorID),
---  20-hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
--của  các  sản  phẩm  do  nhà  cung  cấp  @MaNCC  cung  cấp,  thông  tin  gồm 
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
--và [Purchasing].[PurchaseOrderDetail])
CREATE FUNCTION SumOfProduct (@MaNCC INT)
RETURNS TABLE
AS
	RETURN(SELECT [ProductID], SumOfProduct = SUM([OrderQty]), SumOfSubTotal = SUM([SubTotal])
			FROM [Purchasing].[Vendor] JOIN [Purchasing].[PurchaseOrderHeader] ON Purchasing.Vendor.BusinessEntityID = Purchasing.PurchaseOrderHeader.VendorID
			JOIN [Purchasing].[PurchaseOrderDetail] ON  Purchasing.PurchaseOrderHeader.PurchaseOrderID = Purchasing.PurchaseOrderDetail.PurchaseOrderID
			WHERE @MaNCC = [BusinessEntityID]
			GROUP BY [ProductID])
GO
--
Select *
from dbo.SumOfProduct(1492)
GO
--7)  Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn  (SalesOrderID), 
--thông  tin gồm  SalesOrderID,  [SubTotal],  Discount;  trong  đó  Discount  được  tính 
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0 
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
CREATE FUNCTION Discount_Func()
RETURNS TABLE
AS
RETURN(SELECT [SalesOrderID], [SubTotal], 
	CASE
		WHEN [SubTotal] < 1000 THEN 0
		WHEN [SubTotal] >= 1000 AND [SubTotal] < 5000 THEN [SubTotal] * 0.05
		WHEN [SubTotal] >=5000 AND [SubTotal] < 10000 THEN [SubTotal] * 0.1
		WHEN [SubTotal] >= 10000 THEN [SubTotal] * 0.15
	END AS Discount
	FROM [Sales].[SalesOrderHeader])
GO
--8)  Viết hàm  TotalOfEmp  với tham số  @MonthOrder, @YearOrder để tính  tổng 
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được 
--truyền  vào  2  tham  số,  thông  tin  gồm  [SalesPersonID],  Total,  với 
--Total=Sum([SubTotal])
CREATE FUNCTION TotalOfEmp ( @MonthOrder INT, @YearOrder INT)
RETURNS TABLE
AS
	RETURN(SELECT [SalesOrderID], Total = SUM([SubTotal])
			FROM [Sales].[SalesOrderHeader]
			WHERE @MonthOrder = MONTH([OrderDate]) AND @YearOrder = YEAR([OrderDate])
			GROUP BY [SalesOrderID])
GO
--  Multi-statement Table Valued  Functions:
--9)  Viết lại các câu 5,6,7,8 bằng Multi-statement table valued  function
---cau 5
CREATE FUNCTION NewBonus ( @SalepersonID INT)
RETURNS @newbonus TABLE(
	SalesOrderID INT,
	SumOfSubTotal FLOAT,
	NewBonus FLOAT
)
AS 
BEGIN
	INSERT INTO @newbonus
	SELECT [SalesOrderID], SumOfSubTotal = SUM([SubTotal]), NewBonus = SUM([SubTotal]) * 0.01
	FROM [Sales].[SalesOrderHeader] 
	WHERE @SalepersonID = [SalesPersonID]
	GROUP BY [SalesOrderID];

	RETURN;
END;
GO
---cau 6
CREATE FUNCTION SumOfProduct (@MaNCC INT)
RETURNS @sumofproduct TABLE(
	ProductID INT,
	SumOfProduct INT,
	SumOfSubTotal INT
)
AS
BEGIN
	INSERT INTO @sumofproduct
	SELECT [ProductID], SumOfProduct = SUM([OrderQty]), SumOfSubTotal = SUM([SubTotal])
			FROM [Purchasing].[Vendor] JOIN [Purchasing].[PurchaseOrderHeader] ON Purchasing.Vendor.BusinessEntityID = Purchasing.PurchaseOrderHeader.VendorID
			JOIN [Purchasing].[PurchaseOrderDetail] ON  Purchasing.PurchaseOrderHeader.PurchaseOrderID = Purchasing.PurchaseOrderDetail.PurchaseOrderID
			WHERE @MaNCC = [BusinessEntityID]
			GROUP BY [ProductID]

	RETURN;
END;
GO
--cau 7
CREATE FUNCTION Discount_Func()
RETURNS @result TABLE (
    SalesOrderID INT,
    SubTotal FLOAT,
    Discount FLOAT
)
AS
BEGIN
    INSERT INTO @result
    SELECT SalesOrderID, SubTotal, 
        CASE
            WHEN SubTotal < 1000 THEN 0
            WHEN SubTotal >= 1000 AND SubTotal < 5000 THEN SubTotal * 0.05
            WHEN SubTotal >= 5000 AND SubTotal < 10000 THEN SubTotal * 0.1
            WHEN SubTotal >= 10000 THEN SubTotal * 0.15
        END AS Discount
    FROM Sales.SalesOrderHeader;

    RETURN;
END;
GO
---cau 8
CREATE FUNCTION TotalOfEmp ( @MonthOrder INT, @YearOrder INT)
RETURNS @cau8 TABLE(
	SalesOrderID INT,
	Total INT
)
AS
BEGIN
		INSERT INTO @cau8
		SELECT [SalesOrderID], Total = SUM([SubTotal])
		FROM [Sales].[SalesOrderHeader]
		WHERE @MonthOrder = MONTH([OrderDate]) AND @YearOrder = YEAR([OrderDate])
		GROUP BY [SalesOrderID];

		RETURN;
END;
GO
--10)  Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham 
--số  vào  là  @MaNV  (giá  trị  của  [BusinessEntityID]),  thông  tin  gồm 
--BusinessEntityID, FName, LName, Salary (giá trị của cột  Rate).
--  Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết 
--quả là bảng lương của nhân viên  đó.
CREATE FUNCTION SalaryOfEmp (@maNV INT)
RETURNS TABLE
AS
	RETURN (SELECT [HumanResources].[EmployeePayHistory].[BusinessEntityID], FName = [FirstName], LName = [LastName], Salary = [Rate]
			FROM [HumanResources].[EmployeePayHistory] JOIN [HumanResources].[Employee] ON HumanResources.Employee.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
			JOIN [Person].[Person] ON  HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
			WHERE @maNV = [HumanResources].[EmployeePayHistory].[BusinessEntityID])
GO