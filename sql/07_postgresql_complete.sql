-- ====================================================================
-- MALL MANAGEMENT SYSTEM - POSTGRESQL 15 / 16 / 17 / 18 COMPLETE SCRIPT
-- File: sql/07_postgresql_complete.sql
-- Drop-in PostgreSQL schema with DDL, Constraints, PL/pgSQL Triggers, and Views
-- ====================================================================

-- 1. EXTENSIONS & SCHEMA CLEANUP
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- 2. CUSTOMER & MEMBERSHIP
CREATE TABLE CUSTOMER (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE MEMBERSHIP (
    membership_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    membership_type VARCHAR(20) NOT NULL DEFAULT 'Regular' CHECK(membership_type IN ('Regular', 'Silver', 'Gold', 'Platinum')),
    join_date DATE NOT NULL DEFAULT CURRENT_DATE,
    points INT NOT NULL DEFAULT 0 CHECK(points >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK(status IN ('Active', 'Suspended', 'Expired')),
    CONSTRAINT fk_membership_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE
);

-- 3. SHOP, TENANT & LEASE
CREATE TABLE SHOP (
    shop_id SERIAL PRIMARY KEY,
    shop_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    contact_no VARCHAR(20)
);

CREATE TABLE TENANT (
    tenant_id SERIAL PRIMARY KEY,
    tenant_name VARCHAR(100) NOT NULL,
    contact_no VARCHAR(20) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE LEASE (
    lease_id SERIAL PRIMARY KEY,
    shop_id INT NOT NULL,
    tenant_id INT NOT NULL,
    lease_start DATE NOT NULL,
    lease_end DATE NOT NULL,
    monthly_rent NUMERIC(10,2) NOT NULL CHECK(monthly_rent >= 0),
    lease_status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK(lease_status IN ('Active', 'Expired', 'Terminated', 'Pending Renewal')),
    CONSTRAINT fk_lease_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE,
    CONSTRAINT fk_lease_tenant FOREIGN KEY (tenant_id) REFERENCES TENANT(tenant_id) ON DELETE CASCADE
);

-- 4. PRODUCT & OFFER
CREATE TABLE PRODUCT (
    product_id SERIAL PRIMARY KEY,
    shop_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK(price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK(stock_quantity >= 0),
    CONSTRAINT fk_product_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

CREATE TABLE OFFER (
    offer_id SERIAL PRIMARY KEY,
    shop_id INT NOT NULL,
    offer_name VARCHAR(100) NOT NULL,
    discount_percentage NUMERIC(5,2) NOT NULL CHECK(discount_percentage >= 0 AND discount_percentage <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT fk_offer_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

-- 5. PURCHASE, PURCHASE_DETAIL, PAYMENT & OFFER_USAGE
CREATE TABLE PURCHASE (
    purchase_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    shop_id INT NOT NULL,
    purchase_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK(total_amount >= 0),
    CONSTRAINT fk_purchase_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_purchase_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id)
);

CREATE TABLE PURCHASE_DETAIL (
    purchase_detail_id SERIAL PRIMARY KEY,
    purchase_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK(unit_price >= 0),
    discount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK(discount >= 0),
    CONSTRAINT fk_pd_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE,
    CONSTRAINT fk_pd_product FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
);

CREATE TABLE PAYMENT (
    payment_id SERIAL PRIMARY KEY,
    purchase_id INT NOT NULL UNIQUE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(10,2) NOT NULL CHECK(amount >= 0),
    payment_method VARCHAR(30) NOT NULL CHECK(payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'UPI', 'Net Banking')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Completed' CHECK(payment_status IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    CONSTRAINT fk_payment_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

CREATE TABLE OFFER_USAGE (
    usage_id SERIAL PRIMARY KEY,
    offer_id INT NOT NULL,
    customer_id INT NOT NULL,
    purchase_id INT NOT NULL,
    used_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ou_offer FOREIGN KEY (offer_id) REFERENCES OFFER(offer_id),
    CONSTRAINT fk_ou_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_ou_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

-- 6. PARKING
CREATE TABLE VEHICLE (
    vehicle_id SERIAL PRIMARY KEY,
    customer_id INT,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK(vehicle_type IN ('2-Wheeler', '4-Wheeler', 'EV')),
    CONSTRAINT fk_vehicle_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);

CREATE TABLE PARKING_SLOT (
    slot_id SERIAL PRIMARY KEY,
    floor VARCHAR(10) NOT NULL CHECK(floor IN ('B1', 'B2', 'B3')),
    slot_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK(vehicle_type IN ('2-Wheeler', '4-Wheeler', 'EV')),
    status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK(status IN ('Available', 'Occupied', 'Reserved', 'Maintenance'))
);

CREATE TABLE PARKING_ENTRY (
    entry_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    slot_id INT NOT NULL,
    entry_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exit_time TIMESTAMP,
    parking_fee NUMERIC(8,2) DEFAULT 0 CHECK(parking_fee >= 0),
    CONSTRAINT fk_pe_vehicle FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    CONSTRAINT fk_pe_slot FOREIGN KEY (slot_id) REFERENCES PARKING_SLOT(slot_id)
);

-- 7. EVENT
CREATE TABLE EVENT (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK(capacity > 0)
);

CREATE TABLE EVENT_REGISTRATION (
    registration_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL,
    customer_id INT NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status VARCHAR(20) NOT NULL DEFAULT 'Registered' CHECK(attendance_status IN ('Registered', 'Attended', 'Cancelled')),
    CONSTRAINT fk_er_event FOREIGN KEY (event_id) REFERENCES EVENT(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_er_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE,
    UNIQUE(event_id, customer_id)
);

-- 8. EMPLOYEE, COMPLAINT & MAINTENANCE
CREATE TABLE EMPLOYEE (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL CHECK(department IN ('Security', 'Maintenance', 'Customer Service', 'Housekeeping', 'Operations', 'Management')),
    designation VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE COMPLAINT (
    complaint_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    complaint_type VARCHAR(50) NOT NULL CHECK(complaint_type IN ('Cleanliness', 'Noise', 'Service', 'Staff Behavior', 'Facilities', 'Parking', 'Security', 'Billing')),
    description TEXT NOT NULL,
    complaint_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'In Progress', 'Resolved', 'Dismissed')),
    priority VARCHAR(20) NOT NULL DEFAULT 'Medium' CHECK(priority IN ('Low', 'Medium', 'High', 'Urgent')),
    resolution_date TIMESTAMP,
    CONSTRAINT fk_comp_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

CREATE TABLE COMPLAINT_ASSIGNMENT (
    assignment_id SERIAL PRIMARY KEY,
    complaint_id INT NOT NULL,
    employee_id INT NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    CONSTRAINT fk_ca_complaint FOREIGN KEY (complaint_id) REFERENCES COMPLAINT(complaint_id) ON DELETE CASCADE,
    CONSTRAINT fk_ca_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

CREATE TABLE MAINTENANCE_REQUEST (
    request_id SERIAL PRIMARY KEY,
    reported_by_customer_id INT,
    issue_type VARCHAR(50) NOT NULL CHECK(issue_type IN ('Electrical', 'HVAC / AC', 'Plumbing', 'Escalator / Elevator', 'Structural', 'Lighting', 'Cleaning & Sanitation')),
    description TEXT NOT NULL,
    request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    completion_date TIMESTAMP,
    CONSTRAINT fk_mr_customer FOREIGN KEY (reported_by_customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);

CREATE TABLE MAINTENANCE_ASSIGNMENT (
    assignment_id SERIAL PRIMARY KEY,
    request_id INT NOT NULL,
    employee_id INT NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    CONSTRAINT fk_ma_request FOREIGN KEY (request_id) REFERENCES MAINTENANCE_REQUEST(request_id) ON DELETE CASCADE,
    CONSTRAINT fk_ma_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

-- --------------------------------------------------------------------
-- PL/pgSQL TRIGGERS
-- --------------------------------------------------------------------

-- Trigger 1: Stock Reduction Function
CREATE OR REPLACE FUNCTION fn_trg_reduce_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE PRODUCT
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pg_reduce_stock
AFTER INSERT ON PURCHASE_DETAIL
FOR EACH ROW EXECUTE FUNCTION fn_trg_reduce_stock();

-- Trigger 2: Loyalty Points Function
CREATE OR REPLACE FUNCTION fn_trg_award_loyalty_points()
RETURNS TRIGGER AS $$
DECLARE
    v_cust_id INT;
    v_current_pts INT;
    v_added_pts INT;
    v_new_pts INT;
BEGIN
    IF NEW.payment_status = 'Completed' THEN
        SELECT customer_id INTO v_cust_id FROM PURCHASE WHERE purchase_id = NEW.purchase_id;
        v_added_pts := FLOOR(NEW.amount / 10);
        
        UPDATE MEMBERSHIP
        SET points = points + v_added_pts,
            membership_type = CASE 
                WHEN (points + v_added_pts) >= 1000 THEN 'Platinum'
                WHEN (points + v_added_pts) >= 400 THEN 'Gold'
                WHEN (points + v_added_pts) >= 150 THEN 'Silver'
                ELSE membership_type
            END
        WHERE customer_id = v_cust_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pg_award_loyalty
AFTER INSERT ON PAYMENT
FOR EACH ROW EXECUTE FUNCTION fn_trg_award_loyalty_points();

-- Trigger 3: Occupy Parking Slot
CREATE OR REPLACE FUNCTION fn_trg_occupy_slot()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE PARKING_SLOT SET status = 'Occupied' WHERE slot_id = NEW.slot_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pg_occupy_slot
AFTER INSERT ON PARKING_ENTRY
FOR EACH ROW EXECUTE FUNCTION fn_trg_occupy_slot();

-- Trigger 4: Release Parking Slot
CREATE OR REPLACE FUNCTION fn_trg_release_slot()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.exit_time IS NOT NULL AND OLD.exit_time IS NULL THEN
        UPDATE PARKING_SLOT SET status = 'Available' WHERE slot_id = NEW.slot_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pg_release_slot
AFTER UPDATE OF exit_time ON PARKING_ENTRY
FOR EACH ROW EXECUTE FUNCTION fn_trg_release_slot();
