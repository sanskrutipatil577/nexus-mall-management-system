-- ====================================================================
-- MALL MANAGEMENT SYSTEM - DATABASE SCHEMA (MySQL 8.0+ / MariaDB)
-- Mini Project for DBMS Coursework
-- ====================================================================

DROP DATABASE IF EXISTS mall_management_db;
CREATE DATABASE mall_management_db;
USE mall_management_db;

-- 1. CUSTOMER & MEMBERSHIP
CREATE TABLE CUSTOMER (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE MEMBERSHIP (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    membership_type ENUM('Regular', 'Silver', 'Gold', 'Platinum') NOT NULL DEFAULT 'Regular',
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    points INT NOT NULL DEFAULT 0,
    status ENUM('Active', 'Suspended', 'Expired') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_membership_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE
);

-- 2. SHOP, TENANT & LEASE
CREATE TABLE SHOP (
    shop_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    contact_no VARCHAR(20)
);

CREATE TABLE TENANT (
    tenant_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_name VARCHAR(100) NOT NULL,
    contact_no VARCHAR(20) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE LEASE (
    lease_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    tenant_id INT NOT NULL,
    lease_start DATE NOT NULL,
    lease_end DATE NOT NULL,
    monthly_rent DECIMAL(10,2) NOT NULL,
    lease_status ENUM('Active', 'Expired', 'Terminated', 'Pending Renewal') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_lease_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE,
    CONSTRAINT fk_lease_tenant FOREIGN KEY (tenant_id) REFERENCES TENANT(tenant_id) ON DELETE CASCADE
);

-- 3. PRODUCT & OFFER
CREATE TABLE PRODUCT (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_product_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

CREATE TABLE OFFER (
    offer_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    offer_name VARCHAR(100) NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL CHECK(discount_percentage BETWEEN 0 AND 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT fk_offer_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

-- 4. PURCHASE, PURCHASE_DETAIL, PAYMENT, OFFER_USAGE
CREATE TABLE PURCHASE (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    shop_id INT NOT NULL,
    purchase_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_purchase_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_purchase_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id)
);

CREATE TABLE PURCHASE_DETAIL (
    purchase_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK(unit_price >= 0),
    discount DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pd_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE,
    CONSTRAINT fk_pd_product FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
);

CREATE TABLE PAYMENT (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT NOT NULL UNIQUE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'UPI', 'Net Banking') NOT NULL,
    payment_status ENUM('Completed', 'Pending', 'Failed', 'Refunded') NOT NULL DEFAULT 'Completed',
    CONSTRAINT fk_payment_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

CREATE TABLE OFFER_USAGE (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    offer_id INT NOT NULL,
    customer_id INT NOT NULL,
    purchase_id INT NOT NULL,
    used_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ou_offer FOREIGN KEY (offer_id) REFERENCES OFFER(offer_id),
    CONSTRAINT fk_ou_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_ou_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

-- 5. PARKING
CREATE TABLE VEHICLE (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type ENUM('2-Wheeler', '4-Wheeler', 'EV') NOT NULL,
    CONSTRAINT fk_vehicle_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);

CREATE TABLE PARKING_SLOT (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    floor ENUM('B1', 'B2', 'B3') NOT NULL,
    slot_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('2-Wheeler', '4-Wheeler', 'EV') NOT NULL,
    status ENUM('Available', 'Occupied', 'Reserved', 'Maintenance') NOT NULL DEFAULT 'Available'
);

CREATE TABLE PARKING_ENTRY (
    entry_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    slot_id INT NOT NULL,
    entry_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exit_time TIMESTAMP NULL,
    parking_fee DECIMAL(8,2) DEFAULT 0,
    CONSTRAINT fk_pe_vehicle FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    CONSTRAINT fk_pe_slot FOREIGN KEY (slot_id) REFERENCES PARKING_SLOT(slot_id)
);

-- 6. EVENT
CREATE TABLE EVENT (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100) NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE EVENT_REGISTRATION (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    customer_id INT NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'Cancelled') NOT NULL DEFAULT 'Registered',
    UNIQUE KEY uq_event_cust (event_id, customer_id),
    CONSTRAINT fk_er_event FOREIGN KEY (event_id) REFERENCES EVENT(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_er_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE
);

-- 7. EMPLOYEE, COMPLAINT & MAINTENANCE
CREATE TABLE EMPLOYEE (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department ENUM('Security', 'Maintenance', 'Customer Service', 'Housekeeping', 'Operations', 'Management') NOT NULL,
    designation VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE COMPLAINT (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    complaint_type ENUM('Cleanliness', 'Noise', 'Service', 'Staff Behavior', 'Facilities', 'Parking', 'Security', 'Billing') NOT NULL,
    description TEXT NOT NULL,
    complaint_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'In Progress', 'Resolved', 'Dismissed') NOT NULL DEFAULT 'Pending',
    priority ENUM('Low', 'Medium', 'High', 'Urgent') NOT NULL DEFAULT 'Medium',
    resolution_date TIMESTAMP NULL,
    CONSTRAINT fk_comp_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

CREATE TABLE COMPLAINT_ASSIGNMENT (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    employee_id INT NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status ENUM('Assigned', 'In Progress', 'Completed') NOT NULL DEFAULT 'Assigned',
    CONSTRAINT fk_ca_complaint FOREIGN KEY (complaint_id) REFERENCES COMPLAINT(complaint_id) ON DELETE CASCADE,
    CONSTRAINT fk_ca_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

CREATE TABLE MAINTENANCE_REQUEST (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    reported_by_customer_id INT NULL,
    issue_type ENUM('Electrical', 'HVAC / AC', 'Plumbing', 'Escalator / Elevator', 'Structural', 'Lighting', 'Cleaning & Sanitation') NOT NULL,
    description TEXT NOT NULL,
    request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'In Progress', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    completion_date TIMESTAMP NULL,
    CONSTRAINT fk_mr_customer FOREIGN KEY (reported_by_customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);

CREATE TABLE MAINTENANCE_ASSIGNMENT (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    employee_id INT NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status ENUM('Assigned', 'In Progress', 'Completed') NOT NULL DEFAULT 'Assigned',
    CONSTRAINT fk_ma_request FOREIGN KEY (request_id) REFERENCES MAINTENANCE_REQUEST(request_id) ON DELETE CASCADE,
    CONSTRAINT fk_ma_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

-- TRIGGERS
DELIMITER //

CREATE TRIGGER trg_mysql_reduce_stock
AFTER INSERT ON PURCHASE_DETAIL
FOR EACH ROW
BEGIN
    UPDATE PRODUCT 
    SET stock_quantity = stock_quantity - NEW.quantity 
    WHERE product_id = NEW.product_id;
END;
//

CREATE TRIGGER trg_mysql_award_points
AFTER INSERT ON PAYMENT
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'Completed' THEN
        UPDATE MEMBERSHIP 
        SET points = points + FLOOR(NEW.amount / 10),
            membership_type = CASE 
                WHEN (points + FLOOR(NEW.amount / 10)) >= 1000 THEN 'Platinum'
                WHEN (points + FLOOR(NEW.amount / 10)) >= 400 THEN 'Gold'
                WHEN (points + FLOOR(NEW.amount / 10)) >= 150 THEN 'Silver'
                ELSE membership_type
            END
        WHERE customer_id = (SELECT customer_id FROM PURCHASE WHERE purchase_id = NEW.purchase_id);
    END IF;
END;
//

CREATE TRIGGER trg_mysql_occupy_slot
AFTER INSERT ON PARKING_ENTRY
FOR EACH ROW
BEGIN
    UPDATE PARKING_SLOT SET status = 'Occupied' WHERE slot_id = NEW.slot_id;
END;
//

CREATE TRIGGER trg_mysql_free_slot
AFTER UPDATE ON PARKING_ENTRY
FOR EACH ROW
BEGIN
    IF NEW.exit_time IS NOT NULL AND OLD.exit_time IS NULL THEN
        UPDATE PARKING_SLOT SET status = 'Available' WHERE slot_id = NEW.slot_id;
    END IF;
END;
//

DELIMITER ;
