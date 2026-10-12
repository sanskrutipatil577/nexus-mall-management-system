-- ====================================================================
-- MALL MANAGEMENT SYSTEM - DDL (DATA DEFINITION LANGUAGE)
-- File: sql/01_ddl_tables_and_constraints.sql
-- 20 Relational Tables, Primary Keys, Foreign Keys, CHECK Constraints, Indexes
-- ====================================================================

PRAGMA foreign_keys = ON;

-- 1. CUSTOMER & MEMBERSHIP (Customer Management)
CREATE TABLE IF NOT EXISTS CUSTOMER (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE IF NOT EXISTS MEMBERSHIP (
    membership_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL UNIQUE,
    membership_type VARCHAR(20) NOT NULL DEFAULT 'Regular' CHECK(membership_type IN ('Regular', 'Silver', 'Gold', 'Platinum')),
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    points INTEGER NOT NULL DEFAULT 0 CHECK(points >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK(status IN ('Active', 'Suspended', 'Expired')),
    CONSTRAINT fk_membership_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE
);

-- 2. SHOP, TENANT & LEASE (Shop and Tenant Management)
CREATE TABLE IF NOT EXISTS SHOP (
    shop_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    contact_no VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS TENANT (
    tenant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_name VARCHAR(100) NOT NULL,
    contact_no VARCHAR(20) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS LEASE (
    lease_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    tenant_id INTEGER NOT NULL,
    lease_start DATE NOT NULL,
    lease_end DATE NOT NULL,
    monthly_rent DECIMAL(10,2) NOT NULL CHECK(monthly_rent >= 0),
    lease_status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK(lease_status IN ('Active', 'Expired', 'Terminated', 'Pending Renewal')),
    CONSTRAINT fk_lease_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE,
    CONSTRAINT fk_lease_tenant FOREIGN KEY (tenant_id) REFERENCES TENANT(tenant_id) ON DELETE CASCADE
);

-- 3. PRODUCT & OFFER (Product and Promotion Management)
CREATE TABLE IF NOT EXISTS PRODUCT (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK(stock_quantity >= 0),
    CONSTRAINT fk_product_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OFFER (
    offer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    offer_name VARCHAR(100) NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL CHECK(discount_percentage >= 0 AND discount_percentage <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT fk_offer_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

-- 4. PURCHASE, PURCHASE_DETAIL, PAYMENT & OFFER_USAGE
CREATE TABLE IF NOT EXISTS PURCHASE (
    purchase_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    purchase_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(total_amount >= 0),
    CONSTRAINT fk_purchase_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_purchase_shop FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id)
);

CREATE TABLE IF NOT EXISTS PURCHASE_DETAIL (
    purchase_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK(unit_price >= 0),
    discount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(discount >= 0),
    CONSTRAINT fk_pd_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE,
    CONSTRAINT fk_pd_product FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
);

CREATE TABLE IF NOT EXISTS PAYMENT (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL UNIQUE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
    payment_method VARCHAR(30) NOT NULL CHECK(payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'UPI', 'Net Banking')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Completed' CHECK(payment_status IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    CONSTRAINT fk_payment_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OFFER_USAGE (
    usage_id INTEGER PRIMARY KEY AUTOINCREMENT,
    offer_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    purchase_id INTEGER NOT NULL,
    used_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ou_offer FOREIGN KEY (offer_id) REFERENCES OFFER(offer_id),
    CONSTRAINT fk_ou_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_ou_purchase FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

-- 5. PARKING MANAGEMENT
CREATE TABLE IF NOT EXISTS VEHICLE (
    vehicle_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK(vehicle_type IN ('2-Wheeler', '4-Wheeler', 'EV')),
    CONSTRAINT fk_vehicle_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS PARKING_SLOT (
    slot_id INTEGER PRIMARY KEY AUTOINCREMENT,
    floor VARCHAR(10) NOT NULL CHECK(floor IN ('B1', 'B2', 'B3')),
    slot_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK(vehicle_type IN ('2-Wheeler', '4-Wheeler', 'EV')),
    status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK(status IN ('Available', 'Occupied', 'Reserved', 'Maintenance'))
);

CREATE TABLE IF NOT EXISTS PARKING_ENTRY (
    entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
    vehicle_id INTEGER NOT NULL,
    slot_id INTEGER NOT NULL,
    entry_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exit_time TIMESTAMP,
    parking_fee DECIMAL(8,2) DEFAULT 0 CHECK(parking_fee >= 0),
    CONSTRAINT fk_pe_vehicle FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    CONSTRAINT fk_pe_slot FOREIGN KEY (slot_id) REFERENCES PARKING_SLOT(slot_id)
);

-- 6. EVENT MANAGEMENT
CREATE TABLE IF NOT EXISTS EVENT (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_name VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100) NOT NULL,
    capacity INTEGER NOT NULL CHECK(capacity > 0)
);

CREATE TABLE IF NOT EXISTS EVENT_REGISTRATION (
    registration_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status VARCHAR(20) NOT NULL DEFAULT 'Registered' CHECK(attendance_status IN ('Registered', 'Attended', 'Cancelled')),
    CONSTRAINT fk_er_event FOREIGN KEY (event_id) REFERENCES EVENT(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_er_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE,
    UNIQUE(event_id, customer_id)
);

-- 7. EMPLOYEE, COMPLAINT & MAINTENANCE
CREATE TABLE IF NOT EXISTS EMPLOYEE (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL CHECK(department IN ('Security', 'Maintenance', 'Customer Service', 'Housekeeping', 'Operations', 'Management')),
    designation VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS COMPLAINT (
    complaint_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    complaint_type VARCHAR(50) NOT NULL CHECK(complaint_type IN ('Cleanliness', 'Noise', 'Service', 'Staff Behavior', 'Facilities', 'Parking', 'Security', 'Billing')),
    description TEXT NOT NULL,
    complaint_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'In Progress', 'Resolved', 'Dismissed')),
    priority VARCHAR(20) NOT NULL DEFAULT 'Medium' CHECK(priority IN ('Low', 'Medium', 'High', 'Urgent')),
    resolution_date TIMESTAMP,
    CONSTRAINT fk_comp_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

CREATE TABLE IF NOT EXISTS COMPLAINT_ASSIGNMENT (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    complaint_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    CONSTRAINT fk_ca_complaint FOREIGN KEY (complaint_id) REFERENCES COMPLAINT(complaint_id) ON DELETE CASCADE,
    CONSTRAINT fk_ca_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

CREATE TABLE IF NOT EXISTS MAINTENANCE_REQUEST (
    request_id INTEGER PRIMARY KEY AUTOINCREMENT,
    reported_by_customer_id INTEGER,
    issue_type VARCHAR(50) NOT NULL CHECK(issue_type IN ('Electrical', 'HVAC / AC', 'Plumbing', 'Escalator / Elevator', 'Structural', 'Lighting', 'Cleaning & Sanitation')),
    description TEXT NOT NULL,
    request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    completion_date TIMESTAMP,
    CONSTRAINT fk_mr_customer FOREIGN KEY (reported_by_customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS MAINTENANCE_ASSIGNMENT (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    request_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    CONSTRAINT fk_ma_request FOREIGN KEY (request_id) REFERENCES MAINTENANCE_REQUEST(request_id) ON DELETE CASCADE,
    CONSTRAINT fk_ma_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_customer_phone ON CUSTOMER(phone);
CREATE INDEX IF NOT EXISTS idx_product_shop ON PRODUCT(shop_id);
CREATE INDEX IF NOT EXISTS idx_purchase_customer ON PURCHASE(customer_id);
CREATE INDEX IF NOT EXISTS idx_purchase_shop ON PURCHASE(shop_id);
CREATE INDEX IF NOT EXISTS idx_parking_slot_status ON PARKING_SLOT(status, floor);
CREATE INDEX IF NOT EXISTS idx_complaint_status ON COMPLAINT(status, priority);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON MAINTENANCE_REQUEST(status);
