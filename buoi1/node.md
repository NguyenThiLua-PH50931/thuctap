**Bài tập: Phân tích hiệu quả chiến dịch Affiliate Marketing bằng PHP**
Một công ty triển khai chiến dịch affiliate marketing để quảng bá sản phẩm và yêu cầu xây dựng chương trình PHP nhằm phân tích dữ liệu chiến dịch. Chương trình cần tính toán doanh thu, chi phí hoa hồng, lợi nhuận dựa trên dữ liệu đầu vào, được thực thi trong môi trường PHP (ví dụ: XAMPP), sử dụng cú pháp chuẩn và bao gồm chú thích giải thích các bước tính toán (doanh thu, hoa hồng, lợi nhuận).

**Yêu cầu kỹ thuật**
Dữ liệu đầu vào:
Các biến lưu trữ trực tiếp trong code
Số lượng đơn hàng (integer).
Giá sản phẩm (float).
Tên sản phẩm (string).
Trạng thái chiến dịch (đang chạy/kết thúc, boolean).
Danh sách đơn hàng (array).
Chuyển đổi kiểu dữ liệu nếu cần (ví dụ: chuỗi "150" thành integer).

**Dữ liệu mẫu:**
Tên chiến dịch: "Spring Sale 2025".
Số lượng đơn hàng: 150.
Giá sản phẩm: 99.99 USD.
Tỷ lệ hoa hồng: 20%.
Loại sản phẩm: "Thời trang".
Trạng thái: Kết thúc (true).
Danh sách đơn hàng: ít nhất 5 đơn (ví dụ: "ID001" => 99.99, "ID002" => 49.99, ...).

**Công thức tính toán:**
Doanh thu = Giá sản phẩm × Số lượng đơn hàng.
Chi phí hoa hồng = Doanh thu × Tỷ lệ hoa hồng.
Lợi nhuận = Doanh thu - Chi phí hoa hồng - Thuế VAT.

**Hằng số:**
Tỷ lệ hoa hồng: 20% (const COMMISSION_RATE = 0.2).
Thuế VAT: 10% (const VAT_RATE = 0.1).

**Xử lý logic:**
Sử dụng toán tử so sánh và logic để:
Đánh giá trạng thái chiến dịch.
Xác định hiệu quả:
Lợi nhuận > 0: "Chiến dịch thành công".
Lợi nhuận = 0: "Chiến dịch hòa vốn".
Lợi nhuận < 0: "Chiến dịch thất bại".
Dựa trên loại sản phẩm (Điện tử, Thời trang, Gia dụng), hiển thị thông báo phù hợp (ví dụ: "Sản phẩm Thời trang có doanh thu ổn định").

**Sử dụng vòng lặp:**
for hoặc while để tính tổng doanh thu từ danh sách đơn hàng.
foreach để hiển thị chi tiết từng đơn (ID và giá trị).

**Công cụ hỗ trợ:**
Magic constants: __FILE__ (tên file), __LINE__ (dòng code) để debug.
Đầu ra:
Hiển thị bằng echo, print, và print_r (dùng print_r cho mảng đơn hàng).
Kết quả bao gồm:
Tên chiến dịch và trạng thái.
Tổng doanh thu, chi phí hoa hồng, lợi nhuận (sau khi trừ VAT).
Đánh giá hiệu quả chiến dịch.
Chi tiết từng đơn hàng.
Thông báo mẫu: "Chiến dịch Spring Sale 2025 đã kết thúc với lợi nhuận: [số tiền] USD".

**Mục tiêu**
Chương trình cần cung cấp phân tích chính xác, dễ hiểu, hỗ trợ đánh giá hiệu quả chiến dịch affiliate marketing dựa trên dữ liệu thực tế, với mã nguồn được chú thích rõ ràng để đảm bảo tính minh bạch và dễ bảo trì.
