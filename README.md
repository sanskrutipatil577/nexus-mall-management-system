# Nexus Mall Management System - DBMS Mini Project

A centralized database-driven management application designed to integrate and automate mall operations: customers, shops, leases, inventory, purchases, loyalty points, multi-floor parking, events, customer complaints, and facility maintenance.

Built in compliance with the **Requirement Analysis & ER Diagram Case Study**.

---

## 🌟 Key Features

1. **Customer & Loyalty Management (Section A)**
   - Customer profile registry with phone, email, and registration tracking.
   - Automated Membership tier system (`Regular`, `Silver`, `Gold`, `Platinum`).
   - Automated points accrual trigger upon purchase payment.
   - Returning vs First-time customer tracking.

2. **Shop, Tenant & Lease Management (Section B)**
   - Directory of shops categorized across multiple floors (`Ground`, `1st`, `2nd`, `3rd`, `Basement B1`).
   - Tenant commercial contract tracking with monthly rent roll and lease status (`Active`, `Pending Renewal`, `Expired`).

3. **Product Catalog & Point of Sale (POS) Checkout (Section C)**
   - Real-time inventory tracking with low-stock alerts.
   - Promotional discount campaigns with start/end date validation.
   - Interactive POS Billing Simulator: selects customer, shop outlet, items, calculates promo discounts, records transaction, and generates printable invoice receipts.
   - Atomic database transactions with automated trigger-based stock reduction.

4. **Multi-Level Smart Parking System (Section D)**
   - 2D real-time interactive slot visualizer across Basements `B1`, `B2`, and `B3`.
   - Dedicated bays for `2-Wheeler`, `4-Wheeler`, and `EV` vehicles.
   - Automated bay assignment and vacancy updates via database triggers.
   - Duration-based hourly tariff calculator upon check-out.

5. **Mall Events & Registrations (Section E)**
   - Event scheduling with venue, time, and max capacity limits.
   - Customer RSVP registration with automatic capacity validation and attendance tracking.

6. **Complaints & Maintenance Operations (Sections F & G)**
   - Customer complaint logging with priority levels (`Low`, `Medium`, `High`, `Urgent`).
   - Facility maintenance work orders (`Escalator/Elevator`, `HVAC/AC`, `Plumbing`, `Electrical`, `Lighting`).
   - Staff and technician assignment workflows with status progression (`Pending` &rarr; `In Progress` &rarr; `Resolved/Completed`).

7. **10 DBMS Analytical Reports & Charts (Section H)**
   1. *Total Sales by Shop* (`SUM(total_amount) GROUP BY shop`)
   2. *Popular Product Categories* (`SUM(quantity) GROUP BY category`)
   3. *Customer Purchase Patterns* (`AVG(spent) by Membership Tier`)
   4. *Parking Usage & Peak Hours* (`COUNT(entry_id) GROUP BY hour`)
   5. *Event Registrations vs Capacity* (Utilization rate)
   6. *Most Common Complaints* (Pending vs Resolved breakdown)
   7. *Pending Maintenance Requests* (Categorized by issue type)
   8. *Active, Renewal & Expired Leases* (Rental revenue impact)
   9. *Payment Method Usage* (`Cash`, `Credit Card`, `UPI`, `Debit Card`)
   10. *Returning Customers vs First-Time* (Customer Lifetime Value)

8. **Interactive DBMS SQL Studio**
   - Live SQL Query Console with preset DBMS queries (Joins, Subqueries, Having, Views, Triggers).
   - `EXPLAIN QUERY PLAN` runner.
   - Full ER Diagram visualizer.
   - Schema and Triggers inspector.
   - Drop-in exportable SQL scripts (`schema.sql`, `mysql_schema.sql`, `seed_data.sql`).

---

## 🗄️ Database Architecture & Relational Schema

### Entities (3NF Normalized)
- `CUSTOMER` (`customer_id` PK, `customer_name`, `phone`, `email`, `registration_date`)
- `MEMBERSHIP` (`membership_id` PK, `customer_id` FK, `membership_type`, `points`, `status`)
- `SHOP` (`shop_id` PK, `shop_name`, `category`, `floor`, `contact_no`)
- `TENANT` (`tenant_id` PK, `tenant_name`, `contact_no`, `email`)
- `LEASE` (`lease_id` PK, `shop_id` FK, `tenant_id` FK, `lease_start`, `lease_end`, `monthly_rent`, `lease_status`)
- `PRODUCT` (`product_id` PK, `shop_id` FK, `product_name`, `category`, `price`, `stock_quantity`)
- `OFFER` (`offer_id` PK, `shop_id` FK, `offer_name`, `discount_percentage`, `start_date`, `end_date`)
- `PURCHASE` (`purchase_id` PK, `customer_id` FK, `shop_id` FK, `purchase_date`, `total_amount`)
- `PURCHASE_DETAIL` (`purchase_detail_id` PK, `purchase_id` FK, `product_id` FK, `quantity`, `unit_price`, `discount`)
- `PAYMENT` (`payment_id` PK, `purchase_id` FK, `amount`, `payment_method`, `payment_status`)
- `OFFER_USAGE` (`usage_id` PK, `offer_id` FK, `customer_id` FK, `purchase_id` FK, `used_date`)
- `VEHICLE` (`vehicle_id` PK, `customer_id` FK, `vehicle_number`, `vehicle_type`)
- `PARKING_SLOT` (`slot_id` PK, `floor`, `slot_number`, `vehicle_type`, `status`)
- `PARKING_ENTRY` (`entry_id` PK, `vehicle_id` FK, `slot_id` FK, `entry_time`, `exit_time`, `parking_fee`)
- `EVENT` (`event_id` PK, `event_name`, `event_date`, `start_time`, `end_time`, `location`, `capacity`)
- `EVENT_REGISTRATION` (`registration_id` PK, `event_id` FK, `customer_id` FK, `attendance_status`)
- `EMPLOYEE` (`employee_id` PK, `employee_name`, `department`, `designation`, `phone`)
- `COMPLAINT` (`complaint_id` PK, `customer_id` FK, `complaint_type`, `description`, `status`, `priority`, `resolution_date`)
- `COMPLAINT_ASSIGNMENT` (`assignment_id` PK, `complaint_id` FK, `employee_id` FK, `assignment_status`)
- `MAINTENANCE_REQUEST` (`request_id` PK, `reported_by_customer_id` FK, `issue_type`, `description`, `status`, `completion_date`)
- `MAINTENANCE_ASSIGNMENT` (`assignment_id` PK, `request_id` FK, `employee_id` FK, `assignment_status`)

### Database Triggers
1. **`trg_reduce_product_stock`**: Automatically decrements product stock upon insertion into `PURCHASE_DETAIL`.
2. **`trg_award_loyalty_points`**: Calculates and increments points (1 point per $10 spent) and upgrades customer tier upon `PAYMENT` completion.
3. **`trg_occupy_parking_slot`**: Sets parking slot status to `Occupied` upon vehicle entry.
4. **`trg_release_parking_slot`**: Resets parking slot status to `Available` when vehicle exit time is logged.

### SQL Views
1. `vw_shop_sales`: Aggregates orders, revenue, and average order values per shop.
2. `vw_customer_summary`: Joins customers, memberships, and purchase history with customer lifecycle stage.
3. `vw_parking_status`: Real-time parking occupancy with customer vehicle details.
4. `vw_lease_overview`: Days remaining and financial breakdown for all mall leases.
5. `vw_complaints_detail`: Unresolved tickets joined with customer details and assigned staff.
6. `vw_maintenance_overview`: Open work orders with technician contact details.
7. `vw_event_attendance`: RSVPs, remaining seats, and capacity percentage.

---

## 🚀 How to Run the Project

### Requirements
- Python 3.10+ (Python 3.14 recommended)
- Flask (`pip install flask`)

### Quick Start
1. Navigate to the project directory:
   ```powershell
   cd C:\Users\sanskruti\.gemini\antigravity\scratch\mall-management-system
   ```
2. Start the application:
   ```powershell
   python app.py
   ```
3. Open your browser and visit:
   ```
   http://127.0.0.1:5000
   ```

---

## 🎓 DBMS Viva / Evaluation Guide

| Evaluator Question | Demonstration in Application |
| :--- | :--- |
| *Show relational joins across 3+ tables* | Navigate to **SQL Studio &rarr; Presets &rarr; Join: Shop & Revenue** or check **Shops & Leases** tab. |
| *Demonstrate database triggers* | Open **POS Checkout**, buy an item, then open **SQL Studio** and inspect how stock auto-reduced and loyalty points increased without application code. |
| *How are returning customers detected?* | Open **Customer & Loyalty** or **10 DBMS Reports &rarr; Report #10** which uses `GROUP BY customer_id HAVING COUNT(purchase_id) > 1`. |
| *How is concurrency/data consistency handled?* | Inspect `app.py` `/api/purchases` using atomic transactions (`BEGIN`, `COMMIT`, `ROLLBACK`) with foreign key constraints. |
| *Show MySQL compatibility* | Open **SQL Studio &rarr; Download SQL Scripts** and download `mysql_schema.sql` (MySQL 8.0+ syntax). |
