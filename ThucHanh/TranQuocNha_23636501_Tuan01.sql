CREATE DATABASE SmallWorks
ON PRIMARY
(
NAME = 'SmallWorksPrimary',
FILENAME = 'T:\TranQuocNha\SmallWorks.mdf',
SIZE = 10MB,
MAXSIZE = 50MB,
FILEGROWTH = 20%
),
FILEGROUP SWUserData1
(
NAME = 'SmallWorksData1',
FILENAME = 'T:\TranQuocNha\SmallWorksData1.ndf',
SIZE = 10MB,
MAXSIZE = 50MB,
FILEGROWTH = 20%
),
FILEGROUP SWUserData2
(
NAME = 'SmallWorksData2',
FILENAME = 'T:\TranQuocNha\SmallWorkData2.ndf',
SIZE = 10MB,
MAXSIZE = 50MB,
FILEGROWTH = 20%
)
LOG ON
(
NAME = 'SmallWorks_log',
FILENAME = 'T:\TranQuocNha\SmallWorks_log.ldf',
SIZE = 10MB,
MAXSIZE = 20MB,
FILEGROWTH = 10%
)
GO
----
USE SmallWorks
--4.  Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, sau đó add 
--thêm 2 file filedat1.ndf và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1. 
--Dùng SSMS xem kết  quả.
ALTER DATABASE SmallWorks
ADD FILEGROUP Test1FG1
GO
---
ALTER DATABASE SmallWorks
ADD FILE
(
NAME = 'filedat1',
FILENAME = 'T:\TranQuocNha\filedat1.ndf',
SIZE = 5MB,
MAXSIZE = 50MB,
FILEGROWTH = 20%
) TO FILEGROUP Test1FG1
GO
---
ALTER DATABASE SmallWorks
ADD FILE
(
NAME = 'filedat2',
FILENAME = 'T:\TranQuocNha\filedat2.ndf',
SIZE = 5MB,
MAXSIZE = 50MB,
FILEGROWTH = 20%
) TO FILEGROUP Test1FG1
GO
--5.  Dùng T-SQL tạo thêm một một file thứ cấp  filedat3.ndf  dung lượng 3MB trong 
--filegroup Test1FG1. Sau đó sửa kích thước tập tin này lên 5MB. Dùng SSMS xem 
--kết quả. Dùng T-SQL xóa file thứ cấp filedat3.ndf. Dùng SSMS xem kết  quả
ALTER DATABASE SmallWorks
ADD FILE
(
NAME = 'filedat3',
FILENAME = 'T:\TranQuocNha\filedat3.ndf',
SIZE = 3MB,
MAXSIZE = 50MB,
FILEGROWTH = 20%
) TO FILEGROUP Test1FG1
GO
---
ALTER DATABASE SmallWorks
MODIFY FILE(NAME = 'filedat3', size = 5MB)
GO
---
ALTER DATABASE SmallWorks
REMOVE FILE filedat3
GO

--6.  Xóa  filegroup  Test1FG1?  Bạn  có  xóa  được  không?  Nếu  không  giải  thích?  Muốn  xóa 
--được bạn phải làm  gì?
ALTER DATABASE SMallWorks
REMOVE FILEGROUP Test1FG1
GO
---Khong the xoa tai vi FileGroup khong rong, neu muon xoa thi phai xoa tat ca du lieu ben trong FileGroup
--7.  Xem  lại  thuộc  tính  (properties)  của  CSDL  SmallWorks  bằng  cửa  sổ  thuộc  tính 
--properties  và  bằng  thủ  tục  hệ  thống  sp_helpDb,  sp_spaceUsed,  sp_helpFile. 
--Quan sát và cho biết các trang thể hiện thông tin  gì?.
sp_helpDb SmallWorks
GO
--hien thi thong tin ve ten cac file, duong dan, nam trong filegourp nao, kich thuoc
sp_spaceUsed 
GO
---hien thi khong gian luu bo nho dang su dung
sp_helpFile
GO
---Hien thi thong tin ve cac file
--8.  Tại cửa sổ properties của CSDL SmallWorks, chọn thuộc tính ReadOnly, sau đó 
--đóng  cửa  sổ  properties.  Quan  sát  màu  sắc  của  CSDL.  Dùng  lệnh  T-SQL  gỡ  bỏ
--thuộc  tính  ReadOnly  và  đặt  thuộc  tính  cho  phép  nhiều  người  sử  dụng  CSDL
--SmallWorks.
---Mau sac chuyen sang mau xam
--9. Trong CSDL SmallWorks, tạo 2 bảng mới theo cấu trúc như  sau
CREATE TABLE Person
(
PersonID int not null,
FirtstName nvarchar(50) not null,
MiddleName nvarchar(50) null,
LastName nvarchar(50) not null,
EmailAddress nvarchar(50) null
)ON SWUserData1
GO
---
CREATE TABLE Product
(
ProductID int not null,
ProductName nvarchar(75) NOT NULL,
ProductNumber nvarchar(25) NOT NULL,
StandardCost money NOT NULL,
ListPrice money NOT NULL
)ON SWUserData2
GO
--10.  Chèn dữ liệu vào 2 bảng trên, lấy dữ liệu từ bảng  Person  và bảng  Product  trong 
--AdventureWorks2008  (lưu  ý:  chỉ  rõ  tên  cơ  sở  dữ  liệu  và  lược  đồ),  dùng  lệnh 
--Insert…Select...  Dùng  lệnh  Select *  để  xem  dữ  liệu  trong  2  bảng  Person  và  bảng
--Product  trong SmallWorks.
use [AdventureWorks2008R2]
GO
--
INSERT INTO [SmallWorks].dbo.Person ([PersonID],[FirtstName],[MiddleName],[LastName],[EmailAddress])
SELECT BusinessEntityID, FirstName, MiddleName, LastName, EmailPromotion from [Person].[Person];

SELECT *
FROM dbo.Person
GO
--
SELECT [ProductID].[Name], [ProductNumber], [ListPrice]
INTO [SmallWorks].dbo.Products(ProductID, ProductName, ProductNumber, StandardCost, ListPrice)
FROM [Production].[Product];
GO
--11.  Dùng SSMS, Detach cơ sở dữ liệu SmallWorks ra khỏi phiên làm việc của  SQL.
--12.  Dùng SSMS, Attach cơ sở dữ liệu SmallWorks vào  SQL