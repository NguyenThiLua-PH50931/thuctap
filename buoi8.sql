-- 1. Tạo database và chọn database
CREATE DATABASE IF NOT EXISTS social_network;
USE social_network;


-- 2. Tạo bảng Users
CREATE TABLE IF NOT EXISTS Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 3. Tạo bảng Posts
CREATE TABLE IF NOT EXISTS Posts (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content TEXT,
  likes INT DEFAULT 0,
  hashtags VARCHAR(255),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


-- 4. Tạo bảng Follows
CREATE TABLE IF NOT EXISTS Follows (
  follower_id INT NOT NULL,
  followee_id INT NOT NULL,
  PRIMARY KEY (follower_id, followee_id),
  FOREIGN KEY (follower_id) REFERENCES Users(user_id),
  FOREIGN KEY (followee_id) REFERENCES Users(user_id)
);


-- 5. Tạo bảng PostViews (lớn ~100 triệu dòng)
CREATE TABLE IF NOT EXISTS PostViews (
  view_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  viewer_id INT NOT NULL,
  view_time DATETIME NOT NULL,
  FOREIGN KEY (post_id) REFERENCES Posts(post_id),
  FOREIGN KEY (viewer_id) REFERENCES Users(user_id)
) ENGINE=InnoDB;


-- 6. Tạo bảng Hashtags (chuẩn hóa hashtags)
CREATE TABLE IF NOT EXISTS Hashtags (
  hashtag_id INT AUTO_INCREMENT PRIMARY KEY,
  tag VARCHAR(50) UNIQUE NOT NULL
);


-- 7. Tạo bảng PostHashtags (mối quan hệ nhiều - nhiều giữa Posts và Hashtags)
CREATE TABLE IF NOT EXISTS PostHashtags (
  post_id INT NOT NULL,
  hashtag_id INT NOT NULL,
  PRIMARY KEY(post_id, hashtag_id),
  FOREIGN KEY(post_id) REFERENCES Posts(post_id),
  FOREIGN KEY(hashtag_id) REFERENCES Hashtags(hashtag_id)
);


-- 8. Tạo bảng PostLikes để lưu trạng thái like của user với post (dùng cho stored procedure)
CREATE TABLE IF NOT EXISTS PostLikes (
  user_id INT NOT NULL,
  post_id INT NOT NULL,
  liked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(user_id, post_id),
  FOREIGN KEY(user_id) REFERENCES Users(user_id),
  FOREIGN KEY(post_id) REFERENCES Posts(post_id)
);


-- 9. Tạo bảng phi chuẩn hóa tổng hợp lượt like và view theo ngày (PopularPostsDaily)
CREATE TABLE IF NOT EXISTS PopularPostsDaily (
  post_id INT NOT NULL,
  date DATE NOT NULL,
  total_likes INT DEFAULT 0,
  total_views INT DEFAULT 0,
  PRIMARY KEY(post_id, date),
  FOREIGN KEY(post_id) REFERENCES Posts(post_id)
);


-- 10. Thêm dữ liệu mẫu vào Users và Posts
INSERT INTO Users (username, created_at) VALUES
('alice', NOW()),
('bob', NOW()),
('charlie', NOW());

INSERT INTO Posts (user_id, content, likes, hashtags, created_at) VALUES
(1, 'Post about fitness and health', 25, 'fitness,health', NOW()),
(2, 'Another post about fitness', 10, 'fitness', NOW()),
(3, 'Random post without fitness', 5, 'random', DATE_SUB(NOW(), INTERVAL 1 DAY));


-- 11. Truy vấn lấy 10 bài viết được thích nhiều nhất hôm nay
SELECT post_id, user_id, content, likes, created_at
FROM Posts
WHERE DATE(created_at) = CURDATE()
ORDER BY likes DESC
LIMIT 10;


-- 12. Tạo bảng MEMORY để cache kết quả top liked posts hôm nay (chạy 1 lần)
CREATE TABLE IF NOT EXISTS TopLikedPostsToday (
  post_id INT PRIMARY KEY,
  user_id INT,
  content TEXT,
  likes INT,
  created_at DATETIME
) ENGINE=MEMORY;


-- 13. Cập nhật cache bảng MEMORY (chạy định kỳ)
REPLACE INTO TopLikedPostsToday
SELECT post_id, user_id, content, likes, created_at
FROM Posts
WHERE DATE(created_at) = CURDATE()
ORDER BY likes DESC
LIMIT 10;


-- 14. EXPLAIN ANALYZE cho truy vấn tìm hashtags
EXPLAIN ANALYZE
SELECT * FROM Posts
WHERE hashtags LIKE '%fitness%'
ORDER BY created_at DESC
LIMIT 20;


-- 15. Phân vùng bảng PostViews theo tháng
ALTER TABLE PostViews
PARTITION BY RANGE (YEAR(view_time)*100 + MONTH(view_time)) (
  PARTITION p202301 VALUES LESS THAN (202302),
  PARTITION p202302 VALUES LESS THAN (202303),
  PARTITION p202303 VALUES LESS THAN (202304),
  PARTITION p202304 VALUES LESS THAN (202305),
  PARTITION p202305 VALUES LESS THAN (202306),
  PARTITION p202306 VALUES LESS THAN (202307),
  PARTITION pMax VALUES LESS THAN MAXVALUE
);


-- 16. Truy vấn thống kê số lượt xem mỗi tháng trong 6 tháng gần nhất
SELECT 
  YEAR(view_time) AS year,
  MONTH(view_time) AS month,
  COUNT(*) AS views
FROM PostViews
WHERE view_time >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY year, month
ORDER BY year DESC, month DESC;


-- 17. Ví dụ thay đổi kiểu dữ liệu (nếu muốn tối ưu)
ALTER TABLE PostViews MODIFY COLUMN view_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE Posts MODIFY COLUMN hashtags VARCHAR(100);
ALTER TABLE Posts MODIFY COLUMN created_at TIMESTAMP;


-- 18. Truy vấn Window Function tính tổng view mỗi bài viết và xếp hạng theo ngày, lấy top 3
WITH DailyViews AS (
  SELECT
    post_id,
    DATE(view_time) AS view_date,
    COUNT(*) AS total_views
  FROM PostViews
  GROUP BY post_id, view_date
),
RankedPosts AS (
  SELECT
    post_id,
    view_date,
    total_views,
    RANK() OVER (PARTITION BY view_date ORDER BY total_views DESC) AS rank
  FROM DailyViews
)
SELECT *
FROM RankedPosts
WHERE rank <= 3
ORDER BY view_date DESC, rank ASC;


-- 19. Stored procedure cập nhật lượt like khi user click like
DELIMITER //
CREATE PROCEDURE LikePost(IN p_user_id INT, IN p_post_id INT)
BEGIN
  START TRANSACTION;

  IF NOT EXISTS (
    SELECT 1 FROM PostLikes WHERE user_id = p_user_id AND post_id = p_post_id
  ) THEN
    INSERT INTO PostLikes(user_id, post_id, liked_at) VALUES (p_user_id, p_post_id, NOW());
    UPDATE Posts SET likes = likes + 1 WHERE post_id = p_post_id;
  END IF;

  COMMIT;
END//
DELIMITER ;


-- 20. Bật slow query log (thường thao tác ngoài MySQL client)
-- Ví dụ lệnh bật trong MySQL client (quyền SUPER cần có)
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL slow_query_log_file = '/var/log/mysql/mysql-slow.log';
SET GLOBAL long_query_time = 1;  -- log query chạy trên 1 giây


-- 21. Kích hoạt optimizer trace, chạy truy vấn và lấy trace
SET optimizer_trace="enabled=on";

SELECT p.post_id, p.content, u.username
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
WHERE p.created_at > '2025-01-01'
ORDER BY p.likes DESC
LIMIT 10;

SELECT * FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE\G

SET optimizer_trace="enabled=off";
