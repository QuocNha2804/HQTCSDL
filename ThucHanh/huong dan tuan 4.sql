CREATE TABLE NHOMSANPHAM
(
	MaNhom  Int  PRIMARY KEY Not null,
	TenNhom nvarchar(15) 
)
GO

CREATE TABLE NHACUNGCAP
(
	MaNCC  Int  PRIMARY KEY Not null,
	TenNCC nvarchar(40) Not null,
	Diachi  Nvarchar(60),
	Phone  NVarchar(24),
	SoFax  NVarchar(24),
	DCMail  NVarchar(50) 
)
GO

CREATE TABLE KHACHHANG
(
	MaKH  Char(5)  PRIMARY KEY Not null,
	TenKH nvarchar(40) Not null,
	LoaiKH  Nvarchar(3) CHECK( LoaiKH IN ('VIP','TV','VL')),
	DiaChi  Nvarchar(60),
	Phone  NVarchar(24),
	DCMail  NVarchar(50),
	DiemTL  Int CHECK (DiemTL >= 0)
)
GO

CREATE TABLE SANPHAM
(
	MaSP  Int  PRIMARY KEY Not null,
	TenSP nvarchar(40) Not null,
	MaNCC Int  REFERENCES NHACUNGCAP(MaNCC),
	MoTa  nvarchar(50),
	MaNhom   Int REFERENCES NHOMSANPHAM(MaNhom),
	Đonvitinh  nvarchar(20),
	GiaGoc  Money CHECK (GiaGoc >0),
	SLTON  Int CHECK (SLTON > 0)
)
GO
--Tao khoa ngoai khi da tao xong bang (Neu quen tao khoa ngoai
ALTER TABLE SANPHAM  WITH CHECK 
ADD CONSTRAINT MaNhom_FK Foreign key (MaNhom)  
REFERENCES NHOMSANPHAM(MaNhom)  
ON DELETE Set NULL   
ON UPDATE Cascade 
CREATE DATABASE QLBH
ON PRIMARY
(
	NAME = QLBH_data1,
	FILENAME = 'F:\QLBH\QLBH_data1.mdf',
	SIZE = 10 MB,
	MAXSIZE = 40MB,
	FILEGROWTH = 1MB
)
LOG ON
(
	NAME = QLBH_log,
	FILENAME = 'F:\QLBH\QLBH_log.ldf',
	SIZE = 6MB,
	MAXSIZE = 8MB,
	FILEGROWTH = 1MB
)
--cau 2.b
USE QLBH
CREATE TABLE HOADON
(
	MaHD  Int  PRIMARY KEY Not null,
	NgayLapHD  DateTime DEFAULT GETDATE() CHECK (NgayLapHD >= GETDATE()) ,
	NgayGiao  DateTime ,
	Noichuyen  NVarchar(60)  Not Null, 
	MaKH     Char(5) REFERENCES KHACHHANG(MaKH)
)
GO


CREATE TABLE CT_HOADON
(
	MaHD  Int   Not null  REFERENCES HOADON(MaHD),
	MaSP Int Not null REFERENCES SANPHAM(MaSP),
	Soluong  SmallInt CHECK (Soluong >0),
	Dongia  Money,
	ChietKhau  Money CHECK (ChietKhau >= 0),
	PRIMARY KEY(MaHD,MaSP)
	ON DELETE Cascade  
	ON UPDATE Cascade 
)
GO

--BAI1.4.a
ALTER TABLE HOADON
ADD LoaiHD char(1) DEFAULT 'N' CHECK( LoaiHD IN ('N','X','T'))
GO

--BAI1.4.b
ALTER TABLE HOADON 
ADD CONSTRAINT NGAY_GIAO CHECK (NgayGiao > NgayLapHD) 
GO

USE QLBH
GO
--Bai 1.a: Sua lai do rong cot TenNhom
-- Table NHOMSANPHAM
ALTER TABLE NHOMSANPHAM
ALTER COLUMN TenNhom nvarchar(50) not null

INSERT INTO NHOMSANPHAM VALUES(1, N'Điện tử')
INSERT INTO NHOMSANPHAM VALUES(2, N'Gia Dụng')
INSERT INTO NHOMSANPHAM VALUES(3, N'Dụng Cụ Gia Đình')
INSERT INTO NHOMSANPHAM VALUES(4, N'Các Mặt Hàng Khác')

--Table NHACUNGCAP

INSERT INTO NHACUNGCAP VALUES(1, N'Công ty TNHH Nam Phương', N'1 Lê Lợi, Phường 4, Gò Vấp', N'02345', N'32456', N'NamPhuong@yahoo.com')
INSERT INTO NHACUNGCAP VALUES(2, N'Công ty Lan Ngọc', N'12 Cao Bá Quát, quận 1, TP HCM', N'04758', N'32456', N'LanNgoc@yahoo.com')

--Table SANPHAM
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(1, N'Máy Tính', N'Cái', 700, 100,1,1, N'Máy Sony Ram 2GB')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(2, N'Bàn phím', N'Cái', 1000, 50,1,1, N'Bàn phím 101 phím')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(3, N'Chuột', N'Cái', 800, 150,1,1, N'Chuột không dây')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(4, N'CPU', N'Cái', 3000, 200,1,1, N'CPU')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(5, N'USB', N'Cái', 500, 100,1,1, N'8GB')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(6, N'Lò Vi Sóng', N'Cái', 1000000, 20,3,2, N' ')
--Table KHACHHANG
INSERT INTO KHACHHANG(MaKH,TenKH,DiaChi,Phone,LoaiKH,DCMail,DiemTL) VALUES('KH1', N'Nguyễn Thu Hằng', N'12 Nguyễn Du', N'',N'VL',N'',N'')
INSERT INTO KHACHHANG(MaKH,TenKH,DiaChi,Phone,LoaiKH,DCMail,DiemTL) VALUES('KH2', N'Lê Minh', N'34 Điện Biên Phủ', N'01234',N'TV',N'LeMinh@yahoo.com', 100)
INSERT INTO KHACHHANG(MaKH,TenKH,DiaChi,Phone,LoaiKH,DCMail,DiemTL) VALUES('KH3', N'NGuyễn Minh Trung', N'3 Lê Lợi Gò Vấp', N'0897',N'VIP',N'Trung@yahoo.com', 800)
-- Table HOADON
INSERT INTO HOADON(MaHD,NgayLapHD,MaKH,NgayGiao,Noichuyen,LoaiHD)      
VALUES (1,'30/09/2015','KH1','05/10/2015',N'Cửa hàng ABC 3 Lý CHính Thắng, Q.3','N')

INSERT INTO HOADON(MaHD,NgayLapHD,MaKH,NgayGiao,Noichuyen,LoaiHD)      
VALUES (2,'29/07/2015','KH2','10/08/2015',N'23 Lê Lợi, Q.Gò Vấp', 'T')

INSERT INTO HOADON(MaHD,NgayLapHD,MaKH,NgayGiao,Noichuyen,LoaiHD)      
VALUES (2,'01/10/2015','KH3','01/10/2015',N'2 Nguyễn Du, Q.Gò Vấp', 'X')
GO

--Table CT_HOADON
INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (1,1,8000,5)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (1,2,1200,4)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (1,3,1000,15)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (2,2,1200,9)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (2,4,8000,5)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (3,2,3500,20)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (3,3,1000,15)

--bai 1.2.a
UPDATE SANPHAM
SET GiaGoc = 1.05 * GiaGoc
WHERE MaSP = 2

--bai 1.2.b
UPDATE SANPHAM
SET SLTON = SLTON + 100
WHERE MaNCC = 3 AND MaNhom = 2

--bai 1.2.c
UPDATE SANPHAM
SET MoTa = N'Hàng nhập khầu nguyên chiếc'
WHERE TenSP = N'Lò vi sóng'

--bai 1.2.d: Error. Phai thay doi thuoc tinh khoa ngoai
UPDATE KHACHHANG
SET MaKH = 'VI003'
WHERE MaKH = 'KH3'
-- Xoa Contraints
ALTER TABLE HOADON 
DROP CONSTRAINT FK_HOADON_KHACHHANG 

-- Update Contraints

ALTER TABLE HOADON  WITH CHECK 
ADD CONSTRAINT  FK_HOADON_KHACHHANG Foreign key (MaKH)  
REFERENCES KHACHHANG(MaKH)  
ON DELETE Cascade    
ON UPDATE Set NULL 

--Thuc hien lai
UPDATE KHACHHANG
SET MaKH = 'VI003'
WHERE MaKH = 'KH3'
--bai 1.2.e
UPDATE KHACHHANG
SET MaKH = 'VL001'
WHERE MaKH = 'KH1'

UPDATE KHACHHANG
SET MaKH = 'T0002'
WHERE MaKH = 'KH2'

--bai1.3.a.
Delete from NHOMSANPHAM where  MaNhom = 3
--bai1.3.b.
Delete from CT_HOADON where  (MaHD = 1 AND MaSP = 3)
--bai1.3.c: Error- Do trong Table CT_HOADON co tham chieu den MaHD = 1
Delete from HOADON where  MaHD = 1
--bai1.3.c: Error- Do trong Table CT_HOADON co tham chieu den MaHD = 2
Delete from HOADON where  MaHD = 2

-- Xoa Contraints
ALTER TABLE CT_HOADON 
DROP CONSTRAINT FK__CT_HOADON__MaHD__46E78A0C 

-- Update Contraints

ALTER TABLE CT_HOADON  WITH CHECK 
ADD CONSTRAINT  FK_HOADON_CT_HOADON Foreign key (MaHD)  
REFERENCES HOADON(MaHD)  
ON DELETE Cascade    

--Thuc hien lai
Delete from HOADON where  MaHD = 2