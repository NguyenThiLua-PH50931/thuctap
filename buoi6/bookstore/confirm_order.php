<?php
session_start();
if (!isset($_SESSION['cart']) || !isset($_SESSION['customer'])) {
    die("Không có đơn hàng nào. <a href='index.php'>Quay lại</a>");
}

$cart = $_SESSION['cart'];
$customer = $_SESSION['customer'];
$total = array_sum(array_map(fn($item) => $item['quantity'] * $item['price'], $cart));
?>
<!DOCTYPE html>
<html>
<head><title>Xác nhận đơn hàng</title></head>
<body>
<h2>Đơn hàng của bạn</h2>
<table border="1">
<tr><th>Tên sách</th><th>Đơn giá</th><th>Số lượng</th><th>Thành tiền</th></tr>
<?php foreach ($cart as $item): ?>
<tr>
    <td><?= htmlspecialchars($item['title']) ?></td>
    <td><?= number_format($item['price']) ?></td>
    <td><?= $item['quantity'] ?></td>
    <td><?= number_format($item['price'] * $item['quantity']) ?></td>
</tr>
<?php endforeach; ?>
</table>
<p><strong>Tổng thanh toán: </strong><?= number_format($total) ?>đ</p>
<p><strong>Email:</strong> <?= htmlspecialchars($customer['email']) ?></p>
<p><strong>Điện thoại:</strong> <?= htmlspecialchars($customer['phone']) ?></p>
<p><strong>Địa chỉ:</strong> <?= htmlspecialchars($customer['address']) ?></p>
<p><strong>Thời gian đặt:</strong> <?= date('Y-m-d H:i:s') ?></p>
</body>
</html>
