<?php

// Dữ liệu giả định
$employees = [
    ['id' => 101, 'name' => 'Nguyễn Thị Lụa', 'base_salary' => 5000000],
    ['id' => 102, 'name' => 'Nguyễn Hữu Tráng', 'base_salary' => 6000000],
    ['id' => 103, 'name' => 'Nguyễn Hữu Minh Khôi', 'base_salary' => 5500000],
];

$timesheet = [
    101 => ['2025-03-01', '2025-03-02', '2025-03-04', '2025-03-05'],
    102 => ['2025-03-01', '2025-03-03', '2025-03-04'],
    103 => ['2025-03-02', '2025-03-03', '2025-03-04', '2025-03-05', '2025-03-06'],
];

$adjustments = [
    101 => ['allowance' => 500000, 'deduction' => 200000],
    102 => ['allowance' => 300000, 'deduction' => 100000],
    103 => ['allowance' => 400000, 'deduction' => 150000],
];

define('WORKING_DAYS', 22);

// 1. Tính số ngày công
$working_days = array_map(function ($days) {
    return count($days); // => dùng count() và array_map()
}, $timesheet);

// 2. Tính lương
$net_salaries = array_map(function ($employee) use ($working_days, $adjustments) {
    $id = $employee['id'];
    $work_days = $working_days[$id] ?? 0;
    $base_salary = $employee['base_salary'];
    $allowance = $adjustments[$id]['allowance'] ?? 0;
    $deduction = $adjustments[$id]['deduction'] ?? 0;

    $salary = round(($base_salary / WORKING_DAYS) * $work_days + $allowance - $deduction);
    return $salary;
}, $employees);

// 3. Tạo báo cáo tổng hợp bảng lương

$payroll = array_map(function ($employee) use ($working_days, $adjustments, $net_salaries) {
    $id = $employee['id'];
    $name = $employee['name'];
    $base_salary = $employee['base_salary'];
    $days = $working_days[$id] ?? 0;
    $allowance = $adjustments[$id]['allowance'] ?? 0;
    $deduction = $adjustments[$id]['deduction'] ?? 0;
    $net_salary = $net_salaries[array_search($employee, $GLOBALS['employees'])];

    return compact('id', 'name', 'days', 'base_salary', 'allowance', 'deduction', 'net_salary');
}, $employees);




// 4. Tìm nhân viên có ngày công cao nhất và thấp nhất
$sorted_keys = array_keys($working_days);
$sorted_days = $working_days;
asort($sorted_days); // tăng dần
$min_id = array_key_first($sorted_days);
$max_id = array_key_last($sorted_days);

function getEmployeeNameById($id, $employees)
{
    foreach ($employees as $e) {
        if ($e['id'] === $id) return $e['name'];
    }
    return '';
}

// 5. Cập nhật dữ liệu nhân viên và chấm công
$new_employees = [
    ['id' => 104, 'name' => 'Phạm Văn D', 'base_salary' => 5800000],
];
$employees = array_merge($employees, $new_employees); // array_merge()

// Thêm ngày công mới cho nhân viên 101
array_push($timesheet[101], '2025-03-06');  // thêm cuối
array_unshift($timesheet[101], '2025-03-01'); // thêm đầu
array_pop($timesheet[101]); // xoá cuối
array_shift($timesheet[101]); // xoá đầu

// 6. Lọc nhân viên có ngày công ≥ 4
$filtered_employees = array_filter($employees, function ($employee) use ($working_days) {
    return ($working_days[$employee['id']] ?? 0) >= 4;
});

// 7. Kiểm tra điều kiện logic
$check_date = '2025-03-03';
$has_worked = in_array($check_date, $timesheet[102]);
$has_adjustment = array_key_exists(101, $adjustments);

// 8. Làm sạch dữ liệu chấm công
foreach ($timesheet as $id => &$days) {
    $days = array_unique($days); // loại bỏ trùng lặp
}
unset($days);

// Tính tổng quỹ lương
$total_salary = array_sum($net_salaries);

// In kết quả:
echo "<h3>BẢNG LƯƠNG THÁNG 05/2025</h3>";
echo "<table border='1' cellpadding='8' cellspacing='0' style='border-collapse: collapse; text-align: center;'>";
echo "<thead style='background-color: #f2f2f2;'>
        <tr>
            <th>Mã NV</th>
            <th>Họ tên</th>
            <th>Ngày công</th>
            <th>Lương cơ bản</th>
            <th>Phụ cấp</th>
            <th>Khấu trừ</th>
            <th>Lương</th>
        </tr>
      </thead>";
echo "<tbody>";

foreach ($payroll as $p) {
    echo "<tr>
            <td>{$p['id']}</td>
            <td>{$p['name']}</td>
            <td>{$p['days']}</td>
            <td>" . number_format($p['base_salary']) . "</td>
            <td>" . number_format($p['allowance']) . "</td>
            <td>" . number_format($p['deduction']) . "</td>
            <td><strong>" . number_format($p['net_salary']) . "</strong></td>
        </tr>";
}

echo "</tbody></table>";


// Tổng kết
echo "<br>Tổng quỹ lương tháng 03/2025: " . number_format($total_salary) . " VND<br>";
echo "Nhân viên làm nhiều nhất: " . getEmployeeNameById($max_id, $employees) . " (" . $working_days[$max_id] . " ngày công)<br>";
echo "Nhân viên làm ít nhất: " . getEmployeeNameById($min_id, $employees) . " (" . $working_days[$min_id] . " ngày công)<br>";

// Lọc nhân viên đủ điều kiện thưởng
echo "<br>Danh sách nhân viên đủ điều kiện xét thưởng:<br>";
foreach ($filtered_employees as $e) {
    echo "- " . $e['name'] . " (" . $working_days[$e['id']] . " ngày công)<br>";
}

// Kiểm tra logic
echo "<br>Nguyễn Thị Lụa có đi làm vào ngày $check_date: " . ($has_worked ? 'Có' : 'Không') . "<br>";
echo "Thông tin phụ cấp của nhân viên 101 tồn tại: " . ($has_adjustment ? 'Có' : 'Không') . "<br>";
