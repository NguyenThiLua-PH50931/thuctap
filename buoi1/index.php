<?php
// 1.Hằng số:
const hoa_hong = 0.20; // Tỷ lệ hoa hồng (20%)
const thue_VAT = 0.10; 

// 2.Dữ liệu đầu vào
$ten_chien_dich = "Summer Sale 2025"; // Tên chiến dịch
$so_luong_don_hang = (int)"150"; // Ép kiểu từ chuỗi sang số nguyên
$gia_san_pham = 99.99; // Giá sản phẩm (USD)
$loai_san_pham = "Thời trang"; // Loại sản phẩm
$trang_thai_chien_dich = true; // Trạng thái chiến dịch (true = kết thúc)

// 3.Danh sách đơn hàng
$don_hang = [
    "ID001" => 99.99,
    "ID002" => 49.99,
    "ID003" => 149.99,
    "ID004" => 79.99,
    "ID005" => 199.99
];

// Kiểm tra trạng thái chiến dịch
if ($trang_thai_chien_dich) {
    echo  "Chiến dịch $ten_chien_dich đã kết thúc<br><br>";

    // Hiển thị mảng đơn hàng bằng print_r
    echo "Danh sách đơn hàng (dùng print_r):<br>";
    echo "<pre>";
    print_r($don_hang);
    echo "</pre><br>";

    // Tính toán doanh thu bằng foreach
    $tong_doanh_thu = 0;
    foreach ($don_hang as $gia_don_hang) {
        $tong_doanh_thu += $gia_don_hang;
    }

    // Tính toán doanh thu bằng for (yêu cầu thêm)
    $tong_doanh_thu_for = 0;
    $keys = array_keys($don_hang);
    for ($i = 0; $i < count($keys); $i++) {
        $tong_doanh_thu_for += $don_hang[$keys[$i]];
    }

    // Tính toán chi phí hoa hồng
    $chi_phi_hoa_hong = $tong_doanh_thu * hoa_hong;

    // Tính toán thuế VAT
    $thue_vat = $tong_doanh_thu * thue_VAT;

    // Tính toán lợi nhuận
    $loi_nhuan = $tong_doanh_thu - $chi_phi_hoa_hong - $thue_vat;

    // Hiển thị kết quả
    echo "Thông tin chiến dịch: $ten_chien_dich<br>";
    echo "Số lượng đơn hàng: $so_luong_don_hang<br>";
    echo "Giá sản phẩm trung bình: " . round($gia_san_pham, 2) . " USD<br>";
    echo "Tổng doanh thu (foreach): " . round($tong_doanh_thu, 2) . " USD<br>";
    echo "Tổng doanh thu (for): " . round($tong_doanh_thu_for, 2) . " USD<br>";
    echo "Chi phí hoa hồng: " . round($chi_phi_hoa_hong, 2) . " USD<br>";
    echo "Thuế VAT: " . round($thue_vat, 2) . " USD<br>";
    echo "Lợi nhuận sau thuế: " . round($loi_nhuan, 2) . " USD<br><br>";

    // Đánh giá hiệu quả chiến dịch
    if ($loi_nhuan > 0) {
        echo "Chiến dịch thành công<br><br>";
    } elseif ($loi_nhuan == 0) {
        echo "Chiến dịch hòa vốn<br><br>";
    } else {
        echo "Chiến dịch thất bại<br><br>";
    }

    // Thông báo về loại sản phẩm
    switch ($loai_san_pham) {
        case "Điện tử":
            echo "Sản phẩm Điện tử có doanh thu ổn định.<br>";
            break;
        case "Thời trang":
            echo "Sản phẩm Thời trang có doanh thu ổn định.<br>";
            break;
        case "Gia dụng":
            echo "Sản phẩm Gia dụng có doanh thu ổn định.<br>";
            break;
        default:
            echo "Sản phẩm không xác định.<br>";
    }

    // Chi tiết từng đơn hàng
    echo "Chi tiết các đơn hàng:<br>";
    foreach ($don_hang as $id => $gia) {
        echo "Đơn hàng $id: " . round($gia, 2) . " USD<br>";
    }
    echo "<br>";

    // Debug
    echo "Debug: File này đang được thực thi từ: " . __FILE__ . "<br>";
    echo "Debug: Dòng mã này: " . __LINE__ . "<br>";

} else {
    echo "Chiến dịch '$ten_chien_dich' vẫn đang chạy";
}
?>
