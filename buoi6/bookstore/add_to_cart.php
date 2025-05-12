<?php
session_start();

function sanitize_input($value, $filter, $options = []) {
    return filter_input(INPUT_POST, $value, $filter, $options);
}

$email = sanitize_input('email', FILTER_VALIDATE_EMAIL);
$phone = sanitize_input('phone', FILTER_VALIDATE_REGEXP, [
    'options' => ['regexp' => '/^[0-9]{9,11}$/']
]);
$address = sanitize_input('address', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$book = sanitize_input('book_title', FILTER_SANITIZE_STRING);
$quantity = sanitize_input('quantity', FILTER_VALIDATE_INT);

$prices = ['Clean Code' => 150000, 'Design Patterns' => 200000];
$price = $prices[$book] ?? 0;

if (!$email || !$phone || !$quantity || !$book || $price === 0) {
    die("Dữ liệu không hợp lệ. <a href='index.php'>Quay lại</a>");
}

setcookie('customer_email', $email, time() + 7*24*60*60); // 7 ngày

// Lưu vào session
$_SESSION['cart'] = $_SESSION['cart'] ?? [];
$found = false;
foreach ($_SESSION['cart'] as &$item) {
    if ($item['title'] === $book) {
        $item['quantity'] += $quantity;
        $found = true;
        break;
    }
}
if (!$found) {
    $_SESSION['cart'][] = ['title' => $book, 'quantity' => $quantity, 'price' => $price];
}

$_SESSION['customer'] = ['email' => $email, 'phone' => $phone, 'address' => $address];

// Ghi file JSON
$order = [
    'customer_email' => $email,
    'products' => $_SESSION['cart'],
    'total_amount' => array_sum(array_map(fn($item) => $item['quantity'] * $item['price'], $_SESSION['cart'])),
    'created_at' => date('Y-m-d H:i:s')
];

try {
    if (!file_put_contents('cart_data.json', json_encode($order, JSON_PRETTY_PRINT))) {
        throw new Exception("Không thể ghi file cart_data.json");
    }
} catch (Exception $e) {
    file_put_contents('error_log.txt', $e->getMessage() . "\n", FILE_APPEND);
    die("Đã xảy ra lỗi khi lưu giỏ hàng. <a href='index.php'>Thử lại</a>");
}

header('Location: confirm_order.php');
