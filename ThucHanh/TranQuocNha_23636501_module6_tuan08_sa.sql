--Sử dụng SSMS (Sql Server Management Studio) để thực hiện các thao tác sau:
--1)  Đăng nhập vào  SQL  bằng SQL  Server authentication, tài khoản sa.  Sử dụng TSQL.
USE [master]
GO
---
--2)  Tạo hai login SQL server Authentication User2 và  User3
CREATE LOGIN USER2 WITH PASSWORD = '12345'
CREATE LOGIN USER3 WITH PASSWORD = '12345'
--3)  Tạo một database user User2 ứng với login User2 và một database user   User3
--ứng với login User3 trên CSDL AdventureWorks2008.
USE [AdventureWorks2008R2]
GO
CREATE USER USER2 FOR LOGIN USER2
CREATE USER USER3 FOR LOGIN USER3
--4)  Tạo 2 kết nối đến server thông qua login  User2  và  User3, sau đó thực hiện các 
--thao tác truy cập CSDL  của 2 user  tương ứng (VD: thực hiện  câu Select). Có thực 
--hiện được không?
--Khong thuc hien duoc vi chua cap quyen
--5)  Gán quyền select trên Employee cho User2, kiểm tra kết quả.  Xóa quyền select 
--trên Employee cho User2. Ngắt 2 kết nối của User2 và  User3
GRANT SELECT
ON [HumanResources].[Employee]
TO USER2
----- Truy van duoc vi da cap quyen
REVOKE SELECT
ON [HumanResources].[Employee]
FROM USER2

--6)  Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên 
--CSDL  AdventureWorks2008,  sau  đó  gán  các  quyền  Select,  Update,  Delete  cho 
--Employee_Role.
CREATE ROLE Employee_Role
------
GRANT SELECT, UPDATE, DELETE
TO Employee_Role

--7)  Thêm các  User2  và  User3  vào  Employee_Role.  Tạo  lại  2  kết  nối  đến  server  thông 
--qua login User2 và User3 thực hiện các thao tác  sau:
EXEC sp_addrolemember 'Employee_Role', 'User2'
EXEC sp_addrolemember 'Employee_Role', 'User3'
--a)  Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng 
--Employee

--b)  Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của  nhân 
--viên có BusinessEntityID=1

--c)  Tại kết nối User2, dùng câu lệnh Select xem lại kết  quả.

--d)  Xóa role Employee_Role, (quá trình xóa role    ra sao ?)
EXEC sp_droprolemember 'Employee_Role', 'User2'
EXEC sp_droprolemember 'Employee_Role', 'User3'