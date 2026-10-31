USE [AdventureWorks2008R2]
GO
----
--Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau: 
--create table  M_Department
--(
--DepartmentID int not null primary key, 
--Name nvarchar(50),
--GroupName nvarchar(50)
--)
CREATE TABLE  M_Department
(
DepartmentID INT NOT NULL PRIMARY KEY, 
Name NVARCHAR(50),
GroupName NVARCHAR(50)
)
----create table M_Employees 
--(
--EmployeeID int not null primary key, 
--Firstname nvarchar(50),
--MiddleName nvarchar(50), 
--LastName nvarchar(50),
--DepartmentID int foreign key references M_Department(DepartmentID)
--)

CREATE TABLE M_Employees 
(
EmployeeID INT NOT NULL PRIMARY KEY, 
Firstname NVARCHAR(50),
MiddleName NVARCHAR(50), 
LastName NVARCHAR(50),
DepartmentID INT FOREIGN KEY REFERENCES M_Department(DepartmentID)
)
GO;
--  Tạo  một  view  tên  EmpDepart_View  bao  gồm  các  field:  EmployeeID,
--FirstName,  MiddleName,  LastName,  DepartmentID,  Name,  GroupName,  dựa 
--trên 2 bảng M_Employees và  M_Department.
CREATE VIEW EmpDepart_View
AS
	SELECT [EmployeeID], [Firstname], [MiddleName], [LastName], E.[DepartmentID], [Name], [GroupName]
	FROM [dbo].[M_Employees] E JOIN [dbo].[M_Department] D ON E.DepartmentID = D.DepartmentID

GO;
--  Tạo  một  trigger  tên  InsteadOf_Trigger  thực  hiện  trên  view
--EmpDepart_View,  dùng  để  chèn  dữ  liệu  vào  các  bảng  M_Employees  và 
--M_Department khi chèn một record mới thông qua view EmpDepart_View.
CREATE TRIGGER InsteadOf_Trigger
ON [dbo].[EmpDepart_View]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Chèn dữ liệu vào bảng M_Department nếu chưa tồn tại
    INSERT INTO M_Department (DepartmentID, Name, GroupName)
    SELECT DISTINCT i.DepartmentID, i.Name, i.GroupName
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1 FROM M_Department d WHERE d.DepartmentID = i.DepartmentID
    );
	---kiem tra neu department id da ton tai thi khong chen, tra ve true false

    -- Chèn dữ liệu vào bảng M_Employees
    INSERT INTO M_Employees (EmployeeID, Firstname, MiddleName, LastName, DepartmentID)
    SELECT i.EmployeeID, i.Firstname, i.MiddleName, i.LastName, i.DepartmentID
    FROM inserted i;
END;
--------

INSERT INTO [dbo].[EmpDepart_View] (EmployeeID, Firstname, MiddleName, LastName, DepartmentID, Name, GroupName)
VALUES 
(1, 'Tran', 'Quoc', 'Nha', 11, 'Marketing', 'Sales'),
(2, 'Do', 'Minh', 'Quan', 12, 'Finance', 'Accounting');

-- Kiểm tra dữ liệu đã chèn
SELECT * FROM [dbo].[EmpDepart_View];
SELECT * FROM [dbo].[M_Department];
SELECT * FROM [dbo].[M_Employees];
--2.  Tạo một trigger thực hiện trên bảng  MSalesOrders có chức năng thiết lập độ ưu 
--tiên của  khách hàng (CustPriority) khi người dùng thực hiện các thao tác  Insert, 
--Update và Delete trên bảng MSalesOrders theo điều kiện như  sau:
--  Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của 
--khách hàng (CustPriority) là 3
--  Nếu tổng tiền  Sum(SubTotal)  của khách hàng từ 10,000 $ đến dưới 50000  $ 
--thì độ ưu tiên của khách hàng (CustPriority) là  2
--  Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000  $ trở lên thì độ ưu tiên 
--của khách hàng (CustPriority) là 1
--Các bước thực hiện:
--  Tạo bảng MCustomers và MSalesOrders theo cấu trúc 
--sau: create table  MCustomer
--(
--CustomerID int not null primary key, 
--CustPriority int 
--)
--create table MSalesOrders 
--(
--SalesOrderID int not null primary key, 
--OrderDate date,
--SubTotal money,
--CustomerID int foreign key references MCustomer(CustomerID) )
CREATE TABLE MCustomer (
    CustomerID INT NOT NULL PRIMARY KEY, 
    CustPriority INT
);

CREATE TABLE MSalesOrders (
    SalesOrderID INT NOT NULL PRIMARY KEY, 
    OrderDate DATE,
    SubTotal MONEY,
    CustomerID INT FOREIGN KEY REFERENCES MCustomer(CustomerID) 
);

--  Chèn  dữ  liệu  cho  bảng  MCustomers,  lấy  dữ  liệu  từ  bảng  Sales.Customer, 
--nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho 
--giá trị  null.
INSERT INTO MCustomer (CustomerID, CustPriority)
SELECT CustomerID, NULL
FROM Sales.Customer
WHERE CustomerID > 30100 AND CustomerID < 30118;

--  Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
--Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng 
--khách hàng.
INSERT INTO MSalesOrders (SalesOrderID, OrderDate, SubTotal, CustomerID)
SELECT SalesOrderID, OrderDate, SubTotal, CustomerID
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (SELECT CustomerID FROM MCustomer);

--  Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.
CREATE TRIGGER trg_UpdateCustPriority
ON [dbo].[MSalesOrders]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[MCustomer]
    SET CustPriority = 
        CASE 
            WHEN TotalAmount < 10000 THEN 3
            WHEN TotalAmount >= 10000 AND TotalAmount < 50000 THEN 2
            WHEN TotalAmount >= 50000 THEN 1
        END
    FROM MCustomer C JOIN (
			SELECT CustomerID, SUM(SubTotal) AS TotalAmount
			FROM MSalesOrders
			GROUP BY CustomerID
						   ) AS SalesTotal
			ON C.CustomerID = SalesTotal.CustomerID;
END;
--  Viết  câu  lệnh  kiểm  tra  việc  thực  thi  của  trigger  vừa  tạo  bằng  cách  chèn thêm  hoặc 
--xóa hoặc update một record trên bảng  MSalesOrders
INSERT INTO MSalesOrders (SalesOrderID, OrderDate, SubTotal, CustomerID)
VALUES (10001, '2025-03-20', 35000, 30130);
--kiem tra MCustomers:
SELECT * FROM MCustomers WHERE CustomerID = 30130;
--update SubTotal
UPDATE MSalesOrders 
SET SubTotal = 60000
WHERE SalesOrderID = 10001;
--kiem tra lai MCustomers:
SELECT * FROM MCustomers WHERE CustomerID = 30130;
--xoa don hang
DELETE FROM MSalesOrders WHERE SalesOrderID = 10001;
--3.  Viết  một  trigger  thực  hiện  trên  bảng  MEmployees  sao  cho  khi  người  dùng  thực
--hiện chèn thêm một nhân viên mới vào bảng  MEmployees  thì chương trình cập 
--nhật số nhân viên trong cột  NumOfEmployee của bảng  MDepartment. Nếu tổng 
--số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì 
--hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực  hiện:
--  Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc  sau:
--create table MDepartment 
--(
--DepartmentID int not null primary key, 
--Name nvarchar(50),
--NumOfEmployee int
--)
--create table MEmployees 
--(
--EmployeeID int not null, 
--FirstName nvarchar(50), 
--MiddleName nvarchar(50), 
--LastName nvarchar(50),
--DepartmentID int foreign key references MDepartment(DepartmentID), 
--constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
--) 
CREATE TABLE MDepartment  
(  
    DepartmentID INT NOT NULL PRIMARY KEY,  
    Name NVARCHAR(50),  
    NumOfEmployee INT  
);  

CREATE TABLE MEmployees  
(  
    EmployeeID INT NOT NULL,  
    FirstName NVARCHAR(50),  
    MiddleName NVARCHAR(50),  
    LastName NVARCHAR(50),  
    DepartmentID INT FOREIGN KEY REFERENCES MDepartment(DepartmentID),  
    CONSTRAINT pk_emp_depart PRIMARY KEY (EmployeeID, DepartmentID)  
);

--  Chèn dữ liệu cho bảng  MDepartment, lấy  dữ liệu từ bảng  Department, cột 
--NumOfEmployee  gán  giá  trị  NULL,  bảng  MEmployees  lấy  từ  bảng 
--EmployeeDepartmentHistory
INSERT INTO MDepartment (DepartmentID, Name, NumOfEmployee)
SELECT DepartmentID, Name, NULL
FROM [HumanResources].[Department]
--
SELECT EDH.BusinessEntityID AS EmployeeID, P.FirstName, P.MiddleName, P.LastName, EDH.DepartmentID
FROM [HumanResources].[EmployeeDepartmentHistory] EDH  
JOIN [HumanResources].[Employee] E  ON EDH.BusinessEntityID = E.BusinessEntityID
JOIN [Person].[Person] P ON E.BusinessEntityID = P.BusinessEntityID;

--  Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực  trigger
CREATE TRIGGER trg_LimitEmployees
ON MEmployees
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN MDepartment d ON i.DepartmentID = d.DepartmentID
        WHERE (SELECT COUNT(*) FROM MEmployees WHERE DepartmentID = i.DepartmentID) >= 200
    )
    BEGIN
        RAISERROR ('Da du nhan vien', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO MEmployees (EmployeeID, FirstName, MiddleName, LastName, DepartmentID)
    SELECT EmployeeID, FirstName, MiddleName, LastName, DepartmentID 
	FROM inserted;

    UPDATE MDepartment
    SET NumOfEmployee = (
        SELECT COUNT(*) FROM MEmployees WHERE MEmployees.DepartmentID = MDepartment.DepartmentID
    )
    WHERE DepartmentID IN (SELECT DISTINCT DepartmentID FROM inserted);
END;
--Them mnot nhan vien moi thanh cong (số nhân viên < 200)
INSERT INTO MEmployees (EmployeeID, FirstName, MiddleName, LastName, DepartmentID)
VALUES (1001, 'Nguyen', 'Van', 'Teo', 101);
--Kiem tra sau khi chen
SELECT * FROM MDepartment WHERE DepartmentID = 101;

--4.  Bảng  [Purchasing].[Vendor], chứa thông tin của nhà cung cấp, thuộc    tính
--CreditRating hiển thị thông tin đánh giá mức tín dụng, có các giá trị: 
--1 = Superior
--2 = Excellent
--3 = Above average 
--4 = Average
--5 = Below average
--Viết  một  trigger  nhằm  đảm  bảo  khi  chèn  thêm  một  record  mới  vào  bảng 
--[Purchasing].[PurchaseOrderHeader],  nếu  Vender  có  CreditRating=5  thì  hiển  thị 
--thông báo không cho phép chèn và đồng thời hủy giao tác.
--Dữ liệu test
--INSERT  INTO  Purchasing.PurchaseOrderHeader  (RevisionNumber,  Status, 
--EmployeeID,  VendorID,  ShipMethodID,  OrderDate,  ShipDate,  SubTotal,  TaxAmt, 
--Freight) VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55,
--,3567.564, ,1114.8638 );
CREATE TRIGGER trg_CheckVendor
ON Purchasing.PurchaseOrderHeader
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- kiem tra neu  Vendor co CreditRating = 5
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Purchasing.Vendor v ON i.VendorID = v.BusinessEntityID
        WHERE v.CreditRating = 5
    )
    BEGIN
        RAISERROR ('Khong the tao don hang', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    -- Neu dieu kien khong vi phạm, thuc hein chen du lieu vao bang PurchaseOrderHeader
    INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, [Status], EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight)
    SELECT RevisionNumber, [Status], EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight
    FROM inserted;
END;
----Truong hop bi tu choi (Vendor co CreditRating = 5)
--	INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, [Status], EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight)    
--	VALUES (2, 3, 261, 1652, 4, GETDATE(), GETDATE(), 44594.55, 3567.564, 1114.8638);
----Truong hop thanh cong (Vendor co CreditRating < 5)
--	INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, [Status], EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight)    
--	VALUES (2, 3, 261, 1500, 4, GETDATE(), GETDATE(), 50000, 4000, 1200);
--5.  Viết  một  trigger  điều  chỉnh  số  liệu  trên  bảng  ProductInventory  (lưu  thông  tin  số 
--lượng  sản  phẩm  trong  kho).  Khi 
--chèn  thêm  một  đơn  đặt  hàng  vào 
--bảng  SalesOrderDetail  với  số 
--lượng xác định trong   field
--OrderQty, nếu số lượng trong kho 
--Quantity>  OrderQty thì cập nhật 
--lại  số   lượng   trong   kho 
--Quantity=  Quantity-  OrderQty, 
--ngược lại nếu Quantity=0 thì xuất 
--thông báo “Kho hết hàng” và đồng 
--thời hủy giao  tác.
CREATE TRIGGER trg_UpdateInventory
ON SalesOrderDetail
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Kiem tra san pham het hang
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ProductInventory p ON i.ProductID = p.ProductID
        WHERE p.Quantity = 0
    )
    BEGIN
        RAISERROR ('Kho hết hàng', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    -- Kiem tra so luong trong kho khong du ban
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ProductInventory p ON i.ProductID = p.ProductID
        WHERE p.Quantity < i.OrderQty
    )
    BEGIN
        RAISERROR ('So luong trong kho khong du', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    -- neu du thi tru so luong trong kho
    UPDATE ProductInventory
    SET Quantity = Quantity - i.OrderQty
    FROM ProductInventory p
    JOIN inserted i ON p.ProductID = i.ProductID;
    -- chen don hang vao  SalesOrderDetail
    INSERT INTO SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, LineTotal)
    SELECT SalesOrderID, ProductID, OrderQty, UnitPrice, LineTotal
    FROM inserted;
END;
--6.  Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson,  khi 
--người  dùng  chèn thêm một  record mới  trên  bảng  SalesOrderHeader,  theo  quy  định 
--như sau: Nếu tổng tiền bán được của nhân  viên có hóa  đơn  mới  nhập vào bảng 
--SalesOrderHeader  có giá trị >10000000 thì tăng tiền thưởng lên  10% của  mức 
--thưởng hiện tại. Cách thực  hiện:
--  Tạo hai bảng mới M_SalesPerson và  M_SalesOrderHeader
--create table M_SalesPerson 
--(
--SalePSID int not null primary key, 
--TerritoryID int,
--BonusPS money
--)
--create table M_SalesOrderHeader 
--(
--SalesOrdID int not null primary key, 
--OrderDate date,
--SubTotalOrd money,
--SalePSID int foreign key references M_SalesPerson(SalePSID)
--)
--  Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn 
--những field tương ứng với 2 bảng mới  tạo.
--  Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger 
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập  nhật. 
CREATE TABLE M_SalesPerson 
( 
    SalePSID INT NOT NULL PRIMARY KEY, 
    TerritoryID INT, 
    BonusPS MONEY 
); 

CREATE TABLE M_SalesOrderHeader 
( 
    SalesOrdID INT NOT NULL PRIMARY KEY, 
    OrderDate DATE, 
    SubTotalOrd MONEY, 
    SalePSID INT FOREIGN KEY REFERENCES M_SalesPerson(SalePSID) 
);
-- Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn 
--những field tương ứng với 2 bảng mới tạo. 
INSERT INTO M_SalesPerson (SalePSID, TerritoryID, BonusPS)
SELECT BusinessEntityID, TerritoryID, Bonus
FROM Sales.SalesPerson;

INSERT INTO M_SalesOrderHeader (SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
SELECT SalesOrderID, OrderDate, SubTotal, SalesPersonID
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL;
-- Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger 
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.
CREATE TRIGGER trg_UpdateBonus
ON M_SalesOrderHeader
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cap nhat tien thuong neu tong tien ban duoc  > 10,000,000
    UPDATE M_SalesPerson
    SET BonusPS = BonusPS * 1.1
    WHERE SalePSID IN (
        SELECT i.SalePSID
        FROM inserted i JOIN M_SalesPerson sp 
		ON i.SalePSID = sp.SalePSID
        GROUP BY i.SalePSID
        HAVING SUM(sp.SubTotalOrd) > 10000000
    );
END;
