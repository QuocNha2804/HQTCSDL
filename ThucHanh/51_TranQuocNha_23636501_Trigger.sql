USE [QLHocVien]
-- 1. Đảm bảo năm bắt đầu của một lớp học luôn nhỏ hơn năm kết thúc
CREATE TRIGGER trg_check_class_years
BEFORE INSERT ON Lop
FOR EACH ROW
BEGIN
    IF NEW.NamBatDau >= NEW.NamKetThuc THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Năm bắt đầu phải nhỏ hơn năm kết thúc';
    END IF;
END;

-- 2. Đảm bảo tuổi của giáo viên nằm trong khoảng 22 đến 55
CREATE TRIGGER trg_check_teacher_age
BEFORE INSERT ON GiaoVien
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.NgaySinh, CURDATE()) NOT BETWEEN 22 AND 55 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tuổi giáo viên phải từ 22 đến 55';
    END IF;
END;

-- 3. Đảm bảo mỗi giáo viên chỉ quản lý tối đa 3 giáo viên khác
CREATE TRIGGER trg_check_teacher_management
BEFORE INSERT ON GiaoVien
FOR EACH ROW
BEGIN
    DECLARE count_managed INT;
    SELECT COUNT(*) INTO count_managed FROM GiaoVien WHERE MaQuanLy = NEW.MaQuanLy;
    IF count_managed >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mỗi giáo viên chỉ được quản lý tối đa ba giáo viên khác';
    END IF;
END;

-- 4. Học viên thuộc về một lớp chỉ được học những môn có mở ra cho lớp đó
CREATE TRIGGER trg_check_student_subject
BEFORE INSERT ON DangKyMonHoc
FOR EACH ROW
BEGIN
    DECLARE count_valid INT;
    SELECT COUNT(*) INTO count_valid FROM MoLop
    WHERE MoLop.MaLop = (SELECT MaLop FROM HocVien WHERE MaHV = NEW.MaHV)
    AND MoLop.MaMH = NEW.MaMH;
    IF count_valid = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Học viên chỉ được học những môn có mở ra cho lớp của mình';
    END IF;
END;

-- 5. Giáo viên chỉ được dạy những môn mà họ có khả năng giảng dạy
CREATE TRIGGER trg_check_teacher_subject
BEFORE INSERT ON GiangDay
FOR EACH ROW
BEGIN
    DECLARE count_valid INT;
    SELECT COUNT(*) INTO count_valid FROM ChuyenMon WHERE ChuyenMon.MaGV = NEW.MaGV AND ChuyenMon.MaMH = NEW.MaMH;
    IF count_valid = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Giáo viên chỉ được dạy những môn mà họ có khả năng giảng dạy';
    END IF;
END;