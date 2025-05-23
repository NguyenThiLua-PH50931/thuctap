-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 23, 2025 at 03:31 PM
-- Server version: 8.0.30
-- PHP Version: 8.2.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bb5`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateInvoice` (IN `p_booking_id` INT)   BEGIN
    DECLARE v_check_in DATE;
    DECLARE v_check_out DATE;
    DECLARE v_price INT;
    DECLARE v_nights INT;
    DECLARE v_total_amount INT;

    -- Lấy thông tin đặt phòng và giá phòng
    SELECT b.check_in, b.check_out, r.price
    INTO v_check_in, v_check_out, v_price
    FROM Bookings b
    JOIN Rooms r ON b.room_id = r.room_id
    WHERE b.booking_id = p_booking_id;

    -- Tính số đêm lưu trú
    SET v_nights = DATEDIFF(v_check_out, v_check_in);

    IF v_nights <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày trả phòng phải sau ngày nhận phòng';
    END IF;

    -- Tính tổng tiền
    SET v_total_amount = v_nights * v_price;

    -- Tạo hóa đơn
    INSERT INTO Invoices (booking_id, total_amount, generated_date)
    VALUES (p_booking_id, v_total_amount, CURRENT_TIMESTAMP);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MakeBooking` (IN `p_guest_id` INT, IN `p_room_id` INT, IN `p_check_in` DATE, IN `p_check_out` DATE)   BEGIN
    DECLARE room_status VARCHAR(20);
    DECLARE conflict_count INT;

    -- Kiểm tra trạng thái phòng
    SELECT status INTO room_status FROM Rooms WHERE room_id = p_room_id;

    IF room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng không tồn tại';
    ELSEIF room_status != 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng không có sẵn';
    ELSE
        -- Kiểm tra trùng thời gian đặt phòng đã có
        SELECT COUNT(*) INTO conflict_count
        FROM Bookings
        WHERE room_id = p_room_id
          AND status = 'Confirmed'
          AND (
                (p_check_in BETWEEN check_in AND DATE_SUB(check_out, INTERVAL 1 DAY))
                OR (p_check_out BETWEEN DATE_ADD(check_in, INTERVAL 1 DAY) AND check_out)
                OR (check_in BETWEEN p_check_in AND DATE_SUB(p_check_out, INTERVAL 1 DAY))
             );

        IF conflict_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng đã được đặt trong thời gian này';
        ELSE
            -- Tạo bản ghi đặt phòng mới với trạng thái Confirmed
            INSERT INTO Bookings (guest_id, room_id, check_in, check_out, status)
            VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, 'Confirmed');

            -- Cập nhật trạng thái phòng thành Occupied
            UPDATE Rooms SET status = 'Occupied' WHERE room_id = p_room_id;
        END IF;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int NOT NULL,
  `guest_id` int NOT NULL,
  `room_id` int NOT NULL,
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `status` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `bookings`
--
DELIMITER $$
CREATE TRIGGER `after_booking_cancel` AFTER UPDATE ON `bookings` FOR EACH ROW BEGIN
    DECLARE count_confirmed INT;

    IF OLD.status != 'Cancelled' AND NEW.status = 'Cancelled' THEN

        SELECT COUNT(*) INTO count_confirmed
        FROM Bookings
        WHERE room_id = NEW.room_id
          AND status = 'Confirmed'
          AND check_out > CURDATE();

        IF count_confirmed = 0 THEN
            UPDATE Rooms SET status = 'Available' WHERE room_id = NEW.room_id;
        END IF;

    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `guests`
--

CREATE TABLE `guests` (
  `guest_id` int NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE `invoices` (
  `invoice_id` int NOT NULL,
  `booking_id` int NOT NULL,
  `total_amount` int NOT NULL,
  `generated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `room_id` int NOT NULL,
  `room_number` varchar(10) NOT NULL,
  `type` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `price` int NOT NULL
) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `guest_id` (`guest_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `guests`
--
ALTER TABLE `guests`
  ADD PRIMARY KEY (`guest_id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`invoice_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`room_id`),
  ADD UNIQUE KEY `room_number` (`room_number`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guests`
--
ALTER TABLE `guests`
  MODIFY `guest_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `invoice_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `room_id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`guest_id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`);

--
-- Constraints for table `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
