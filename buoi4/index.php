<?php
session_start(); // Superglobal: $_SESSION

// Biến toàn cục lưu tổng thu và chi
$GLOBALS['tong_thu'] = 0;
$GLOBALS['tong_chi'] = 0;

// Mảng chứa từ khóa nhạy cảm
$tu_khoa_nhay_cam = ['nợ xấu', 'vay nóng'];
$canh_bao = [];

// Khởi tạo mảng lưu giao dịch nếu chưa có
if (!isset($_SESSION['transactions'])) {
    $_SESSION['transactions'] = [];
}

// Xử lý khi form được gửi
if ($_SERVER['REQUEST_METHOD'] === 'POST') { // Superglobal: $_SERVER
    $transaction_name = trim($_POST['transaction_name']);
    $amount = trim($_POST['amount']);
    $type = $_POST['type'] ?? '';
    $note = trim($_POST['note'] ?? ''); // Sửa: thêm trim() để loại bỏ khoảng trắng
    $date = trim($_POST['date']);

    $errors = [];

    // Tên không có ký tự đặc biệt
    if (!preg_match("/^[\p{L}0-9 ]+$/u", $transaction_name)) {
        $errors[] = "Tên giao dịch không được chứa ký tự đặc biệt.";
    }

    // Số tiền là số dương
    if (!preg_match('/^\d+(\.\d+)?$/', $amount) || $amount <= 0) {
        $errors[] = "Số tiền phải là số dương và không có chữ.";
    }

    // Ngày đúng định dạng dd/mm/yyyy
    if (!preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $date)) {
        $errors[] = "Ngày phải đúng định dạng dd/mm/yyyy.";
    }

    // Kiểm tra loại giao dịch
    if (!in_array($type, ['thu', 'chi'])) {
        $errors[] = "Loại giao dịch không hợp lệ.";
    }

    // Kiểm tra từ khóa nhạy cảm trong ghi chú
    foreach ($tu_khoa_nhay_cam as $kw) {
        if (stripos($note, $kw) !== false || stripos($transaction_name, $kw) !== false) {
            $errors[] = "Thông tin có chứa từ khóa nhạy cảm: \"$kw\"";
            break;
        }
    }

    // Nếu không có lỗi, lưu vào session
    if (empty($errors)) {
        $gd = [
            'name' => $transaction_name,
            'amount' => (float)$amount,
            'type' => $type,
            'note' => $note,
            'date' => $date,
        ];

        $_SESSION['transactions'][] = $gd;
    }
}

//  Luôn cập nhật tổng thu/chi sau mỗi thao tác, kể cả khi có lỗi
$GLOBALS['tong_thu'] = 0;
$GLOBALS['tong_chi'] = 0;

foreach ($_SESSION['transactions'] as $t) {
    if ($t['type'] === 'thu') {
        $GLOBALS['tong_thu'] += $t['amount'];
    } elseif ($t['type'] === 'chi') {
        $GLOBALS['tong_chi'] += $t['amount'];
    }
}
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý giao dịch tài chính</title>
</head>
<body>
    <h2>Nhập giao dịch</h2>
    <form method="POST" action="<?= htmlspecialchars($_SERVER['PHP_SELF']) ?>"> <!-- Superglobal: $_SERVER -->
        <label>Tên giao dịch: <input type="text" name="transaction_name" required></label><br><br>
        <label>Số tiền: <input type="number" name="amount" required></label><br><br>
        <label>Loại giao dịch:
            <input type="radio" name="type" value="thu" required> Thu
            <input type="radio" name="type" value="chi"> Chi
        </label><br><br>
        <label>Ghi chú: <input type="text" name="note"></label><br><br>
        <label>Ngày thực hiện: <input type="text" name="date" placeholder="dd/mm/yyyy" required></label><br><br>
        <button type="submit">Lưu giao dịch</button>
    </form>

    <?php if (!empty($errors)): ?>
        <div style="color: red;">
            <h4>Lỗi:</h4>
            <ul>
                <?php foreach ($errors as $e) echo "<li>$e</li>"; ?>
            </ul>
        </div>
    <?php endif; ?>

    <?php if (!empty($_SESSION['transactions'])): ?>
        <h3>Danh sách giao dịch</h3>
        <table border="1" cellpadding="6" cellspacing="0">
            <thead>
                <tr>
                    <th>Tên</th>
                    <th>Số tiền</th>
                    <th>Loại</th>
                    <th>Ghi chú</th>
                    <th>Ngày</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($_SESSION['transactions'] as $t): ?>
                    <tr>
                        <td><?= htmlspecialchars($t['name']) ?></td>
                        <td><?= number_format($t['amount']) ?></td>
                        <td><?= $t['type'] ?></td>
                        <td><?= htmlspecialchars($t['note']) ?></td>
                        <td><?= $t['date'] ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <h4>Thống kê:</h4>
        <p>Tổng thu: <?= number_format($GLOBALS['tong_thu']) ?> VND</p>
        <p>Tổng chi: <?= number_format($GLOBALS['tong_chi']) ?> VND</p>
        <p><strong>Số dư: <?= number_format($GLOBALS['tong_thu'] - $GLOBALS['tong_chi']) ?> VND</strong></p>
    <?php endif; ?>
</body>
</html>
