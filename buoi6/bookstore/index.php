<?php
session_start();

// Lưu tên/email bằng cookie (7 ngày)
$customer_email = $_COOKIE['customer_email'] ?? '';
?>
<!DOCTYPE html>
<html>
<head><title>Giỏ hàng sách</title></head>
<body>
<h2>Chọn sách</h2>
<form action="add_to_cart.php" method="POST">
  <label>Sách:</label>
  <select name="book_title">
    <option value="Clean Code">Clean Code - 150000đ</option>
    <option value="Design Patterns">Design Patterns - 200000đ</option>
  </select><br>

  <label>Số lượng:</label>
  <input type="number" name="quantity" required><br><br>

  <h3>Thông tin nhận hàng</h3>
  <label>Email:</label>
  <input type="email" name="email" value="<?= htmlspecialchars($customer_email) ?>" required><br><br>

  <label>Số điện thoại:</label>
  <input type="text" name="phone" required><br><br>

  <label>Địa chỉ:</label>
  <textarea name="address" required></textarea><br><br>

  <button type="submit">Thêm vào giỏ hàng</button>
</form><br>

<a href="confirm_order.php">Xác nhận đặt hàng</a> | 
<a href="clear_cart.php">Xóa giỏ hàng</a>
</body>
</html>
