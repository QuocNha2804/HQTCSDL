--1.  Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục 
--T:\backup\adv2008back.bak
EXEC sp_addumpdevice 'disk', 'adv2008back', 'T:\Backup\adv2008back.bak';
--2.  Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, rồi 
--thực hiện full backup vào thiết bị backup vừa tạo
ALTER DATABASE [AdventureWorks2008R2]
SET RECOVERY FULL
GO
--CACH1
BACKUP DATABASE[AdventureWorks2008R2]  --FILE 1
TO adv2008back
WITH DESCRIPTION = 'adv2008 FULL Backup'
--CACH2
 BACKUP DATABASE[AdventureWorks2008R2] 
TO DISK = 'T:\Backup\adv2008back.bak'
WITH DESCRIPTION = 'adv2008 FULL Backup'
--3.  Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe 
--đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp 
--hơn 60%.
USE [AdventureWorks2008R2]
GO
--
SELECT [ProductSubcategoryID]
FROM [Production].[ProductSubcategory]
WHERE [Name] LIKE 'Bike%'
--
SELECT [ProductID], [ProductSubcategoryID], [ListPrice]
FROM [Production].[Product]
WHERE [ProductSubcategoryID] IN(SELECT [ProductSubcategoryID]
								FROM [Production].[ProductSubcategory]
								WHERE [Name] LIKE 'Bike%')
---
BEGIN TRAN
UPDATE [Production].[Product]
SET [ListPrice] = [ListPrice] - 15
WHERE [ProductSubcategoryID] IN(SELECT [ProductSubcategoryID]
								FROM [Production].[ProductSubcategory]
								WHERE [Name] LIKE 'Bike%')
	COMMIT
GO
--4.  Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu 
--vào thiết bị backup vừa tạo
--a.  Tạo 1 differential backup 
BACKUP DATABASE [AdventureWorks2008R2] --FILE 2
TO adv2008back
WITH DIFFERENTIAL, DESCRIPTION = 'adv2008 Different backup'
 
--b.  Tạo 1 transaction log backup
--CACH 1
BACKUP LOG [AdventureWorks2008R2] --FILE 3
TO adv2008back
--CACH 2
BACKUP LOG [AdventureWorks2008R2]
TO DISK = 'T:\Backup\adv2008back.TRN'
WITH DESCRIPTION = 'adv2008 Log Backup'
--5.  (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục 
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6). 
--Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup
DELETE Person.EmailAddress
--
SELECT *
FROM Person.EmailAddress
--
--BACKUP K XAI CHUNG VOI TRANSACTION DUOC
BACKUP LOG [AdventureWorks2008R2] --FILE 4
TO adv2008back

--6.  Thực hiện lệnh:
--a.  Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như 
--sau:

--INSERT INTO Person.PersonPhone VALUES (10000,'123-456-7890',1,GETDATE())
SELECT *
FROM Person.PersonPhone
WHERE [BusinessEntityID] = '10000'
---
INSERT INTO Person.PersonPhone VALUES (10000,'123-456-7890',1,GETDATE())
--b.  Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị 
--backup vừa tạo. 
BACKUP DATABASE [AdventureWorks2008R2] --FILE 5
TO adv2008back
WITH DIFFERENTIAL
--
BACKUP LOG [AdventureWorks2008R2] --FILE 6
TO adv2008back
--c.  Chú ý giờ hệ thống của máy. 
--Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem
DROP TABLE [Sales].[ShoppingCartItem]
--7.  Xóa CSDL AdventureWorks2008
USE master
GO
--
DROP DATABASE [AdventureWorks2008R2]
--8.  Để khôi phục lại CSDL: 
--a.  Như lúc ban đầu (trước câu 3) thì phải restore thế nào? 
RESTORE DATABASE [AdventureWorks2008R2]
FROM adv2008back
WITH FILE = 1, NORECOVERY
--b.  Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn 
--còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
RESTORE DATABASE [AdventureWorks2008R2]
FROM adv2008back
WITH FILE = 3, NORECOVERY --XAI NORECOVERY THI DATABASE DANG RESTORING , CHUA XAI DTB DUOC
--c.  Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL 
--AdventureWorks2008  ra sao?
RESTORE DATABASE [AdventureWorks2008R2]
FROM adv2008back
WITH FILE = 5, RECOVERY
--9. Thực hiện đoạn lệnh sau: 
CREATE DATABASE Plan2Recover
GO
USE Plan2Recover; 

CREATE TABLE T1 (
			PK INT Identity PRIMARY KEY, 
			Name VARCHAR(15) 
)
GO 

INSERT T1 VALUES ('Full'); 
GO 

SELECT * FROM T1

BACKUP DATABASE Plan2Recover 
TO DISK = 'T:\P2R.bak' 
WITH NAME = 'P2R_Full', 
INIT; 
--Tiếp tục thực hiện các lệnh sau: 
INSERT T1 VALUES ('Log 1'); 
GO 
BACKUP Log Plan2Recover 
TO DISK ='T:\P2R.bak' 
WITH NAME = 'P2R_Log'; 
--Tiếp tục thực hiện các lệnh sau: 
INSERT T1 VALUES ('Log 2'); 
GO 
BACKUP Log Plan2Recover 
TO DISK ='T:\P2R.bak' 
WITH NAME = 'P2R_Log'; 
--Xóa CSDL vừa tạo, rồi thực hiện quá trình khôi phục như sau: 
Use Master; 
RESTORE DATABASE Plan2Recover 
FROM DISK = 'T:\P2R.bak' 
With FILE = 1, NORECOVERY; 
RESTORE LOG Plan2Recover 
FROM DISK ='T:\P2R.bak' 
With FILE = 2, NORECOVERY; 
RESTORE LOG Plan2Recover 
FROM DISK ='T:\P2R.bak' 
With FILE = 3, RECOVERY; 