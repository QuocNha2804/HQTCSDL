--câu 2
-- SESSION 1
USE abc;
BEGIN TRAN;
UPDATE Accounts SET balance = 9999 WHERE AccountID = 101;
-- KHÔNG COMMIT
---

--câu 3
SELECT * FROM Accounts WHERE AccountID = 101;
-- Kết quả: balance = 1000
BEGIN TRAN;
UPDATE Accounts SET balance = 800 WHERE AccountID = 101;
-- chưa commit
SELECT * FROM Accounts WHERE AccountID = 101;
-- Kết quả: balance = 800
COMMIT;
--commit lại
---câu 4, cập nhật lại balance thành 1000 trước

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRAN;
SELECT * FROM Accounts WHERE AccountID = 101;
--- balance 1000
UPDATE Accounts SET balance = 800 WHERE AccountID = 101;
-- cập nhật nhưng chưa commit
-- CLIENT A
SELECT * FROM Accounts WHERE AccountID = 101;
-- Kết quả: balance = 800
COMMIT;
--câu 5
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN;

-- Trừ 100 từ tài khoản 101
UPDATE Accounts 
SET balance = balance - 100 
WHERE AccountID = 101;

-- Cộng 100 vào tài khoản 202
UPDATE Accounts 
SET balance = balance + 100 
WHERE AccountID = 202;

COMMIT;
--câu6
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;

-- Giảm 100 từ account 101
UPDATE Accounts 
SET balance = balance - 100 
WHERE AccountID = 101;

-- Tăng 100 cho account 202
UPDATE Accounts 
SET balance = balance + 100 
WHERE AccountID = 202;

-- Chưa COMMIT (đợi B)
ROLLBACK;

SELECT * FROM Accounts;
COMMIT;


--câu7
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;
SELECT * FROM Accounts WHERE balance > 1000;

SELECT * FROM Accounts WHERE balance > 1000;
COMMIT;
