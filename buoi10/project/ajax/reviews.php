<?php
require '../db.php';
$id = $_GET['id'];
$stmt = $conn->prepare("SELECT user, comment FROM reviews WHERE product_id = ?");
$stmt->execute([$id]);
$reviews = $stmt->fetchAll();
foreach ($reviews as $r) {
    echo "<p><b>{$r['user']}:</b> {$r['comment']}</p>";
}
?>