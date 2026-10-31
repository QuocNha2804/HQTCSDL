USE master

CREATE LOGIN Login_User8 WITH PASSWORD = '123456' 

USE [QLHocVien];

CREATE USER User8 FOR LOGIN Login_User8
--cap quyen select cho user8 // lam tren sa
GRANT SELECT
ON [QLHocVien]
TO User8 -- qua new query moi la cua User8 co the select bang Hoc vien 
--thu hoi quyen // lam tren sa
REVOKE SELECT
ON [QLHocVien]
TO User8
---tao role
USE [QLHocVien]
CREATE ROLE HocVien_Role
---Gan quyen cho role
GRANT UPDATE, SELECT, DELETE
TO HocVien_Role

--
--them User 3 vao role
EXEC sp_addrolemember N'Employee_Role', N'User3'
--xoa role neu role rong, k con thanh vien
DROP ROLE Employee_Role