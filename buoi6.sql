-- 1. Tạo bảng Accounts (InnoDB)
CREATE TABLE IF NOT EXISTS Accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100),
    balance DECIMAL(15,2),
    status VARCHAR(20) CHECK (status IN ('Active', 'Frozen', 'Closed'))
) ENGINE=InnoDB;

-- 2. Tạo bảng Transactions (InnoDB)
CREATE TABLE IF NOT EXISTS Transactions (
    txn_id INT PRIMARY KEY AUTO_INCREMENT,
    from_account INT,
    to_account INT,
    amount DECIMAL(15,2),
    txn_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending')),
    FOREIGN KEY (from_account) REFERENCES Accounts(account_id),
    FOREIGN KEY (to_account) REFERENCES Accounts(account_id)
) ENGINE=InnoDB;

-- 3. Tạo bảng TxnAuditLogs (MyISAM)
CREATE TABLE IF NOT EXISTS TxnAuditLogs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    action VARCHAR(255),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM;

-- 4. Tạo bảng Referrals (cho CTE đệ quy)
CREATE TABLE IF NOT EXISTS Referrals (
    referrer_id INT,
    referee_id INT
);

-- 5. Stored Procedure TransferMoney
DELIMITER $$

CREATE PROCEDURE TransferMoney (
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE from_balance DECIMAL(15,2);
    DECLARE from_status, to_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO TxnAuditLogs(action) VALUES(CONCAT('Transfer failed from ', p_from_account, ' to ', p_to_account));
    END;

    START TRANSACTION;

    -- LOCK tài khoản theo thứ tự ID để chống deadlock
    IF p_from_account < p_to_account THEN
        SELECT balance, status INTO from_balance, from_status FROM Accounts WHERE account_id = p_from_account FOR UPDATE;
        SELECT status INTO to_status FROM Accounts WHERE account_id = p_to_account FOR UPDATE;
    ELSE
        SELECT status INTO to_status FROM Accounts WHERE account_id = p_to_account FOR UPDATE;
        SELECT balance, status INTO from_balance, from_status FROM Accounts WHERE account_id = p_from_account FOR UPDATE;
    END IF;

    IF from_status != 'Active' OR to_status != 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or both accounts are not active';
    END IF;

    IF from_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;

    -- Trừ và cộng tiền
    UPDATE Accounts SET balance = balance - p_amount WHERE account_id = p_from_account;
    UPDATE Accounts SET balance = balance + p_amount WHERE account_id = p_to_account;

    -- Ghi log giao dịch
    INSERT INTO Transactions(from_account, to_account, amount, status)
    VALUES(p_from_account, p_to_account, p_amount, 'Success');

    INSERT INTO TxnAuditLogs(action)
    VALUES(CONCAT('Transfer ', p_amount, ' from ', p_from_account, ' to ', p_to_account));

    COMMIT;
END$$

DELIMITER ;

-- 6. Ví dụ CTE đệ quy - liệt kê tất cả cấp dưới của 1 khách hàng (referrer_id = 1)
WITH RECURSIVE SubReferrals AS (
    SELECT referrer_id, referee_id, 1 AS level
    FROM Referrals
    WHERE referrer_id = 1

    UNION ALL

    SELECT r.referrer_id, r.referee_id, sr.level + 1
    FROM Referrals r
    INNER JOIN SubReferrals sr ON r.referrer_id = sr.referee_id
)
SELECT * FROM SubReferrals;

-- 7. CTE phân loại giao dịch theo mức so với trung bình
WITH AvgTxn AS (
    SELECT AVG(amount) AS avg_amount FROM Transactions
),
LabeledTxns AS (
    SELECT *,
        CASE
            WHEN amount > (SELECT avg_amount FROM AvgTxn) THEN 'High'
            WHEN amount = (SELECT avg_amount FROM AvgTxn) THEN 'Normal'
            ELSE 'Low'
        END AS amount_label
    FROM Transactions
)
SELECT * FROM LabeledTxns;
