-- ================================
-- 1. TẠO CÁC BẢNG
-- ================================

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(100),
    referrer_id INT,
    FOREIGN KEY (referrer_id) REFERENCES Users(user_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(100),
    is_active BOOLEAN
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    status VARCHAR(50),
    order_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ================================
-- 2. CHÈN DỮ LIỆU MẪU
-- ================================

INSERT INTO Users (user_id, full_name, email, city, referrer_id) VALUES
(1, 'Nguyen Van A', 'a@gmail.com', 'Hanoi', NULL),
(2, 'Tran Thi B', 'b@gmail.com', 'Hanoi', 1),
(3, 'Le Van C', 'c@gmail.com', 'HCM', 1),
(4, 'Pham Thi D', 'd@gmail.com', 'Da Nang', NULL),
(5, 'Do Van E', 'e@gmail.com', 'Hanoi', 2),
(6, 'Hoang Thi F', 'f@gmail.com', 'HCM', NULL),
(7, 'Ngo Van G', 'g@gmail.com', 'Da Nang', NULL);

INSERT INTO Products (product_id, product_name, price, category, is_active) VALUES
(1, 'iPhone 14', 20000000, 'Điện thoại', 1),
(2, 'MacBook Air', 30000000, 'Laptop', 1),
(3, 'iPad', 10000000, 'Tablet', 1),
(4, 'Apple Watch', 8000000, 'Đồng hồ', 0),
(5, 'AirPods Pro', 5000000, 'Phụ kiện', 1),
(6, 'Galaxy S23', 18000000, 'Điện thoại', 1),
(7, 'Dell XPS', 28000000, 'Laptop', 1),
(8, 'Sony WH-1000XM4', 7000000, 'Phụ kiện', 0);

INSERT INTO Orders (order_id, user_id, status, order_date) VALUES
(1, 2, 'completed', '2023-06-01'),
(2, 3, 'pending', '2023-06-02'),
(3, 2, 'completed', '2023-06-03'),
(4, 4, 'cancelled', '2023-06-04'),
(5, 5, 'completed', '2023-06-05'),
(6, 6, 'completed', '2023-06-06'),
(7, 6, 'completed', '2023-06-07'),
(8, 7, 'completed', '2023-06-08');

INSERT INTO OrderItems (order_item_id, order_id, product_id, quantity) VALUES
(1, 1, 1, 1),
(2, 1, 5, 2),
(3, 2, 2, 1),
(4, 3, 4, 1),
(5, 3, 3, 1),
(6, 5, 6, 1),
(7, 5, 5, 2),
(8, 6, 7, 1),
(9, 7, 2, 1),
(10, 7, 5, 1),
(11, 8, 3, 1),
(12, 8, 5, 1);

-- ================================
-- 3. TRUY VẤN SQL THEO YÊU CẦU
-- ================================

-- 1. Tổng doanh thu từ đơn hàng completed, nhóm theo danh mục sản phẩm
SELECT 
    p.category,
    SUM(oi.quantity * p.price) AS total_revenue
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.category;

-- 2. Danh sách người dùng kèm tên người giới thiệu
SELECT 
    u.user_id,
    u.full_name,
    r.full_name AS referrer_name
FROM Users u
LEFT JOIN Users r ON u.referrer_id = r.user_id;

-- 3. Sản phẩm đã từng được đặt mua nhưng không còn active
SELECT DISTINCT 
    p.product_id,
    p.product_name
FROM Products p
JOIN OrderItems oi ON p.product_id = oi.product_id
WHERE p.is_active = 0;

-- 4. Người dùng chưa từng đặt đơn hàng nào
SELECT 
    u.user_id,
    u.full_name
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id
WHERE o.order_id IS NULL;

-- 5. Đơn hàng đầu tiên của từng người dùng
SELECT 
    user_id,
    MIN(order_id) AS first_order_id
FROM Orders
GROUP BY user_id;

-- 6. Tổng chi tiêu của mỗi người dùng
SELECT 
    u.user_id,
    u.full_name,
    SUM(oi.quantity * p.price) AS total_spent
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY u.user_id, u.full_name;

-- 7. Người dùng có tổng chi tiêu > 25 triệu
SELECT 
    u.user_id,
    u.full_name,
    SUM(oi.quantity * p.price) AS total_spent
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY u.user_id, u.full_name
HAVING SUM(oi.quantity * p.price) > 25000000;

-- 8. Tổng số đơn hàng và tổng doanh thu của từng thành phố
SELECT 
    u.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'completed' THEN oi.quantity * p.price ELSE 0 END) AS total_revenue
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id
LEFT JOIN OrderItems oi ON o.order_id = oi.order_id
LEFT JOIN Products p ON oi.product_id = p.product_id
GROUP BY u.city;

-- 9. Người dùng có ít nhất 2 đơn hàng completed
SELECT 
    u.user_id,
    u.full_name,
    COUNT(o.order_id) AS completed_orders
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
WHERE o.status = 'completed'
GROUP BY u.user_id, u.full_name
HAVING COUNT(o.order_id) >= 2;

-- 10. Đơn hàng có sản phẩm thuộc nhiều hơn 1 danh mục
SELECT 
    oi.order_id
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY oi.order_id
HAVING COUNT(DISTINCT p.category) > 1;

-- 11. Người dùng đã từng đặt hàng và người dùng được giới thiệu (UNION)
SELECT 
    u.user_id,
    u.full_name,
    'placed_order' AS source
FROM Users u
JOIN Orders o ON u.user_id = o.user_id

UNION

SELECT 
    u.user_id,
    u.full_name,
    'referred' AS source
FROM Users u
WHERE u.referrer_id IS NOT NULL;
