-- TẠO CÁC BẢNG
CREATE TABLE Candidates (
    candidate_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    years_exp INT,
    expected_salary INT
);

CREATE TABLE Jobs (
    job_id INT PRIMARY KEY,
    title VARCHAR(100),
    department VARCHAR(50),
    min_salary INT,
    max_salary INT
);

CREATE TABLE Applications (
    app_id INT PRIMARY KEY,
    candidate_id INT,
    job_id INT,
    apply_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    FOREIGN KEY (job_id) REFERENCES Jobs(job_id)
);

CREATE TABLE ShortlistedCandidates (
    candidate_id INT,
    job_id INT,
    selection_date DATE
);

-- CHÈN DỮ LIỆU MẪU
INSERT INTO Candidates VALUES
(1, 'Nguyen Van A', 'a@gmail.com', '0123456789', 2, 800),
(2, 'Tran Thi B', 'b@gmail.com', NULL, 5, 1500),
(3, 'Le Van C', 'c@gmail.com', '0987654321', 0, 500),
(4, 'Pham Thi D', 'd@gmail.com', '0111222333', 7, 2000);

INSERT INTO Jobs VALUES
(101, 'Backend Developer', 'IT', 700, 1500),
(102, 'Frontend Developer', 'IT', 800, 1800),
(103, 'HR Executive', 'HR', 500, 1000),
(104, 'Data Analyst', 'IT', 900, 1700),
(105, 'Sales Rep', 'Sales', 600, 1200);

INSERT INTO Applications VALUES
(1001, 1, 101, '2025-05-01', 'Accepted'),
(1002, 2, 103, '2025-05-03', 'Pending'),
(1003, 2, 102, '2025-05-05', 'Rejected'),
(1004, 3, 104, '2025-05-10', 'Accepted'),
(1005, 4, 105, '2025-05-12', 'Pending');

-- CÁC TRUY VẤN SQL THEO YÊU CẦU

-- 1. Tìm các ứng viên đã từng ứng tuyển vào ít nhất một công việc thuộc phòng ban "IT"
SELECT *
FROM Candidates c
WHERE EXISTS (
    -- Bước 1: Lọc công việc phòng ban IT mà ứng viên đã ứng tuyển
    SELECT 1
    FROM Applications a
    JOIN Jobs j ON a.job_id = j.job_id
    WHERE a.candidate_id = c.candidate_id
    AND j.department = 'IT'
);

-- 2. Liệt kê các công việc mà mức lương tối đa lớn hơn mức lương mong đợi của bất kỳ ứng viên nào
SELECT *
FROM Jobs
WHERE max_salary > ANY (
    SELECT expected_salary
    FROM Candidates
);

-- 3. Liệt kê các công việc mà mức lương tối thiểu lớn hơn mức lương mong đợi của tất cả ứng viên
SELECT *
FROM Jobs
WHERE min_salary > ALL (
    SELECT expected_salary
    FROM Candidates
);

-- 4. Chèn vào bảng ShortlistedCandidates những ứng viên có trạng thái ứng tuyển là 'Accepted'
INSERT INTO ShortlistedCandidates (candidate_id, job_id, selection_date)
SELECT candidate_id, job_id, CURRENT_DATE
FROM Applications
WHERE status = 'Accepted';

-- 5. Hiển thị ứng viên kèm đánh giá kinh nghiệm
SELECT
    full_name,
    years_exp,
    -- Bước 1: Phân loại theo số năm kinh nghiệm
    CASE
        WHEN years_exp < 1 THEN 'Fresher'
        WHEN years_exp BETWEEN 1 AND 3 THEN 'Junior'
        WHEN years_exp BETWEEN 4 AND 6 THEN 'Mid-level'
        ELSE 'Senior'
    END AS exp_level
FROM Candidates;

-- 6. Liệt kê ứng viên, thay số điện thoại NULL bằng 'Chưa cung cấp'
SELECT
    full_name,
    email,
    COALESCE(phone, 'Chưa cung cấp') AS phone
FROM Candidates;

-- 7. Tìm công việc có max_salary ≠ min_salary và max_salary ≥ 1000
SELECT *
FROM Jobs
WHERE max_salary != min_salary
AND max_salary >= 1000;

-- 8 Tìm các công việc có mức lương tối đa khác mức lương tối thiểu
-- và mức lương tối đa lớn hơn hoặc bằng 1000
SELECT *
FROM Jobs
WHERE max_salary != min_salary
AND max_salary >= 1000;
