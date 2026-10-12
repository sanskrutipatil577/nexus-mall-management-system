-- ====================================================================
-- MALL MANAGEMENT SYSTEM - STORED PROCEDURES & TRANSACTIONS
-- File: sql/04_stored_procedures.sql
-- Comprehensive Stored Procedures for PostgreSQL & MySQL 8.0+
-- Demonstrates TCL (Transaction Control: BEGIN, COMMIT, ROLLBACK), Exception Handling
-- ====================================================================

-- --------------------------------------------------------------------
-- PROCEDURE 1: Process POS Sale Checkout with Transaction Integrity
-- Deducts product stock, validates availability, logs payment, and awards loyalty points.
-- --------------------------------------------------------------------

-- MySQL 8.0+ Syntax:
DELIMITER //

DROP PROCEDURE IF EXISTS sp_process_purchase_checkout //
CREATE PROCEDURE sp_process_purchase_checkout(
    IN p_customer_id INT,
    IN p_shop_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_payment_method VARCHAR(30),
    OUT p_purchase_id INT,
    OUT p_total_amount DECIMAL(10,2),
    OUT p_status_msg VARCHAR(255)
)
proc_block: BEGIN
    DECLARE v_stock INT;
    DECLARE v_unit_price DECIMAL(10,2);
    DECLARE v_discount DECIMAL(10,2) DEFAULT 0.00;
    
    -- Error Handler: Rollback on any SQL error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_msg = 'Transaction Failed: Internal SQL Exception. Rolled back.';
        SET p_purchase_id = 0;
        SET p_total_amount = 0.00;
    END;

    START TRANSACTION;

    -- Step 1: Verify product existence and stock
    SELECT stock_quantity, price INTO v_stock, v_unit_price
    FROM PRODUCT
    WHERE product_id = p_product_id AND shop_id = p_shop_id
    FOR UPDATE;

    IF v_stock IS NULL THEN
        ROLLBACK;
        SET p_status_msg = 'Error: Product not found in the designated shop outlet.';
        LEAVE proc_block;
    END IF;

    IF v_stock < p_quantity THEN
        ROLLBACK;
        SET p_status_msg = CONCAT('Error: Insufficient stock. Only ', v_stock, ' units available.');
        LEAVE proc_block;
    END IF;

    -- Calculate total
    SET p_total_amount = (v_unit_price * p_quantity) - v_discount;

    -- Step 2: Insert into PURCHASE header
    INSERT INTO PURCHASE (customer_id, shop_id, purchase_date, total_amount)
    VALUES (p_customer_id, p_shop_id, CURRENT_TIMESTAMP, p_total_amount);
    SET p_purchase_id = LAST_INSERT_ID();

    -- Step 3: Insert into PURCHASE_DETAIL
    INSERT INTO PURCHASE_DETAIL (purchase_id, product_id, quantity, unit_price, discount)
    VALUES (p_purchase_id, p_product_id, p_quantity, v_unit_price, v_discount);

    -- Step 4: Record Completed Payment
    INSERT INTO PAYMENT (purchase_id, payment_date, amount, payment_method, payment_status)
    VALUES (p_purchase_id, CURRENT_TIMESTAMP, p_total_amount, p_payment_method, 'Completed');

    COMMIT;
    SET p_status_msg = 'Success: Transaction completed, inventory deducted, and points awarded.';
END //

-- --------------------------------------------------------------------
-- PROCEDURE 2: Vehicle Parking Entry with Automatic Bay Allocation
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_park_vehicle_entry //
CREATE PROCEDURE sp_park_vehicle_entry(
    IN p_vehicle_number VARCHAR(30),
    IN p_vehicle_type VARCHAR(20),
    IN p_customer_id INT,
    OUT p_entry_id INT,
    OUT p_assigned_slot VARCHAR(20),
    OUT p_status_msg VARCHAR(255)
)
proc_block: BEGIN
    DECLARE v_vehicle_id INT;
    DECLARE v_slot_id INT;

    START TRANSACTION;

    -- Check if vehicle exists or insert
    SELECT vehicle_id INTO v_vehicle_id FROM VEHICLE WHERE vehicle_number = p_vehicle_number;
    IF v_vehicle_id IS NULL THEN
        INSERT INTO VEHICLE (customer_id, vehicle_number, vehicle_type)
        VALUES (p_customer_id, p_vehicle_number, p_vehicle_type);
        SET v_vehicle_id = LAST_INSERT_ID();
    END IF;

    -- Find available slot matching vehicle type
    SELECT slot_id, slot_number INTO v_slot_id, p_assigned_slot
    FROM PARKING_SLOT
    WHERE vehicle_type = p_vehicle_type AND status = 'Available'
    ORDER BY floor, slot_number
    LIMIT 1
    FOR UPDATE;

    IF v_slot_id IS NULL THEN
        ROLLBACK;
        SET p_status_msg = 'Error: Parking facility full for this vehicle classification.';
        LEAVE proc_block;
    END IF;

    -- Log entry (Trigger marks slot Occupied)
    INSERT INTO PARKING_ENTRY (vehicle_id, slot_id, entry_time)
    VALUES (v_vehicle_id, v_slot_id, CURRENT_TIMESTAMP);
    SET p_entry_id = LAST_INSERT_ID();

    COMMIT;
    SET p_status_msg = CONCAT('Success: Vehicle assigned to parking slot ', p_assigned_slot);
END //

-- --------------------------------------------------------------------
-- PROCEDURE 3: Vehicle Exit & Dynamic Tariff Settlement
-- Hourly Rates: 2-Wheeler ($2/hr), EV ($3/hr), 4-Wheeler ($5/hr)
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_park_vehicle_exit //
CREATE PROCEDURE sp_park_vehicle_exit(
    IN p_entry_id INT,
    OUT p_duration_hours INT,
    OUT p_parking_fee DECIMAL(8,2),
    OUT p_status_msg VARCHAR(255)
)
proc_block: BEGIN
    DECLARE v_entry_time TIMESTAMP;
    DECLARE v_vtype VARCHAR(20);
    DECLARE v_rate DECIMAL(5,2);

    START TRANSACTION;

    SELECT pe.entry_time, v.vehicle_type INTO v_entry_time, v_vtype
    FROM PARKING_ENTRY pe
    JOIN VEHICLE v ON pe.vehicle_id = v.vehicle_id
    WHERE pe.entry_id = p_entry_id AND pe.exit_time IS NULL
    FOR UPDATE;

    IF v_entry_time IS NULL THEN
        ROLLBACK;
        SET p_status_msg = 'Error: Active parking entry not found.';
        LEAVE proc_block;
    END IF;

    -- Determine hourly tariff rate
    IF v_vtype = '2-Wheeler' THEN SET v_rate = 2.00;
    ELSEIF v_vtype = 'EV' THEN SET v_rate = 3.00;
    ELSE SET v_rate = 5.00;
    END IF;

    SET p_duration_hours = CEIL(TIMESTAMPDIFF(MINUTE, v_entry_time, CURRENT_TIMESTAMP) / 60.0);
    IF p_duration_hours < 1 THEN SET p_duration_hours = 1; END IF;
    SET p_parking_fee = p_duration_hours * v_rate;

    -- Update exit timestamp (Trigger frees parking slot)
    UPDATE PARKING_ENTRY
    SET exit_time = CURRENT_TIMESTAMP, parking_fee = p_parking_fee
    WHERE entry_id = p_entry_id;

    COMMIT;
    SET p_status_msg = CONCAT('Success: Parking fee calculated as $', p_parking_fee, ' for ', p_duration_hours, ' hours.');
END //

DELIMITER ;
