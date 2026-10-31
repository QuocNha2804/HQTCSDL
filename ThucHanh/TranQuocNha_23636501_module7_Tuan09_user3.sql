--câu 2
USE abc;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM Accounts WHERE AccountID = 101;
-- Kết quả: thấy balance = 9999 (dù chưa commit) vì đang sử dụng read uncommited
-- SESSION 2
USE abc;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM Accounts WHERE AccountID = 101;
-- Kết quả: query sẽ chờ cho đến khi user2 COMMIT hoặc ROLLBACK


--câu 3

SELECT * FROM Accounts WHERE AccountID = 101;
-- Kết quả: balance = 1000
BEGIN TRAN;
UPDATE Accounts SET balance = 500 WHERE AccountID = 101;
-- chờ, chưa chạy được
SELECT * FROM Accounts WHERE AccountID = 101;
-- chạy update lại, kết quả: balance = 500
COMMIT;
--commit lại
---không biết user2 đã giảm xuống 800, lost update


---câu 4, cập nhật lại balance thành 1000 trước

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRAN;
SELECT * FROM Accounts WHERE AccountID = 101;
--- balance 1000

UPDATE Accounts SET balance = 500 WHERE AccountID = 101;
-- không cập nhật được vì bị khóa ở bên user 2, khi nào user 2 commit và nó chưa timeout thì chạy được

--câu 5
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN;

-- Trừ 200 từ tài khoản 202
UPDATE Accounts 
SET balance = balance - 200 
WHERE AccountID = 202;

-- Cộng 200 vào tài khoản 101
UPDATE Accounts 
SET balance = balance + 200 
WHERE AccountID = 101;

COMMIT;


--câu6
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM Accounts;
COMMIT;


--câu7
INSERT INTO Accounts (AccountID, balance) VALUES (304, 3000);
COMMIT;
