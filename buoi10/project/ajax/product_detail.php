<?php
require '../db.php';
$id = $_GET['id'];
$stmt = $conn->prepare("SELECT * FROM products WHERE id = ?");
$stmt->execute([$id]);
$product = $stmt->fetch();
echo "<h3>{$product['name']}</h3><p>{$product['description']}</p><p>Giá: {$product['price']}</p><p>Tồn kho: {$product['stock']}</p>";
?>
