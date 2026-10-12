-- ====================================================================
-- MALL MANAGEMENT SYSTEM - DATABASE VIEWS
-- File: sql/03_views.sql
-- 7 Pre-computed Analytical and Operational Views
-- ====================================================================

-- 1. Shop Sales & Financial Performance View
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

-- 2. Customer Loyalty, Spend and Returning Classification View
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

-- 3. Real-Time Parking Bay Occupancy View
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

-- 4. Commercial Lease Contract Overview View
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

-- 5. Customer Complaints & Resolution Status View
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

-- 6. Facility Maintenance Work Orders View
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

-- 7. Event Attendance & Capacity Utilization View
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
