-- 0. (Tùy chọn) Tạo cơ sở dữ liệu mới và sử dụng
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- 1. Tạo bảng Categories
CREATE TABLE Categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL
);

-- 2. Tạo bảng Products
CREATE TABLE Products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  category_id INT,
  price DECIMAL(10,2),
  stock_quantity INT,
  created_at DATETIME,
  FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- 3. Tạo bảng Orders
CREATE TABLE Orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  order_date DATETIME,
  status VARCHAR(20)
);

-- 4. Tạo bảng OrderItems
CREATE TABLE OrderItems (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 5. Tạo chỉ mục trên bảng Orders (status + order_date)
CREATE INDEX idx_orders_status_orderdate ON Orders(status, order_date DESC);

-- 6. Tạo composite index trên bảng OrderItems (order_id + product_id)
CREATE INDEX idx_orderitems_orderid_productid ON OrderItems(order_id, product_id);

-- 7. Truy vấn tối ưu lấy thông tin đơn hàng đã giao (shipped)
SELECT 
    o.order_id,
    o.user_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
WHERE o.status = 'Shipped'
ORDER BY o.order_date DESC;

-- 8. So sánh hiệu suất JOIN vs Subquery
-- Truy vấn JOIN:
SELECT p.product_id, p.name, c.name AS category_name
FROM Products p
JOIN Categories c ON p.category_id = c.category_id;

-- Truy vấn Subquery:
SELECT p.product_id, p.name,
       (SELECT name FROM Categories WHERE category_id = p.category_id) AS category_name
FROM Products p;

-- 9. Lấy 10 sản phẩm mới nhất trong danh mục "Electronics", stock_quantity > 0
SELECT p.product_id, p.name, p.price, p.stock_quantity, p.created_at
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
WHERE c.name = 'Electronics'
  AND p.stock_quantity > 0
ORDER BY p.created_at DESC
LIMIT 10;

-- 10. Tạo Covering Index cho truy vấn lọc theo category_id và sắp xếp theo price
CREATE INDEX idx_products_category_price_name ON Products(category_id, price, name, product_id);

-- Truy vấn sử dụng Covering Index
SELECT product_id, name, price 
FROM Products 
WHERE category_id = 3 
ORDER BY price ASC 
LIMIT 20;

-- 12. Truy vấn tách bước: lọc đơn hàng có sản phẩm đắt tiền (>1M), sau đó tính tổng số lượng
CREATE TEMPORARY TABLE ExpensiveOrders AS
SELECT DISTINCT order_id
FROM OrderItems
WHERE unit_price > 1000000;

SELECT SUM(quantity) AS total_quantity
FROM OrderItems
WHERE order_id IN (SELECT order_id FROM ExpensiveOrders);

-- 13. Truy vấn top 5 sản phẩm bán chạy nhất trong 30 ngày gần nhất
SELECT p.product_id, p.name, SUM(oi.quantity) AS total_sold
FROM OrderItems oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.order_date >= NOW() - INTERVAL 30 DAY
  AND o.status = 'Shipped'
GROUP BY p.product_id, p.name
ORDER BY total_sold DESC
LIMIT 5;
