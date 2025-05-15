<?php
require 'db.php';

echo "<style>
    table { border-collapse: collapse; width: 80%; margin-bottom: 30px; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background: #eee; }
    h2 { margin-top: 40px; }
</style>";

// 4.1 Thêm 5 sản phẩm mẫu
$products = [
    ['Động cơ A', 1500000, 10],
    ['Cảm biến B', 750000, 25],
    ['Bảng điều khiển C', 2200000, 5],
    ['Thiết bị đo D', 980000, 15],
    ['Bộ điều khiển E', 1850000, 7]
];

echo "<h2>4.1 Thêm 5 sản phẩm mẫu</h2>";
foreach ($products as $p) {
    $stmt = $pdo->prepare("INSERT INTO products (product_name, unit_price, stock_quantity, created_at) VALUES (?, ?, ?, NOW())");
    $stmt->execute($p);
    echo "Đã thêm sản phẩm ID: " . $pdo->lastInsertId() . "<br>";
}

// 4.3 Thêm 3 đơn hàng, mỗi đơn có 2-3 sản phẩm
$orderData = [
    ['2025-05-14', 'Công ty ABC', 'Giao nhanh'],
    ['2025-05-15', 'Công ty XYZ', 'Yêu cầu xuất hóa đơn'],
    ['2025-05-16', 'Công ty DEF', null]
];

echo "<h2>4.3 Thêm 3 đơn hàng với sản phẩm</h2>";
foreach ($orderData as $order) {
    $stmt = $pdo->prepare("INSERT INTO orders (order_date, customer_name, note) VALUES (?, ?, ?)");
    $stmt->execute($order);
    $orderId = $pdo->lastInsertId();
    echo "Đơn hàng ID: $orderId, Khách hàng: {$order[1]}<br>";
    
    $items = [
        [rand(1, 5), rand(1, 5)],
        [rand(1, 5), rand(1, 5)],
        [rand(1, 5), rand(1, 5)],
    ];
    shuffle($items);
    foreach (array_slice($items, 0, rand(2, 3)) as [$pid, $qty]) {
        $price = $pdo->query("SELECT unit_price FROM products WHERE id = $pid")->fetch()['unit_price'];
        $stmt = $pdo->prepare("INSERT INTO order_items (order_id, product_id, quantity, price_at_order_time) VALUES (?, ?, ?, ?)");
        $stmt->execute([$orderId, $pid, $qty, $price]);
        echo " — Thêm sản phẩm ID: $pid, Số lượng: $qty, Giá tại thời điểm đặt: $price<br>";
    }
}

// 4.4 Prepared Statement thêm sản phẩm
echo "<h2>4.4 Thêm sản phẩm mới bằng Prepared Statement</h2>";
function insertProduct($name, $price, $stock) {
    global $pdo;
    $stmt = $pdo->prepare("INSERT INTO products (product_name, unit_price, stock_quantity, created_at) VALUES (?, ?, ?, NOW())");
    $stmt->execute([$name, $price, $stock]);
    echo "Đã thêm sản phẩm: $name<br>";
}
insertProduct("Thiết bị mới X", 1999000, 8);

// Hàm hiển thị bảng sản phẩm
function displayProducts($title, $pdo, $sql, $params = []) {
    echo "<h2>$title</h2>";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$rows) {
        echo "Không có dữ liệu.<br>";
        return;
    }

    echo "<table><thead><tr>";
    foreach (array_keys($rows[0]) as $col) {
        echo "<th>$col</th>";
    }
    echo "</tr></thead><tbody>";
    foreach ($rows as $row) {
        echo "<tr>";
        foreach ($row as $val) {
            echo "<td>$val</td>";
        }
        echo "</tr>";
    }
    echo "</tbody></table>";
}

// 4.5 Hiển thị toàn bộ danh sách sản phẩm
displayProducts("4.5 Tất cả sản phẩm", $pdo, "SELECT * FROM products");

// 4.6 Lọc sản phẩm giá > 1.000.000
displayProducts("4.6 Sản phẩm có giá > 1.000.000", $pdo, "SELECT * FROM products WHERE unit_price > ?", [1000000]);

// 4.7 Hiển thị sản phẩm theo giá giảm dần
displayProducts("4.7 Sản phẩm theo giá giảm dần", $pdo, "SELECT * FROM products ORDER BY unit_price DESC");

// 4.8 Xóa sản phẩm theo ID
echo "<h2>4.8 Xóa sản phẩm theo ID</h2>";
$idToDelete = 1; // bạn thay ID nếu muốn
$stmt = $pdo->prepare("DELETE FROM products WHERE id = ?");
$stmt->execute([$idToDelete]);
echo "Đã xóa sản phẩm có ID = $idToDelete<br>";

// 4.9 Cập nhật giá và tồn kho sản phẩm
echo "<h2>4.9 Cập nhật giá và tồn kho sản phẩm</h2>";
$stmt = $pdo->prepare("UPDATE products SET unit_price = ?, stock_quantity = ? WHERE id = ?");
$stmt->execute([2000000, 12, 2]);
echo "Đã cập nhật sản phẩm ID = 2 với giá 2.000.000 và tồn kho 12<br>";

// 4.10 Lấy 5 sản phẩm mới nhất
displayProducts("4.10 5 sản phẩm mới nhất", $pdo, "SELECT * FROM products ORDER BY created_at DESC LIMIT 5");
?>
