-- 1. Tạo cơ sở dữ liệu OnlineLearning
CREATE DATABASE IF NOT EXISTS OnlineLearning;

-- 2. Sử dụng cơ sở dữ liệu OnlineLearning
USE OnlineLearning;

-- 3. Tạo bảng Students
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- 4. Tạo bảng Courses
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price INT CHECK (price >= 0)
);

-- 5. Tạo bảng Enrollments
CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enroll_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES Students(student_id),
    CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
-- 6. Tạo VIEW StudentCourseView hiển thị sinh viên và tên khóa học đã đăng ký
CREATE VIEW StudentCourseView AS
SELECT 
    s.student_id,
    s.full_name,
    c.course_id,
    c.title AS course_title,
    e.enroll_date,
    e.status
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id;

-- 7. Tạo INDEX trên cột title của bảng Courses để tối ưu tìm kiếm
CREATE INDEX idx_course_title ON Courses(title);

-- 8. Xóa bảng Enrollments nếu không còn cần nữa
-- DROP TABLE IF EXISTS Enrollments;

-- 9. Xóa cơ sở dữ liệu OnlineLearning nếu không còn dùng nữa
-- DROP DATABASE IF EXISTS OnlineLearning;
