-- ====================================================================
-- MALL MANAGEMENT SYSTEM - DATABASE SCHEMA (SQLite / ANSI SQL)
-- Mini Project for DBMS Coursework
-- Compliant with ER Diagram and Functional Requirements
-- ====================================================================

PRAGMA foreign_keys = ON;

-- --------------------------------------------------------------------
-- 1. CUSTOMER & MEMBERSHIP ENTITIES
-- --------------------------------------------------------------------

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
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 2. SHOP, TENANT & LEASE ENTITIES
-- --------------------------------------------------------------------

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
    FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES TENANT(tenant_id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 3. PRODUCT & OFFER ENTITIES
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS PRODUCT (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK(stock_quantity >= 0),
    FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OFFER (
    offer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    offer_name VARCHAR(100) NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL CHECK(discount_percentage >= 0 AND discount_percentage <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 4. PURCHASE, PAYMENT & OFFER USAGE ENTITIES
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS PURCHASE (
    purchase_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    purchase_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id)
);

CREATE TABLE IF NOT EXISTS PURCHASE_DETAIL (
    purchase_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK(unit_price >= 0),
    discount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(discount >= 0),
    FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
);

CREATE TABLE IF NOT EXISTS PAYMENT (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL UNIQUE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
    payment_method VARCHAR(30) NOT NULL CHECK(payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'UPI', 'Net Banking')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Completed' CHECK(payment_status IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OFFER_USAGE (
    usage_id INTEGER PRIMARY KEY AUTOINCREMENT,
    offer_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    purchase_id INTEGER NOT NULL,
    used_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offer_id) REFERENCES OFFER(offer_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 5. PARKING MANAGEMENT ENTITIES
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS VEHICLE (
    vehicle_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK(vehicle_type IN ('2-Wheeler', '4-Wheeler', 'EV')),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
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
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    FOREIGN KEY (slot_id) REFERENCES PARKING_SLOT(slot_id)
);

-- --------------------------------------------------------------------
-- 6. EVENT MANAGEMENT ENTITIES
-- --------------------------------------------------------------------

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
    FOREIGN KEY (event_id) REFERENCES EVENT(event_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE,
    UNIQUE(event_id, customer_id)
);

-- --------------------------------------------------------------------
-- 7. EMPLOYEE, COMPLAINT & MAINTENANCE ENTITIES
-- --------------------------------------------------------------------

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
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

CREATE TABLE IF NOT EXISTS COMPLAINT_ASSIGNMENT (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    complaint_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    FOREIGN KEY (complaint_id) REFERENCES COMPLAINT(complaint_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

CREATE TABLE IF NOT EXISTS MAINTENANCE_REQUEST (
    request_id INTEGER PRIMARY KEY AUTOINCREMENT,
    reported_by_customer_id INTEGER,
    issue_type VARCHAR(50) NOT NULL CHECK(issue_type IN ('Electrical', 'HVAC / AC', 'Plumbing', 'Escalator / Elevator', 'Structural', 'Lighting', 'Cleaning & Sanitation')),
    description TEXT NOT NULL,
    request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    completion_date TIMESTAMP,
    FOREIGN KEY (reported_by_customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS MAINTENANCE_ASSIGNMENT (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    request_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    FOREIGN KEY (request_id) REFERENCES MAINTENANCE_REQUEST(request_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

-- --------------------------------------------------------------------
-- 8. INDEXES FOR PERFORMANCE OPTIMIZATION
-- --------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_customer_phone ON CUSTOMER(phone);
CREATE INDEX IF NOT EXISTS idx_product_shop ON PRODUCT(shop_id);
CREATE INDEX IF NOT EXISTS idx_purchase_customer ON PURCHASE(customer_id);
CREATE INDEX IF NOT EXISTS idx_purchase_shop ON PURCHASE(shop_id);
CREATE INDEX IF NOT EXISTS idx_purchase_date ON PURCHASE(purchase_date);
CREATE INDEX IF NOT EXISTS idx_parking_slot_status ON PARKING_SLOT(status, floor);
CREATE INDEX IF NOT EXISTS idx_complaint_status ON COMPLAINT(status, priority);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON MAINTENANCE_REQUEST(status);
CREATE INDEX IF NOT EXISTS idx_lease_dates ON LEASE(lease_start, lease_end, lease_status);

-- --------------------------------------------------------------------
-- 9. VIEWS FOR REPORTING & ANALYTICS
-- --------------------------------------------------------------------

-- View 1: Shop Sales & Revenue Summary
CREATE VIEW IF NOT EXISTS vw_shop_sales AS
SELECT 
    s.shop_id,
    s.shop_name,
    s.category,
    s.floor,
    COUNT(DISTINCT p.purchase_id) AS total_orders,
    COALESCE(SUM(p.total_amount), 0.0) AS total_revenue,
    COALESCE(ROUND(AVG(p.total_amount), 2), 0.0) AS avg_order_value
FROM SHOP s
LEFT JOIN PURCHASE p ON s.shop_id = p.shop_id
GROUP BY s.shop_id, s.shop_name, s.category, s.floor;

-- View 2: Customer Loyalty & Returning Analysis
CREATE VIEW IF NOT EXISTS vw_customer_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.phone,
    c.email,
    c.registration_date,
    m.membership_type,
    COALESCE(m.points, 0) AS points,
    m.status AS membership_status,
    COUNT(p.purchase_id) AS total_purchases,
    COALESCE(SUM(p.total_amount), 0.0) AS lifetime_spent,
    CASE 
        WHEN COUNT(p.purchase_id) > 1 THEN 'Returning Customer'
        WHEN COUNT(p.purchase_id) = 1 THEN 'First-time Customer'
        ELSE 'Prospect (No Purchases)'
    END AS customer_lifecycle
FROM CUSTOMER c
LEFT JOIN MEMBERSHIP m ON c.customer_id = m.customer_id
LEFT JOIN PURCHASE p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

-- View 3: Parking Real-Time Occupancy & Usage
CREATE VIEW IF NOT EXISTS vw_parking_status AS
SELECT 
    ps.slot_id,
    ps.floor,
    ps.slot_number,
    ps.vehicle_type AS slot_vehicle_type,
    ps.status,
    pe.entry_id,
    pe.entry_time,
    v.vehicle_number,
    c.customer_name,
    c.phone
FROM PARKING_SLOT ps
LEFT JOIN PARKING_ENTRY pe ON ps.slot_id = pe.slot_id AND pe.exit_time IS NULL
LEFT JOIN VEHICLE v ON pe.vehicle_id = v.vehicle_id
LEFT JOIN CUSTOMER c ON v.customer_id = c.customer_id;

-- View 4: Active & Expired Leases Summary
CREATE VIEW IF NOT EXISTS vw_lease_overview AS
SELECT 
    l.lease_id,
    s.shop_name,
    s.category AS shop_category,
    s.floor,
    t.tenant_name,
    t.contact_no AS tenant_contact,
    l.lease_start,
    l.lease_end,
    l.monthly_rent,
    l.lease_status,
    CAST((julianday(l.lease_end) - julianday('now')) AS INTEGER) AS days_remaining
FROM LEASE l
JOIN SHOP s ON l.shop_id = s.shop_id
JOIN TENANT t ON l.tenant_id = t.tenant_id;

-- View 5: Unresolved Complaints with Assigned Employees
CREATE VIEW IF NOT EXISTS vw_complaints_detail AS
SELECT 
    comp.complaint_id,
    comp.complaint_type,
    comp.description,
    comp.complaint_date,
    comp.status,
    comp.priority,
    comp.resolution_date,
    c.customer_name,
    c.phone AS customer_phone,
    emp.employee_name AS assigned_to,
    emp.department AS employee_dept,
    ca.assignment_status
FROM COMPLAINT comp
JOIN CUSTOMER c ON comp.customer_id = c.customer_id
LEFT JOIN COMPLAINT_ASSIGNMENT ca ON comp.complaint_id = ca.complaint_id
LEFT JOIN EMPLOYEE emp ON ca.employee_id = emp.employee_id;

-- View 6: Pending Maintenance Requests Overview
CREATE VIEW IF NOT EXISTS vw_maintenance_overview AS
SELECT 
    m.request_id,
    m.issue_type,
    m.description,
    m.request_date,
    m.status,
    m.completion_date,
    c.customer_name AS reported_by,
    emp.employee_name AS assigned_technician,
    emp.phone AS technician_phone,
    ma.assignment_status
FROM MAINTENANCE_REQUEST m
LEFT JOIN CUSTOMER c ON m.reported_by_customer_id = c.customer_id
LEFT JOIN MAINTENANCE_ASSIGNMENT ma ON m.request_id = ma.request_id
LEFT JOIN EMPLOYEE emp ON ma.employee_id = emp.employee_id;

-- View 7: Event Attendance & Capacity Tracker
CREATE VIEW IF NOT EXISTS vw_event_attendance AS
SELECT 
    e.event_id,
    e.event_name,
    e.event_date,
    e.start_time,
    e.end_time,
    e.location,
    e.capacity,
    COUNT(er.registration_id) AS total_registered,
    SUM(CASE WHEN er.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS total_attended,
    (e.capacity - COUNT(er.registration_id)) AS remaining_seats,
    ROUND(CAST(COUNT(er.registration_id) AS REAL) / e.capacity * 100, 1) AS occupancy_percentage
FROM EVENT e
LEFT JOIN EVENT_REGISTRATION er ON e.event_id = er.event_id
GROUP BY e.event_id;

-- --------------------------------------------------------------------
-- 10. DATABASE TRIGGERS (DBMS ESSENTIALS)
-- --------------------------------------------------------------------

-- Trigger 1: Automatically reduce product stock when item is purchased
CREATE TRIGGER IF NOT EXISTS trg_reduce_product_stock
AFTER INSERT ON PURCHASE_DETAIL
FOR EACH ROW
BEGIN
    UPDATE PRODUCT
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END;

-- Trigger 2: Automatically award membership points and upgrade tier upon completed payment
CREATE TRIGGER IF NOT EXISTS trg_award_loyalty_points
AFTER INSERT ON PAYMENT
WHEN NEW.payment_status = 'Completed'
BEGIN
    -- Update points: 1 point per $10 spent
    UPDATE MEMBERSHIP
    SET points = points + CAST(NEW.amount / 10 AS INTEGER),
        membership_type = CASE 
            WHEN (points + CAST(NEW.amount / 10 AS INTEGER)) >= 1000 THEN 'Platinum'
            WHEN (points + CAST(NEW.amount / 10 AS INTEGER)) >= 400 THEN 'Gold'
            WHEN (points + CAST(NEW.amount / 10 AS INTEGER)) >= 150 THEN 'Silver'
            ELSE membership_type
        END
    WHERE customer_id = (SELECT customer_id FROM PURCHASE WHERE purchase_id = NEW.purchase_id);
END;

-- Trigger 3: Automatically set parking slot to Occupied on vehicle entry
CREATE TRIGGER IF NOT EXISTS trg_occupy_parking_slot
AFTER INSERT ON PARKING_ENTRY
BEGIN
    UPDATE PARKING_SLOT
    SET status = 'Occupied'
    WHERE slot_id = NEW.slot_id;
END;

-- Trigger 4: Automatically set parking slot to Available when vehicle exits
CREATE TRIGGER IF NOT EXISTS trg_release_parking_slot
AFTER UPDATE OF exit_time ON PARKING_ENTRY
WHEN NEW.exit_time IS NOT NULL AND OLD.exit_time IS NULL
BEGIN
    UPDATE PARKING_SLOT
    SET status = 'Available'
    WHERE slot_id = NEW.slot_id;
END;
