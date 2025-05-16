<?php
require '../db.php';
$q = "%" . $_GET['q'] . "%";
$stmt = $conn->prepare("SELECT name, price FROM products WHERE name LIKE ?");
$stmt->execute([$q]);
$products = $stmt->fetchAll();
foreach ($products as $p) {
    echo "<p>{$p['name']} - {$p['price']}đ</p>";
}
?>