<?php include 'includes/header.php'; ?>
<?php include 'includes/logger.php'; ?>
<?php include 'includes/upload.php'; ?>

<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? 'Không rõ hành động';
    $filename = null;

    if (!empty($_FILES['proof']['name'])) {
        $filename = handle_upload($_FILES['proof']);
    }

    write_log($action, $filename);
    echo "<p style='color: green;'>Đã ghi nhật ký thành công!</p>";
}
?>

<form method="POST" enctype="multipart/form-data">
    <label>Nhập hành động:</label>
    <input type="text" name="action" required>
    <br><br>
    <label>Minh chứng (ảnh/pdf):</label>
    <input type="file" name="proof">
    <br><br>
    <button type="submit">Ghi nhật ký</button>
</form>
<br>
<a href="view_log.php">Xem nhật ký theo ngày</a>
</body>
</html>
