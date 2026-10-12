-- ====================================================================
-- MALL MANAGEMENT SYSTEM - 10 DBMS ANALYTICAL QUERIES
-- File: sql/06_10_analytics_queries.sql
-- Direct implementation of Section H (Reporting and Analytics)
-- ====================================================================

-- --------------------------------------------------------------------
-- QUERY 1: Total Sales by Shop
-- DBMS Concepts: INNER JOIN, LEFT JOIN, SUM(), COUNT(), GROUP BY, ORDER BY
-- Description: Aggregates total sales revenue, order volumes, and average ticket size per shop.
-- --------------------------------------------------------------------
SELECT 
    s.shop_id,
    s.shop_name,
    s.category AS shop_category,
    s.floor,
    COUNT(p.purchase_id) AS total_orders,
    COALESCE(SUM(p.total_amount), 0.0) AS gross_sales_revenue,
    COALESCE(ROUND(AVG(p.total_amount), 2), 0.0) AS avg_order_value
FROM SHOP s
LEFT JOIN PURCHASE p ON s.shop_id = p.shop_id
GROUP BY s.shop_id, s.shop_name, s.category, s.floor
ORDER BY gross_sales_revenue DESC;

-- --------------------------------------------------------------------
-- QUERY 2: Popular Product Categories
-- DBMS Concepts: Multi-table JOIN (PRODUCT -> PURCHASE_DETAIL), SUM(), Aggregation
-- Description: Identifies highest-velocity product categories by total units sold and revenue.
-- --------------------------------------------------------------------
SELECT 
    pr.category AS product_category,
    COUNT(DISTINCT pd.purchase_id) AS orders_count,
    SUM(pd.quantity) AS total_units_sold,
    ROUND(SUM((pd.quantity * pd.unit_price) - pd.discount), 2) AS category_revenue
FROM PURCHASE_DETAIL pd
JOIN PRODUCT pr ON pd.product_id = pr.product_id
GROUP BY pr.category
ORDER BY total_units_sold DESC;

-- --------------------------------------------------------------------
-- QUERY 3: Customer Purchase Patterns
-- DBMS Concepts: JOIN, GROUP BY, Nested Subquery Aggregation, AVG()
-- Description: Analyzes purchasing frequency and spending habits segmented by loyalty tier.
-- --------------------------------------------------------------------
SELECT 
    m.membership_type,
    COUNT(DISTINCT c.customer_id) AS total_members,
    ROUND(AVG(COALESCE(sub.cust_total, 0)), 2) AS avg_spend_per_member,
    ROUND(AVG(COALESCE(sub.order_count, 0)), 1) AS avg_orders_per_member
FROM CUSTOMER c
LEFT JOIN MEMBERSHIP m ON c.customer_id = m.customer_id
LEFT JOIN (
    SELECT customer_id, COUNT(purchase_id) AS order_count, SUM(total_amount) AS cust_total
    FROM PURCHASE
    GROUP BY customer_id
) sub ON c.customer_id = sub.customer_id
GROUP BY m.membership_type
ORDER BY avg_spend_per_member DESC;

-- --------------------------------------------------------------------
-- QUERY 4: Parking Usage and Peak Hours
-- DBMS Concepts: Date/Time Extraction (strftime/EXTRACT), GROUP BY, SUM()
-- Description: Tracks parking entry distribution across hours of the day and fee collection.
-- --------------------------------------------------------------------
-- Peak Hours Distribution:
SELECT 
    strftime('%H:00', entry_time) AS hour_of_day,
    COUNT(entry_id) AS vehicles_parked_count,
    COALESCE(SUM(parking_fee), 0.0) AS total_parking_revenue
FROM PARKING_ENTRY
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Usage by Basement Floor:
SELECT 
    floor,
    COUNT(slot_id) AS total_capacity,
    SUM(CASE WHEN status = 'Occupied' THEN 1 ELSE 0 END) AS currently_occupied,
    SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) AS currently_available,
    ROUND(CAST(SUM(CASE WHEN status = 'Occupied' THEN 1 ELSE 0 END) AS REAL) / COUNT(slot_id) * 100, 1) AS occupancy_rate_pct
FROM PARKING_SLOT
GROUP BY floor;

-- --------------------------------------------------------------------
-- QUERY 5: Event Registrations and Attendance
-- DBMS Concepts: Conditional Aggregation (CASE WHEN), Capacity Ratio
-- Description: Compares registered RSVPs against venue capacity and actual attendance.
-- --------------------------------------------------------------------
SELECT 
    e.event_id,
    e.event_name,
    e.location,
    e.capacity AS max_venue_capacity,
    COUNT(er.registration_id) AS total_rsvps,
    SUM(CASE WHEN er.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS verified_attendees,
    (e.capacity - COUNT(er.registration_id)) AS remaining_seats,
    ROUND(CAST(COUNT(er.registration_id) AS REAL) / e.capacity * 100, 1) AS rsvp_capacity_pct
FROM EVENT e
LEFT JOIN EVENT_REGISTRATION er ON e.event_id = er.event_id
GROUP BY e.event_id, e.event_name, e.location, e.capacity
ORDER BY total_rsvps DESC;

-- --------------------------------------------------------------------
-- QUERY 6: Most Common Customer Complaints
-- DBMS Concepts: Category Breakdown, Priority Weighting, Pending vs Resolved Counts
-- Description: Analyzes complaint volumes by category and resolution progress.
-- --------------------------------------------------------------------
SELECT 
    complaint_type,
    COUNT(complaint_id) AS total_complaints_filed,
    SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) AS resolved_count,
    SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS in_progress_count,
    SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending_unassigned_count,
    SUM(CASE WHEN priority = 'Urgent' THEN 1 ELSE 0 END) AS urgent_severity_count
FROM COMPLAINT
GROUP BY complaint_type
ORDER BY total_complaints_filed DESC;

-- --------------------------------------------------------------------
-- QUERY 7: Pending Maintenance Requests
-- DBMS Concepts: Status Filtering, Technician Workload Identification
-- Description: Identifies facility equipment issues requiring immediate technician intervention.
-- --------------------------------------------------------------------
SELECT 
    issue_type,
    COUNT(request_id) AS total_work_orders,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN status != 'Completed' THEN 1 ELSE 0 END) AS pending_backlog,
    SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS active_in_progress
FROM MAINTENANCE_REQUEST
GROUP BY issue_type
ORDER BY pending_backlog DESC;

-- --------------------------------------------------------------------
-- QUERY 8: Active and Expired Leases Summary
-- DBMS Concepts: Date Comparisons, Rental Roll Aggregation
-- Description: Summarizes active commercial tenant revenue vs expired/pending renewals.
-- --------------------------------------------------------------------
SELECT 
    lease_status,
    COUNT(lease_id) AS total_contracts,
    ROUND(SUM(monthly_rent), 2) AS monthly_rent_revenue,
    ROUND(AVG(monthly_rent), 2) AS avg_contract_rent
FROM LEASE
GROUP BY lease_status
ORDER BY monthly_rent_revenue DESC;

-- --------------------------------------------------------------------
-- QUERY 9: Payment Method Usage
-- DBMS Concepts: Grouped Volume & Revenue Shares, Distribution Percentage
-- Description: Shows transaction distribution across Cash, Credit Card, UPI, and Debit Card.
-- --------------------------------------------------------------------
SELECT 
    payment_method,
    COUNT(payment_id) AS transactions_count,
    ROUND(SUM(amount), 2) AS total_amount_collected,
    ROUND(AVG(amount), 2) AS avg_transaction_ticket
FROM PAYMENT
GROUP BY payment_method
ORDER BY total_amount_collected DESC;

-- --------------------------------------------------------------------
-- QUERY 10: Returning Customers Analysis
-- DBMS Concepts: HAVING clause, Conditional Grouping, Customer Lifetime Value (LTV)
-- Description: Distinguishes repeat loyal shoppers (purchases > 1) from first-time shoppers.
-- --------------------------------------------------------------------
SELECT 
    CASE 
        WHEN order_count > 1 THEN 'Returning Customer (Repeat Buyer)'
        ELSE 'First-time Customer (Single Order)'
    END AS customer_retention_segment,
    COUNT(customer_id) AS customer_count,
    ROUND(SUM(total_spent), 2) AS aggregate_spend,
    ROUND(AVG(total_spent), 2) AS avg_customer_lifetime_value
FROM (
    SELECT 
        c.customer_id,
        COUNT(p.purchase_id) AS order_count,
        COALESCE(SUM(p.total_amount), 0.0) AS total_spent
    FROM CUSTOMER c
    JOIN PURCHASE p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
) customer_order_summary
GROUP BY customer_retention_segment;
