<?php

// Dữ liệu người dùng
$users = [
    1 => ['name' => 'Alice', 'referrer_id' => null],
    2 => ['name' => 'Bob', 'referrer_id' => 1],
    3 => ['name' => 'Charlie', 'referrer_id' => 2],
    4 => ['name' => 'David', 'referrer_id' => 3],
    5 => ['name' => 'Eva', 'referrer_id' => 1],
];

// Dữ liệu đơn hàng
$orders = [
    ['order_id' => 101, 'user_id' => 4, 'amount' => 200.0],
    ['order_id' => 102, 'user_id' => 3, 'amount' => 150.0],
    ['order_id' => 103, 'user_id' => 5, 'amount' => 300.0],
];

// Tỷ lệ hoa hồng mặc định
function getCommissionRates(): array {
    return [
        1 => 0.10,
        2 => 0.05,
        3 => 0.02,
    ];
}

// Biến toàn cục để lưu hoa hồng
$commissionSummary = [];
$commissionDetails = [];

// Hàm đệ quy để lấy danh sách referrers theo cấp
function getReferrers(int $userId, array $users, int $level = 1, int $maxLevel = 3): array {
    if ($level > $maxLevel || !isset($users[$userId]['referrer_id']) || $users[$userId]['referrer_id'] === null) {
        return [];
    }

    $referrerId = $users[$userId]['referrer_id'];
    return array_merge(
        [$level => $referrerId],
        getReferrers($referrerId, $users, $level + 1, $maxLevel)
    );
}

// Hàm tính hoa hồng
function calculateCommission(array $orders, array $users, array $commissionRates): array {
    global $commissionSummary, $commissionDetails;

    foreach ($orders as $order) {
        $userId = $order['user_id'];
        $amount = $order['amount'];
        $orderId = $order['order_id'];

        // Lấy chuỗi giới thiệu
        $referrers = getReferrers($userId, $users);

        // Dùng hàm ẩn danh xử lý từng cấp
        array_walk($referrers, function($referrerId, $level) use ($orderId, $userId, $amount, $commissionRates, $users) {
            global $commissionSummary, $commissionDetails;

            $rate = $commissionRates[$level] ?? 0;
            $commission = $amount * $rate;

            // Cộng dồn vào tổng
            if (!isset($commissionSummary[$referrerId])) {
                $commissionSummary[$referrerId] = 0.0;
            }
            $commissionSummary[$referrerId] += $commission;

            // Ghi chi tiết
            $commissionDetails[] = [
                'referrer_id' => $referrerId,
                'referrer_name' => $users[$referrerId]['name'],
                'buyer_id' => $userId,
                'buyer_name' => $users[$userId]['name'],
                'order_id' => $orderId,
                'level' => $level,
                'commission' => $commission
            ];
        });
    }

    return ['summary' => $commissionSummary, 'details' => $commissionDetails];
}

// Hàm xử lý nhiều đơn hàng với variadic
function reportCommission(array $orders, array $users, ...$rates): void {
    $commissionRates = empty($rates) ? getCommissionRates() : $rates[0];

    $result = calculateCommission($orders, $users, $commissionRates);

    echo "TỔNG HOA HỒNG:<br>";
    foreach ($result['summary'] as $userId => $total) {
        echo "{$users[$userId]['name']} nhận được: " . number_format($total, 2) . " USD<br>";
    }

    echo "<br>CHI TIẾT HOA HỒNG:<br>";
    foreach ($result['details'] as $detail) {
        echo "- {$detail['referrer_name']} nhận được " . number_format($detail['commission'], 2) .
            " USD từ đơn hàng {$detail['order_id']} do {$detail['buyer_name']} mua (cấp {$detail['level']})<br>";
    }
}

// Chạy chương trình
reportCommission($orders, $users);

?>
