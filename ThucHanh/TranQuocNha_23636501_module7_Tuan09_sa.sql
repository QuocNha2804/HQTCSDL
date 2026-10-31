---module 7 tuan 8
--1)  Thêm  vào  bảng  Department  một  dòng  dữ  liệu  tùy  ý  bằng  câu  lệnh 
--INSERT..VALUES…
--a)  Thực hiện lệnh chèn thêm vào bảng Department một dòng dữ liệu tùy ý bằng 
--cách thực hiện lệnh Begin tran và Rollback, dùng câu lệnh Select * From 
--Department xem kết quả.
USE [AdventureWorks2008R2]
GO
---
BEGIN TRAN
INSERT [HumanResources].[Department]([Name],[GroupName], [ModifiedDate] )
VALUES ('IT DEPARTMENT', 'IUH', GETDATE())
ROLLBACK
GO
--b)  Thực hiện câu lệnh trên với lệnh Commit và kiểm tra kết  quả.
BEGIN TRAN
INSERT [HumanResources].[Department]([Name],[GroupName], [ModifiedDate] )
VALUES ('IT DEPARTMENT', 'IUH', GETDATE())
COMMIT
GO
--2)  Tắt chế độ autocommit của SQL Server (SET IMPLICIT_TRANSACTIONS 
--ON). Tạo đoạn batch gồm các thao  tác:
--  Thêm một dòng vào bảng  Department
--  Tạo một bảng Test (ID int, Name  nvarchar(10))
--  Thêm một dòng vào Test
--  ROLLBACK;
--  Xem dữ liệu ở bảng Department và Test để kiểm tra dữ liệu, giải thích kết 
--quả.
SET IMPLICIT_TRANSACTIONS ON

INSERT [HumanResources].[Department]([Name],[GroupName], [ModifiedDate])
VALUES ('AC DEPARTMENT', 'IUH', GETDATE())

CREATE TABLE Test (ID int, Name  nvarchar(10))

INSERT Test
VALUES(1,'IUH')

ROLLBACK
GO
---
SELECT * FROM [HumanResources].[Department]
--
SELECT * FROM Test
---vi dang du dung rollback nen khi chay cac batch lenh, no se rollback ve trang thai ban dau
-- nen insert du lieu khong duoc va khong the tao bang test
----

--3)  Viết  đoạn  batch  thực  hiện  các  thao  tác  sau  (lưu  ý  thực  hiện  lệnh  SET 
--XACT_ABORT ON: nếu câu lệnh T-SQL làm phát sinh lỗi run-time, toàn bộ giao 
--dịch được chấm dứt và  Rollback)
--  Câu lệnh SELECT với phép chia 0 :SELECT 1/0 as  Dummy
--  Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này 
--không tồn  tại)
--  Xóa một dòng không tồn tại trên bảng Department  (DepartmentID =’66’)
--  Thêm một dòng bất kỳ vào bảng  Department
--  COMMIT;
--Thực thi đoạn batch, quan sát kết quả và các thông báo lỗi và giải thích kết quả
SET XACT_ABORT ON
BEGIN TRAN
SELECT 1/0 AS Dummy

UPDATE [HumanResources].[Department]
SET [GroupName] = 'IUH'
WHERE [DepartmentID]= '9'

DELETE [HumanResources].[Department]
WHERE [DepartmentID] ='66'

INSERT [HumanResources].[Department]([Name],[GroupName], [ModifiedDate])
VALUES ('QN DEPARTMENT', 'IUH', GETDATE()) 

COMMIT
GO
---
SELECT * FROM [HumanResources].[Department]
WHERE [DepartmentID] ='9'
GO
--4)  Thực  hiện  lệnh  SET  XACT_ABORT  OFF  (những  câu  lệnh  lỗi  sẽ  rollback, 
--transaction vẫn tiếp tục) sau đó thực thi lại các thao tác của đoạn batch ở câu 3. Quan 
--sát kết quả và giải thích kết  quả?
SET XACT_ABORT OFF
---chay cai nay co the khong chon edit 200 row cua bang duoc
BEGIN TRAN
SELECT 1/0 AS Dummy

UPDATE [HumanResources].[Department]
SET [GroupName] = 'IUH'
WHERE [DepartmentID]= '9'

DELETE [HumanResources].[Department]
WHERE [DepartmentID] ='66'

INSERT [HumanResources].[Department]([Name],[GroupName], [ModifiedDate])
VALUES ('QN DEPARTMENT', 'IUH', GETDATE()) 

COMMIT
GO
---
SELECT * FROM [HumanResources].[Department]
WHERE [DepartmentID] ='9'
GO
---
------tuan 09


--1)  Tạo bảng Accounts (AccountID int NOT NULL PRIMARY KEY, 
--balance int NOT NULL
--CONSTRAINT unloanable_account CHECK (balance >= 0)
--Chèn dữ liệu:
--INSERT INTO Accounts (acctID,balance) VALUES (101,1000); 
--INSERT INTO Accounts (acctID,balance) VALUES (202,2000);
--chuan bi
CREATE DATABASE abc
GO
USE abc
GO
--
CREATE TABLE Accounts (
	AccountID int NOT NULL PRIMARY KEY, 
	balance int NOT NULL 
	CONSTRAINT unloanable_account CHECK (balance >= 0)
)
GO
---
sp_helpconstraint 'accounts'
GO
---insert
INSERT INTO Accounts (AccountID,balance) VALUES (101,1000); 
INSERT INTO Accounts (AccountID,balance) VALUES (202,1000); 
GO
--
SELECT * FROM Accounts
----
CREATE LOGIN USER2 WITH PASSWORD = '123'
CREATE LOGIN USER3 WITH PASSWORD = '123'
---
CREATE USER USER2 FOR LOGIN USER2
CREATE USER USER3 FOR LOGIN USER3
---
CREATE ROLE Role_Account
---
GRANT INSERT, SELECT, UPDATE, DELETE
TO Role_Account
--
DROP user USER2
DROP user USER3
--
EXEC sp_addrolemember Role_Account, USER2
EXEC sp_addrolemember Role_Account, USER3
--2)  SET TRANSACTION ISOLATION  LEVEL
--SET TRANSACTION ISOLATION LEVEL
--{ READ UNCOMMITTED
--| READ COMMITTED
--| REPEATABLE READ
--| SNAPSHOT
--| SERIALIZABLE
--}[ ; ]
--  READ UNCOMMITTED: có thể đọc những dòng đang được hiệu chỉnh 
--bởi các transaction khác nhưng chưa  commit
--  READ COMMITTED: không thể đọc những dòng đang hiệu chỉnh bởi 
--những transaction khác mà chưa  commit

--3)  Mở 2 cửa sổ Query của SQL server, thiết lập SET TRANSACTION ISOLATION 
--LEVEL READ COMMITTED ở cả 2 cửa sổ (tạm gọi là client A bên trái, và client B 
--bên  phải)
--  B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts 
--với AccountID  =101
--  B2: Client A cập nhật account trên AccountID  =101, balance  =1000-200
--  B3: Client B cập nhật account trên AccountID  =101, balance  =1000-500
--  B4: Client A: SELECT trên Accounts với AccountID  =101;  COMMIT;
--  B5: Client B: SELECT trên Accounts với AccountID =101; COMMIT; 
--Quan sát kết quả hiển thị và giải  thích.
--4)  Thiết lập ISOLATION LEVEL REPEATABLE READ  (không thể đọc được dữ liệu 
--đã  được  hiệu  chỉnh  nhưng  chưa  commit  bởi  các  transaction  khác  và  không  có 
--transaction khác có thể hiệu chỉnh dữ liệu đã được đọc bởi các giao dịch hiện tại cho 
--đến transaction hiện tại hoàn thành) ở 2 client. Thực hiện yêu cầu  sau:
--  B1: Client  A,  client  B:  cùng  thực  hiện  lệnh  SELECT  trên  bảng  Accounts  với
--AccountID  =101
--  B2: Client A cập nhật accounts trên AccountID  =101, balance  =1000-200
--  B3: Client B cập nhật accounts trên AccountID  =101, balance  =1000-500.
--  B4: Client A: SELECT trên Accounts với AccountID  =101;  COMMIT;
--Quan sát kết quả hiển thị và giải  thích.
--5)  Giả sử có 2 giao dịch chuyển tiền từ tài khoản 101 và 202 như  sau:
--  Client A chuyển 100$ từ tài khoản 101 sang  202
--  Client B chuyển 200$ từ tài khoản 202 sang  101.
--Viết các lệnh tương ứng ở 2 client để kiểm soát các giao dịch xảy ra đúng
--6)  Xóa tất cả dữ liệu của bảng Accounts. Thêm lại các dòng  mới
--INSERT INTO Accounts (AccountID  ,balance) VALUES (101,1000);
--INSERT INTO Accounts (AccountID  ,balance) VALUES (202,2000);
--  B1: Client A: cập nhật balance của account giảm đi 100 cho AccountID =101, 
--cập nhật balance của account tăng lên 100 cho AccountID  =202
--  B2: Client B: thiết lập ISOLATION LEVEL READ  UNCOMMITTED
--SELECT * FROM Accounts; 
--COMMIT; 
--  B3: Client A: 
--ROLLBACK;
--SELECT * FROM Accounts; 
--COMMIT;
--Quan sát kết quả và giải thích.
DELETE FROM Accounts;
-- Thêm lại dữ liệu mới
INSERT INTO Accounts (AccountID, balance) VALUES (101, 1000);
INSERT INTO Accounts (AccountID, balance) VALUES (202, 2000);

--client A thực hiện update, kết quả sau update là AccountID = 101: 900, AccountID = 202: 2100
--khi đó client B SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT * FROM Accounts; kết quả hiển thị  AccountID = 101: 900, AccountID = 202: 2100
--Do dùng READ UNCOMMITTED, nên Client B đọc được dữ liệu chưa commit của Client A.Đây gọi là dirty read (đọc bẩn).Nếu A rollback thì dữ liệu B vừa đọc là không còn đúng.
--client A ROLLBACK; dữ liệu quay về ban đầu  AccountID = 1000: 900, AccountID = 202: 2000
--A select lại và kêt quả là  AccountID = 1000: 900, AccountID = 202: 2000
--Dữ liệu được khôi phục về trạng thái trước khi A bắt đầu transaction.
--Như vậy dữ liệu mà B đọc trước đó (900 và 2100) là không còn đúng – đây chính là hậu quả của việc dùng READ UNCOMMITTED.
----7)  Xóa tất cả dữ liệu của bảng Account, thêm lại các dòng  mới
--INSERT INTO Accounts (AccountID ,balance) VALUES (101,1000); 
--INSERT INTO Accounts (AccountID  ,balance) VALUES (202,2000);
---  B1: Client A: thiết lập ISOLATION LEVEL REPEATABLE READ;
--Lấy ra các Accounts có Balance>1000
---  B2: Client B:
--INSERT INTO Accounts (AccountID ,balance) VALUES 
--(303,3000);
--COMMIT;
---  B3: Client  A:
--SELECT * FROM Accounts WHERE balance > 1000;
--COMMIT;
--Quan sát kết quả và giải thích
DELETE FROM Accounts;
-- Thêm lại dữ liệu mới
INSERT INTO Accounts (AccountID, balance) VALUES (101, 1000);
INSERT INTO Accounts (AccountID, balance) VALUES (202, 2000);