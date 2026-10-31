--C. BÀI TẠP STORED PROCEDURE

--1. Cho biết danh sách các giáo viên được phân công giảng dạy môn “Khai thác dữ liệu”.
CREATE PROCEDURE sp_DanhSachGiaoVienKhaiThacDuLieu
AS
BEGIN
    SELECT GV.[MaGV],[TenGV]
    FROM [dbo].[GIAOVIEN] GV
    JOIN [dbo].[PHANCONG] PC ON GV.MaGV= PC.MaGV
    JOIN [dbo].[MONHOC] MH ON PC.MaMH = MH.MaMonHoc
    WHERE MH.TenMonHoc = N'Khai thác dữ liệu';
END;
---
EXEC sp_DanhSachGiaoVienKhaiThacDuLieu;
---
--2. Nhận vào họ tên một giáo viên, cho biết danh sách tên các môn học mà giáo viên
--này đã được phân công giảng dạy.

CREATE PROCEDURE sp_DanhSachMonHocCuaGiaoVien @HoTenGiaoVien NVARCHAR(100)
    
AS
BEGIN
    SELECT MH.TenMonHoc
    FROM [dbo].[GIAOVIEN] GV
    JOIN [dbo].[PHANCONG] PC ON GV.MaGV = PC.MaGV
    JOIN [dbo].[MONHOC] MH ON PC.MaMH = MH.MaMonHoc
    WHERE GV.TenGV = @HoTenGiaoVien;
END;

EXEC sp_DanhSachMonHocCuaGiaoVien N'Trần Minh Anh';


--3. Nhận vào họ tên một giáo viên, đếm số môn mà giáo viên này có khả năng giảng
--dạy. Xuất ra dưới dạng tham số output và in ra kết quả.
CREATE PROCEDURE sp_DemSoMonCuaGiaoVien
    @HoTenGiaoVien NVARCHAR(100),  
    @SoMon INT OUTPUT              
AS
BEGIN
  
    SELECT @SoMon = COUNT(MH.MaMonHoc)
    FROM [dbo].[GIAOVIEN] GV
    JOIN [dbo].[PHANCONG] PC ON GV.MaGV = PC.MaGV
    JOIN [dbo].[MONHOC] MH ON PC.MaMH = MH.MaMonHoc
    WHERE GV.TenGV = @HoTenGiaoVien;
END;

DECLARE @SoMon INT;
EXEC sp_DemSoMonCuaGiaoVien N'Trần Minh Anh', @SoMon OUTPUT;
PRINT N'Số môn giảng dạy: ' + CAST(@SoMon AS NVARCHAR(10));

--4. Nhận vào một tên môn học, cho biết có bao nhiêu học viên đã từng thi đậu môn này.

--Xuất ra dưới dạng tham số output và in ra kết quả.
CREATE PROCEDURE sp_DemHocVienThiDau @TenMonHoc NVARCHAR(100), @SoHocVien INT OUTPUT
AS
BEGIN
 SELECT @SoHocVien = COUNT(DISTINCT HV.MaHocVien)
 FROM [dbo].[MONHOC] MH 
 JOIN [dbo].[KETQUA] KQ ON MH.MaMonHoc = KQ.MaMonHoc
 JOIN [dbo].[HOCVIEN] HV ON KQ.MaHV = HV.MaHocVien
 WHERE MH.TenMonHoc = @TenMonHoc AND KQ.Diem >=5
 END;


 DECLARE @SoHocVien INT;
 EXEC sp_DemHocVienThiDau N'Hệ thống thông minh', @SoHocVien OUTPUT;
 PRINT N'Số học viên: ' + CAST(@SoHocVien AS NVARCHAR(10));
--D. BÀI TẬP FUNCTION

--1. Nhập vào tên một học viên cho biết số môn học viên này đã từng thi rớt.
CREATE FUNCTION fn_SoHocVienThiRot( @TenHocVien NVARCHAR(100))
RETURNS INT
AS
BEGIN
	DECLARE @SoMonRot INT;
	SELECT @SoMonRot = COUNT(DISTINCT KQ.MaMonHoc)
	FROM [dbo].[HOCVIEN] HV JOIN [dbo].[KETQUA] KQ ON HV.MaHocVien = KQ.MaHV
	WHERE HV.TenHocVien = @TenHocVien AND KQ.Diem <5
	RETURN @SoMonRot
END;

DECLARE @SoMonRot INT;
SET @SoMonRot = [dbo].[fn_SoHocVienThiRot](N'Trần Trung Chính');
PRINT N'So mon thi rot la: '+ CAST(@SoMonRot AS NVARCHAR(10));
--2. Nhập vào một mã lớp, một tên giáo viên. Cho biết số môn mà giáo viên từng dạy
--cho lớp này.
CREATE FUNCTION fn_SoMonGiaoVienDayChoLop(@MaLop NVARCHAR(100), @TenGiaoVien NVARCHAR(100))
RETURNS INT
AS
BEGIN
	DECLARE @SoMon INT;
	SELECT @SoMon = COUNT(DISTINCT PC.MaMH)
	FROM [dbo].[GIAOVIEN] GV JOIN [dbo].[PHANCONG] PC ON GV.MaGV = PC.MaGV JOIN [dbo].[LOPHOC] LH ON PC.MaLop = LH.MaLop
	WHERE LH.MaLop=@MaLop AND GV.TenGV = @TenGiaoVien
	RETURN @SoMon
END;

DECLARE @SoMon INT;
SET @SoMon = [dbo].[fn_SoMonGiaoVienDayChoLop](N'LH000004',N'Hà Anh Tuấn')
PRINT N'So Mon Hoc La: '+ CAST(@SoMon AS NVARCHAR(10))

--3. Nhập vào một mã học viên, cho biết điểm trung bình của học viên.
CREATE FUNCTION fn_DiemTrungBinhHocVien(@MaHocVien NVARCHAR(100))
RETURNS FLOAT
AS
BEGIN
	DECLARE @DiemTrungBinh FLOAT;
	SELECT @DiemTrungBinh = AVG(KQ.Diem)
	FROM [dbo].[HOCVIEN] HV JOIN [dbo].[KETQUA] KQ ON HV.MaHocVien = KQ.MaHV
	WHERE HV.MaHocVien = @MaHocVien
	RETURN @DiemTrungBinh
END;

DECLARE @DiemTrungBinh FLOAT;
SET @DiemTrungBinh = [dbo].[fn_DiemTrungBinhHocVien](N'HV000004')
PRINT N'Diem Trung Binh La: ' + CAST(@DiemTrungBinh AS NVARCHAR(10))
--4. Nhập vào một tên môn học, cho biết danh sách các học viên (mã học viên, tên học
--viên, ngày sinh) đã đậu môn này. Học viên đậu khi điểm lần thi sau cùng >= 5.

CREATE FUNCTION fn_DanhSachHocVienThiDau(@TenMonHoc NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
	SELECT [MaHocVien],[TenHocVien],[NgaySinh]
	FROM [dbo].[HOCVIEN] HV JOIN [dbo].[KETQUA] KQ ON HV.MaHocVien=KQ.MaHV JOIN [dbo].[MONHOC] MH ON KQ.MaMonHoc = MH.MaMonHoc
	WHERE MH.TenMonHoc = @TenMonHoc AND KQ.Diem >=5 AND KQ.LanThi =( SELECT MAX(KQ2.LanThi)
																	FROM [dbo].[KETQUA] KQ2
																	WHERE KQ2.MaHV = KQ.MaHV AND KQ2.MaMonHoc = KQ.MaMonHoc)
);

SELECT*
FROM [dbo].[fn_DanhSachHocVienThiDau](N'Toán cao cấp');


