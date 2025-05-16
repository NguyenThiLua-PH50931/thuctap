<?php
session_start();
$id = $_POST['id'];
$_SESSION['cart'][$id] = ($_SESSION['cart'][$id] ?? 0) + 1;
$total = array_sum($_SESSION['cart']);
echo json_encode(["success" => true, "cartCount" => $total]);
?>