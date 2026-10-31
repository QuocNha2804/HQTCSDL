SELECT*
FROM [dbo].[SANPHAM]
----
SELECT*
FROM [dbo].[NHOMSANPHAM]
---
CREATE TRIGGER Insert_trigger
ON [dbo].[SANPHAM]
FOR INSERT
AS
BEGIN
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		DECLARE @MaNhom_Ins INT, @SoLuong INT
		SELECT @MaNhom_Ins = [MaNhom], @SoLuong = [SLTON]
		FROM inserted

		UPDATE [dbo].[NHOMSANPHAM]
		SET [SoLuong] = [SoLuong] + @SoLuong
		WHERE [MaNhom] = @MaNhom_Ins
	END


END
---
CREATE TRIGGER Del_trigger
ON [dbo].[SANPHAM]
FOR DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM deleted)
	BEGIN
		DECLARE @MaNhom_Del INT, @SoLuong INT
		SELECT @MaNhom_Del = [MaNhom], @SoLuong = [SLTON]
		FROM deleted

		UPDATE [dbo].[NHOMSANPHAM]
		SET [SoLuong] = [SoLuong] - @SoLuong
		WHERE @MaNhom_Del = [MaNhom]
	END

END
---
DELETE FROM [dbo].[SANPHAM] WHERE [MaSP] = 7
----
go
create trigger update_Trigger
on [dbo].[SANPHAM] 
for update
as
begin
    if exists (select * from inserted) and exists (select * from deleted)
    begin
        declare @MaNhom_Ins int, @soLuongMoi int, @soLuongCu int;
        select @MaNhom_Ins = D.MaNhom, @soLuongCu = D.SLTON, @soLuongMoi = I.SLTON
        from deleted D
        join inserted I on D.MaSP = I.MaSP;
        update [dbo].[NHOMSANPHAM]
        set [SoLuong] = [SoLuong] - @soLuongCu + @soLuongMoi
        where [MaNhom] = @MaNhom_Ins;
    end
end
----
update [dbo].[SANPHAM] 
set SLTON = 55 
where MaSP = 1;
--Câu 4:Tạo trigger thay thế cho thao tác chèn 1 bản ghi vào
--bảng SANPHAM với SLTON < 0 bằng thông báo ' ko chèn được'
-- và rollback transaction
go
CREATE TRIGGER Check_SLTon
ON [dbo].[SANPHAM]
FOR INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE SLTON < 0)
    BEGIN
        PRINT 'Không thể chèn bản ghi có SLTON nhỏ hơn 0'
        ROLLBACK TRANSACTION
    END
END;
GO

--Câu 5 Tạo HienThi_View gồm: MaNhom,TenNhom,MaSP,TenSP, MaNCC
--Đonvitinh,GiaGoc,SLTON
CREATE VIEW HienThi_View
AS
	SELECT NSP.[MaNhom],[TenNhom],[MaSP],[TenSP],[MaNCC],[Đonvitinh],[GiaGoc],[SLTON]
	FROM [dbo].[SANPHAM] SP JOIN [dbo].[NHOMSANPHAM] NSP ON SP.[MaNhom] = NSP.[MaNhom]

--Câu 6: Tạo trigger thay thế cho thao tác chèn 1 bản ghi vào HienThi_View
--thành thao tác cập nhật soluong trong bảng NHOMSANPHAM, và chèn bản ghi mới vào 
--bảng san phẩm[MaSP]
