CREATE PROC tong1 (
	@a int,
	@b int, 
	@Tong int OUTPUT, 
	@Hieu int OUTPUT, 
	@Tich int OUTPUT)

	AS
	BEGIN
		SET @Tong = @a + @b;
		SET @Hieu = @a - @b;
		SET @Tich = @a * @b;

		PRINT 'Tong = ' + CAST(@Tong AS VARCHAR(10));
		PRINT 'Hieu = ' + CAST(@Hieu AS VARCHAR(10));
		PRINT 'Tich = ' + CAST(@Tich AS VARCHAR(10));

	END;
GO


DECLARE @Tong INT,@Hieu INT, @Tich INT;
EXEC tong1 
    @a = 1, 
    @b = 2, 
    @Tong = @Tong OUTPUT, 
    @Hieu = @Hieu OUTPUT, 
    @Tich = @Tich OUTPUT;