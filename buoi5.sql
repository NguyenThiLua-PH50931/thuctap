-- 1. Tạo bảng
CREATE TABLE IF NOT EXISTS Rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    type VARCHAR(20),
    status VARCHAR(20),
    price INT CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS Guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    status VARCHAR(20),
    CONSTRAINT fk_guest FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    CONSTRAINT fk_room FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

CREATE TABLE IF NOT EXISTS Invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    total_amount INT,
    generated_date DATE,
    CONSTRAINT fk_booking FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- 2. Stored Procedure MakeBooking
DELIMITER $$

CREATE PROCEDURE MakeBooking (
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE
)
BEGIN
    DECLARE room_status VARCHAR(20);
    DECLARE booking_conflict INT;

    SELECT status INTO room_status FROM Rooms WHERE room_id = p_room_id;

    IF room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room not found';
    ELSEIF room_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room is not available';
    END IF;

    SELECT COUNT(*) INTO booking_conflict
    FROM Bookings
    WHERE room_id = p_room_id
      AND status = 'Confirmed'
      AND (p_check_in < check_out AND p_check_out > check_in);

    IF booking_conflict > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking conflicts with existing bookings';
    ELSE
        INSERT INTO Bookings (guest_id, room_id, check_in, check_out, status)
        VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, 'Confirmed');

        UPDATE Rooms SET status = 'Occupied' WHERE room_id = p_room_id;
    END IF;

END$$

-- 3. Trigger after_booking_cancel
CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    -- Khai báo biến phải nằm đầu BEGIN trigger
    DECLARE cnt INT DEFAULT 0;

    IF NEW.status = 'Cancelled' AND OLD.status <> 'Cancelled' THEN

        SELECT COUNT(*) INTO cnt
        FROM Bookings
        WHERE room_id = NEW.room_id
          AND status = 'Confirmed'
          AND check_out > CURDATE();

        IF cnt = 0 THEN
            UPDATE Rooms SET status = 'Available' WHERE room_id = NEW.room_id;
        END IF;

    END IF;
END$$

-- 4. Stored Procedure GenerateInvoice
CREATE PROCEDURE GenerateInvoice (
    IN p_booking_id INT
)
BEGIN
    DECLARE nights INT;
    DECLARE price_per_night INT;
    DECLARE total_amount INT;
    DECLARE check_in_date DATE;
    DECLARE check_out_date DATE;
    DECLARE room INT;

    SELECT check_in, check_out, room_id
    INTO check_in_date, check_out_date, room
    FROM Bookings WHERE booking_id = p_booking_id;

    IF check_in_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking not found';
    END IF;

    SET nights = DATEDIFF(check_out_date, check_in_date);
    IF nights <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid check-in/check-out dates';
    END IF;

    SELECT price INTO price_per_night FROM Rooms WHERE room_id = room;

    SET total_amount = nights * price_per_night;

    INSERT INTO Invoices (booking_id, total_amount, generated_date)
    VALUES (p_booking_id, total_amount, CURDATE());
END$$

DELIMITER ;
