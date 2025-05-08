<?php include 'includes/header.php'; ?>

<form method="GET">
    <label>Chọn ngày:</label>
    <input type="date" name="date" required>
    <button type="submit">Xem nhật ký</button>
</form>

<?php
if (!empty($_GET['date'])) {
    $date = $_GET['date'];
    $file = __DIR__ . "/logs/log_$date.txt";

    if (file_exists($file)) {
        echo "<h3>Nhật ký ngày $date</h3><ul>";
        $fh = fopen($file, 'r');
        while (!feof($fh)) {
            $line = fgets($fh);
            if (trim($line)) {
                // Màu đỏ nếu có "thất bại"
                $color = stripos($line, 'thất bại') !== false ? 'red' : 'black';
                echo "<li style='color: $color;'>$line</li>";
            }
        }
        fclose($fh);
        echo "</ul>";
    } else {
        echo "<p style='color: orange;'>Không có nhật ký cho ngày này.</p>";
    }
}
?>
</body>
</html>
