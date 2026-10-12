import sqlite3
import os
from datetime import datetime, timedelta
from db import get_db_connection, init_db

def seed_database():
    init_db(force=True)
    conn = get_db_connection()
    cursor = conn.cursor()

    print("Seeding Mall Management System database...")

    # 1. Customers
    customers = [
        ("Aarav Sharma", "+91 98201 11223", "aarav.sharma@example.com", "2025-10-15"),
        ("Priya Patel", "+91 98202 22334", "priya.patel@example.com", "2025-11-01"),
        ("Rohan Verma", "+91 98203 33445", "rohan.verma@example.com", "2025-11-20"),
        ("Ananya Iyer", "+91 98204 44556", "ananya.iyer@example.com", "2025-12-05"),
        ("Vikram Malhotra", "+91 98205 55667", "vikram.m@example.com", "2026-01-10"),
        ("Sneha Kulkarni", "+91 98206 66778", "sneha.k@example.com", "2026-01-18"),
        ("Kabir Mehta", "+91 98207 77889", "kabir.mehta@example.com", "2026-02-01"),
        ("Neha Reddy", "+91 98208 88990", "neha.reddy@example.com", "2026-02-14"),
        ("Aditya Roy", "+91 98209 99001", "aditya.roy@example.com", "2026-03-01"),
        ("Ishita Sen", "+91 98210 10112", "ishita.sen@example.com", "2026-03-10"),
        ("Rahul Deshmukh", "+91 98211 12123", "rahul.d@example.com", "2026-04-05"),
        ("Pooja Nair", "+91 98212 13134", "pooja.nair@example.com", "2026-05-12"),
        ("Karan Kapoor", "+91 98213 14145", "karan.k@example.com", "2026-06-20"),
        ("Ritu Aggarwal", "+91 98214 15156", "ritu.a@example.com", "2026-07-08"),
        ("Devendra Singh", "+91 98215 16167", "dev.singh@example.com", "2026-08-15")
    ]
    cursor.executemany(
        "INSERT INTO CUSTOMER (customer_name, phone, email, registration_date) VALUES (?, ?, ?, ?)",
        customers
    )

    # 2. Memberships
    memberships = [
        (1, "Platinum", "2025-10-15", 1450, "Active"),
        (2, "Gold", "2025-11-01", 620, "Active"),
        (3, "Silver", "2025-11-20", 280, "Active"),
        (4, "Platinum", "2025-12-05", 1120, "Active"),
        (5, "Gold", "2026-01-10", 540, "Active"),
        (6, "Silver", "2026-01-18", 190, "Active"),
        (7, "Regular", "2026-02-01", 60, "Active"),
        (8, "Regular", "2026-02-14", 90, "Active"),
        (9, "Silver", "2026-03-01", 210, "Active"),
        (10, "Regular", "2026-03-10", 40, "Active"),
        (11, "Regular", "2026-04-05", 0, "Active"),
        (12, "Gold", "2026-05-12", 480, "Active"),
        (13, "Regular", "2026-06-20", 30, "Active"),
        (14, "Regular", "2026-07-08", 0, "Suspended"),
        (15, "Silver", "2026-08-15", 175, "Active")
    ]
    cursor.executemany(
        "INSERT INTO MEMBERSHIP (customer_id, membership_type, join_date, points, status) VALUES (?, ?, ?, ?, ?)",
        memberships
    )

    # 3. Tenants
    tenants = [
        ("Inditex Trent Retail Ltd", "+91 22 6678 1000", "leasing@inditex.com"),
        ("Apple India Retail Pvt Ltd", "+91 22 4005 2000", "store_leasing@apple.com"),
        ("Tata Starbucks Private Ltd", "+91 22 6755 3000", "realestate@starbucks.co.in"),
        ("Nike India Retail Operations", "+91 80 4123 4000", "retail@nike.com"),
        ("H&M Hennes & Mauritz Retail", "+91 11 4987 5000", "expansion@hm.com"),
        ("Samsung Electronics India", "+91 12 4488 6000", "retail_ops@samsung.com"),
        ("Cinepolis Cinemas India", "+91 12 4677 7000", "projects@cinepolis.com"),
        ("Reliance Brands (Sephora)", "+91 22 3555 8000", "leasing@relbrands.com"),
        ("Crossword Bookstores Ltd", "+91 22 2498 9000", "franchise@crossword.in"),
        ("Nature's Basket Fine Foods", "+91 22 6123 1111", "admin@naturesbasket.co.in"),
        ("Restaurant Brands Asia (Burger King)", "+91 22 7100 2222", "property@bk.com"),
        ("Timezone Family Entertainment", "+91 22 6177 3333", "operations@timezone.com")
    ]
    cursor.executemany(
        "INSERT INTO TENANT (tenant_name, contact_no, email) VALUES (?, ?, ?)",
        tenants
    )

    # 4. Shops
    shops = [
        ("Zara Flagship", "Fashion & Apparel", "Ground Floor", "+91 22 6678 1001"),
        ("Apple Store Central", "Electronics & Gadgets", "Ground Floor", "+91 22 4005 2001"),
        ("Starbucks Reserve", "Food & Dining", "Ground Floor", "+91 22 6755 3001"),
        ("Nike Town", "Footwear & Sportswear", "1st Floor", "+91 80 4123 4001"),
        ("H&M Trend", "Fashion & Apparel", "1st Floor", "+91 11 4987 5001"),
        ("Samsung Experience Hub", "Electronics & Gadgets", "1st Floor", "+91 12 4488 6001"),
        ("Cinepolis VIP Multiplex", "Entertainment", "3rd Floor", "+91 12 4677 7001"),
        ("Sephora Beauty Lounge", "Beauty & Cosmetics", "2nd Floor", "+91 22 3555 8001"),
        ("Crossword Book Emporium", "Books & Stationery", "2nd Floor", "+91 22 2498 9001"),
        ("Nature's Basket Gourmet", "Supermarket & Groceries", "Basement B1", "+91 22 6123 1112"),
        ("Burger King Express", "Food & Dining", "3rd Floor", "+91 22 7100 2223"),
        ("Timezone Gaming Arena", "Entertainment", "3rd Floor", "+91 22 6177 3334")
    ]
    cursor.executemany(
        "INSERT INTO SHOP (shop_name, category, floor, contact_no) VALUES (?, ?, ?, ?)",
        shops
    )

    # 5. Leases
    leases = [
        (1, 1, "2024-01-01", "2027-12-31", 12500.00, "Active"),
        (2, 2, "2024-03-01", "2028-02-28", 16000.00, "Active"),
        (3, 3, "2024-05-01", "2027-04-30", 6500.00, "Active"),
        (4, 4, "2024-06-01", "2027-05-31", 7200.00, "Active"),
        (5, 5, "2024-01-15", "2026-10-15", 9800.00, "Pending Renewal"), # upcoming renewal!
        (6, 6, "2024-08-01", "2027-07-31", 8500.00, "Active"),
        (7, 7, "2023-09-01", "2028-08-31", 22000.00, "Active"),
        (8, 8, "2024-11-01", "2027-10-31", 5800.00, "Active"),
        (9, 9, "2023-12-01", "2026-09-01", 3400.00, "Expired"), # expired lease for analytics
        (10, 10, "2024-02-01", "2027-01-31", 11000.00, "Active"),
        (11, 11, "2024-04-01", "2027-03-31", 4500.00, "Active"),
        (12, 12, "2024-07-01", "2027-06-30", 9000.00, "Active")
    ]
    cursor.executemany(
        "INSERT INTO LEASE (shop_id, tenant_id, lease_start, lease_end, monthly_rent, lease_status) VALUES (?, ?, ?, ?, ?, ?)",
        leases
    )

    # 6. Products
    products = [
        # Zara (Shop 1)
        (1, "Oversized Linen Shirt", "Fashion & Apparel", 49.99, 45),
        (1, "Tailored Slim Trousers", "Fashion & Apparel", 69.99, 30),
        (1, "Wool Blend Trench Coat", "Fashion & Apparel", 149.99, 15),
        (1, "Casual Cotton Blazer", "Fashion & Apparel", 119.99, 20),
        
        # Apple (Shop 2)
        (2, "iPhone 15 Pro Max 256GB", "Electronics & Gadgets", 1199.00, 25),
        (2, "MacBook Air 15-inch M3", "Electronics & Gadgets", 1299.00, 18),
        (2, "AirPods Pro (2nd Gen)", "Electronics & Gadgets", 249.00, 50),
        (2, "Apple Watch Series 9", "Electronics & Gadgets", 399.00, 32),
        
        # Starbucks (Shop 3)
        (3, "Caramel Macchiato Venti", "Food & Dining", 6.50, 100),
        (3, "Cold Brew Reserve", "Food & Dining", 5.75, 120),
        (3, "Smoked Turkey Bagel Sandwich", "Food & Dining", 8.25, 40),
        (3, "Starbucks Tumbler 16oz", "Food & Dining", 24.50, 35),
        
        # Nike (Shop 4)
        (4, "Air Max 270 Sneakers", "Footwear & Sportswear", 160.00, 40),
        (4, "Dri-FIT Training Tee", "Footwear & Sportswear", 35.00, 75),
        (4, "Pegasus 40 Running Shoes", "Footwear & Sportswear", 130.00, 28),
        (4, "Tech Fleece Jogger", "Footwear & Sportswear", 110.00, 35),
        
        # H&M (Shop 5)
        (5, "Relaxed Fit Denim Jacket", "Fashion & Apparel", 59.99, 50),
        (5, "Classic Crewneck Sweater", "Fashion & Apparel", 29.99, 65),
        (5, "Chino Shorts", "Fashion & Apparel", 24.99, 80),
        
        # Samsung (Shop 6)
        (6, "Galaxy S24 Ultra 512GB", "Electronics & Gadgets", 1299.99, 22),
        (6, "Galaxy Tab S9 128GB", "Electronics & Gadgets", 799.99, 15),
        (6, "Galaxy Buds2 Pro", "Electronics & Gadgets", 199.99, 45),
        
        # Cinepolis (Shop 7)
        (7, "VIP Recliner Movie Ticket", "Entertainment", 18.00, 200),
        (7, "Popcorn & Soda Combo XL", "Entertainment", 12.50, 150),
        (7, "IMAX 3D Laser Ticket", "Entertainment", 22.00, 180),
        
        # Sephora (Shop 8)
        (8, "Dior Sauvage Eau de Parfum", "Beauty & Cosmetics", 145.00, 30),
        (8, "Huda Beauty Eyeshadow Palette", "Beauty & Cosmetics", 68.00, 40),
        (8, "Fenty Gloss Bomb", "Beauty & Cosmetics", 22.00, 60),
        
        # Crossword (Shop 9)
        (9, "Atomic Habits by James Clear", "Books & Stationery", 16.99, 55),
        (9, "Sapiens by Yuval Noah Harari", "Books & Stationery", 18.50, 42),
        (9, "Moleskine Hardcover Journal", "Books & Stationery", 24.00, 35),
        
        # Nature's Basket (Shop 10)
        (10, "Extra Virgin Cold Pressed Olive Oil", "Supermarket & Groceries", 19.99, 40),
        (10, "Organic Hass Avocados (Pack of 4)", "Supermarket & Groceries", 8.99, 70),
        (10, "Belgian Artisanal Dark Chocolate", "Supermarket & Groceries", 7.50, 85),
        
        # Burger King (Shop 11)
        (11, "Double Whopper Meal with Fries", "Food & Dining", 11.49, 120),
        (11, "Crispy Chicken Tenders (8 Pcs)", "Food & Dining", 7.99, 90),
        
        # Timezone (Shop 12)
        (12, "Gold Play Card ($50 Credits)", "Entertainment", 50.00, 100),
        (12, "VIP Power Card ($100 Credits)", "Entertainment", 100.00, 80)
    ]
    cursor.executemany(
        "INSERT INTO PRODUCT (shop_id, product_name, category, price, stock_quantity) VALUES (?, ?, ?, ?, ?)",
        products
    )

    # 7. Offers
    offers = [
        (1, "Summer Chic 20% Off", 20.0, "2026-06-01", "2026-10-31"),
        (2, "Apple Student Advantage", 10.0, "2026-08-01", "2026-11-30"),
        (3, "Happy Hour Coffee 15%", 15.0, "2026-09-01", "2026-12-31"),
        (4, "Marathon Season 25% Off", 25.0, "2026-09-15", "2026-10-25"),
        (6, "Galaxy Fest 12% Off", 12.0, "2026-09-01", "2026-10-30"),
        (7, "Cinema Tuesday Special 30%", 30.0, "2026-01-01", "2026-12-31"),
        (8, "Glamour Week 15% Off", 15.0, "2026-09-20", "2026-10-10"),
        (10, "Gourmet Weekend 10% Off", 10.0, "2026-09-01", "2026-12-31")
    ]
    cursor.executemany(
        "INSERT INTO OFFER (shop_id, offer_name, discount_percentage, start_date, end_date) VALUES (?, ?, ?, ?, ?)",
        offers
    )

    # 8. Parking Slots (Floors B1, B2, B3)
    slots = []
    for fl in ["B1", "B2", "B3"]:
        for i in range(1, 9):
            slot_num = f"{fl}-{100 + i}"
            v_type = "4-Wheeler" if i <= 5 else ("2-Wheeler" if i <= 7 else "EV")
            slots.append((fl, slot_num, v_type, "Available"))
    cursor.executemany(
        "INSERT INTO PARKING_SLOT (floor, slot_number, vehicle_type, status) VALUES (?, ?, ?, ?)",
        slots
    )

    # 9. Vehicles
    vehicles = [
        (1, "MH-01-AB-1234", "4-Wheeler"),
        (2, "MH-02-CD-5678", "4-Wheeler"),
        (3, "MH-03-EF-9012", "2-Wheeler"),
        (4, "MH-04-GH-3456", "EV"),
        (5, "MH-01-JK-7890", "4-Wheeler"),
        (6, "MH-02-LM-2345", "4-Wheeler"),
        (7, "MH-03-NP-6789", "2-Wheeler"),
        (8, "MH-04-QR-0123", "EV"),
        (9, "MH-01-ST-4567", "4-Wheeler"),
        (10, "MH-02-UV-8901", "2-Wheeler")
    ]
    cursor.executemany(
        "INSERT INTO VEHICLE (customer_id, vehicle_number, vehicle_type) VALUES (?, ?, ?)",
        vehicles
    )

    # 10. Parking Entries (some active, some completed)
    # Entry 1 to 4: Currently parked (exit_time is NULL)
    active_entries = [
        (1, 1, "2026-10-01 10:15:00", None, 0.0),
        (2, 2, "2026-10-01 11:00:00", None, 0.0),
        (3, 6, "2026-10-01 11:30:00", None, 0.0),
        (4, 8, "2026-10-01 12:05:00", None, 0.0)
    ]
    cursor.executemany(
        "INSERT INTO PARKING_ENTRY (vehicle_id, slot_id, entry_time, exit_time, parking_fee) VALUES (?, ?, ?, ?, ?)",
        active_entries
    )
    # Mark those 4 slots occupied
    cursor.execute("UPDATE PARKING_SLOT SET status = 'Occupied' WHERE slot_id IN (1, 2, 6, 8)")

    # Completed entries for analytics
    completed_entries = [
        (5, 3, "2026-09-30 14:00:00", "2026-09-30 17:30:00", 12.00),
        (6, 4, "2026-09-30 15:15:00", "2026-09-30 18:45:00", 12.00),
        (7, 7, "2026-09-30 16:00:00", "2026-09-30 17:15:00", 4.00),
        (8, 8, "2026-09-30 12:30:00", "2026-09-30 16:00:00", 15.00),
        (9, 1, "2026-09-29 18:00:00", "2026-09-29 21:00:00", 10.00),
        (10, 2, "2026-09-29 11:00:00", "2026-09-29 14:00:00", 10.00),
        (1, 5, "2026-09-28 17:00:00", "2026-09-28 19:30:00", 8.00),
        (2, 9, "2026-09-28 13:00:00", "2026-09-28 16:45:00", 14.00)
    ]
    cursor.executemany(
        "INSERT INTO PARKING_ENTRY (vehicle_id, slot_id, entry_time, exit_time, parking_fee) VALUES (?, ?, ?, ?, ?)",
        completed_entries
    )

    # 11. Employees
    employees = [
        ("Rajesh Kulkarni", "Operations", "Mall Operations Director", "+91 98330 11001"),
        ("Suresh Sharma", "Maintenance", "Chief HVAC & Electrical Tech", "+91 98330 22002"),
        ("Amitabh Sen", "Maintenance", "Elevator & Plumbing Specialist", "+91 98330 33003"),
        ("Sunita Desai", "Customer Service", "Senior Helpdesk Executive", "+91 98330 44004"),
        ("Pooja Hegde", "Customer Service", "Guest Relations Officer", "+91 98330 55005"),
        ("Vikramaditya Rao", "Security", "Head of Mall Security", "+91 98330 66006"),
        ("Ramesh Jadhav", "Housekeeping", "Facility Cleanliness Supervisor", "+91 98330 77007"),
        ("Deepak Chawla", "Security", "Parking & Traffic Warden", "+91 98330 88008")
    ]
    cursor.executemany(
        "INSERT INTO EMPLOYEE (employee_name, department, designation, phone) VALUES (?, ?, ?, ?)",
        employees
    )

    # 12. Events
    events = [
        ("Grand Autumn Tech Expo 2026", "2026-10-10", "11:00:00", "20:00:00", "Central Atrium Ground Floor", 250),
        ("Diwali Fashion Gala & Runway", "2026-10-18", "17:00:00", "21:30:00", "Main Plaza Level 1", 300),
        ("Kids Robotics & STEM Workshop", "2026-10-05", "10:30:00", "13:30:00", "Community Hub Level 2", 50),
        ("World Food & Artisan Coffee Carnival", "2026-10-24", "12:00:00", "22:00:00", "Open Air Terrace Level 4", 400),
        ("E-Sports Gaming Championship 2026", "2026-10-12", "14:00:00", "20:00:00", "Timezone Arena Level 3", 100)
    ]
    cursor.executemany(
        "INSERT INTO EVENT (event_name, event_date, start_time, end_time, location, capacity) VALUES (?, ?, ?, ?, ?, ?)",
        events
    )

    # 13. Event Registrations
    registrations = [
        (1, 1, "2026-09-20 10:00:00", "Registered"),
        (1, 2, "2026-09-20 11:30:00", "Registered"),
        (1, 3, "2026-09-21 15:40:00", "Registered"),
        (1, 4, "2026-09-22 09:20:00", "Registered"),
        (1, 5, "2026-09-22 18:10:00", "Registered"),
        (2, 2, "2026-09-21 12:00:00", "Registered"),
        (2, 4, "2026-09-23 14:00:00", "Registered"),
        (2, 6, "2026-09-24 16:30:00", "Registered"),
        (3, 7, "2026-09-25 11:15:00", "Attended"),
        (3, 8, "2026-09-25 12:00:00", "Attended"),
        (4, 1, "2026-09-26 14:20:00", "Registered"),
        (4, 9, "2026-09-26 17:00:00", "Registered"),
        (5, 3, "2026-09-27 10:00:00", "Registered"),
        (5, 10, "2026-09-27 11:45:00", "Registered")
    ]
    cursor.executemany(
        "INSERT INTO EVENT_REGISTRATION (event_id, customer_id, registration_date, attendance_status) VALUES (?, ?, ?, ?)",
        registrations
    )

    # 14. Complaints & Complaint Assignments
    complaints = [
        (1, "Cleanliness", "Restroom on 2nd floor near cinema was out of hand wash soap and paper towels.", "2026-09-28 14:30:00", "Resolved", "Medium", "2026-09-28 16:00:00"),
        (2, "Parking", "Parking ticket gate at Basement B2 took money but barrier didn't open immediately.", "2026-09-29 11:15:00", "Resolved", "High", "2026-09-29 11:45:00"),
        (3, "Facilities", "Central escalator moving from Floor 1 to Floor 2 made squeaking sounds and jerked.", "2026-09-30 16:45:00", "In Progress", "Urgent", None),
        (4, "Staff Behavior", "Store attendant at fashion outlet refused return without supervisor who was unavailable.", "2026-10-01 10:00:00", "Pending", "Medium", None),
        (5, "Noise", "Acoustics from the promotional speakers at ground atrium were excessively loud for dining.", "2026-09-27 19:20:00", "Resolved", "Low", "2026-09-27 20:30:00"),
        (6, "Facilities", "Water cooler on 3rd floor food court is dispensing warm water.", "2026-10-01 11:30:00", "Pending", "Low", None),
        (7, "Security", "Unattended luggage seen near cinema entrance for 20 minutes.", "2026-09-29 20:00:00", "Resolved", "Urgent", "2026-09-29 20:25:00")
    ]
    cursor.executemany(
        "INSERT INTO COMPLAINT (customer_id, complaint_type, description, complaint_date, status, priority, resolution_date) VALUES (?, ?, ?, ?, ?, ?, ?)",
        complaints
    )

    complaint_assignments = [
        (1, 7, "2026-09-28 14:40:00", "Completed"),
        (2, 8, "2026-09-29 11:20:00", "Completed"),
        (3, 3, "2026-09-30 17:00:00", "In Progress"),
        (4, 4, "2026-10-01 10:15:00", "Assigned"),
        (5, 1, "2026-09-27 19:30:00", "Completed"),
        (6, 2, "2026-10-01 11:45:00", "Assigned"),
        (7, 6, "2026-09-29 20:05:00", "Completed")
    ]
    cursor.executemany(
        "INSERT INTO COMPLAINT_ASSIGNMENT (complaint_id, employee_id, assigned_date, assignment_status) VALUES (?, ?, ?, ?)",
        complaint_assignments
    )

    # 15. Maintenance Requests & Assignments
    maintenance_requests = [
        (1, "Escalator / Elevator", "Routine quarterly lubrication and sensor tuning of main escalator E-03.", "2026-09-25 09:00:00", "Completed", "2026-09-25 14:00:00"),
        (None, "HVAC / AC", "Cooling tower chiller unit #2 showing lower refrigerant pressure.", "2026-09-29 08:30:00", "In Progress", None),
        (2, "Lighting", "LED strip lighting along west atrium walkway is flickering.", "2026-09-30 10:00:00", "Pending", None),
        (None, "Plumbing", "Main drainage trap in B1 food service corridor needs descaling.", "2026-10-01 07:30:00", "In Progress", None),
        (None, "Electrical", "Emergency backup diesel generator test run and battery replacement.", "2026-09-26 06:00:00", "Completed", "2026-09-26 11:00:00"),
        (3, "Cleaning & Sanitation", "Post-event deep pressure wash of open-air plaza pavers.", "2026-10-01 09:00:00", "Pending", None)
    ]
    cursor.executemany(
        "INSERT INTO MAINTENANCE_REQUEST (reported_by_customer_id, issue_type, description, request_date, status, completion_date) VALUES (?, ?, ?, ?, ?, ?)",
        maintenance_requests
    )

    maintenance_assignments = [
        (1, 3, "2026-09-25 09:15:00", "Completed"),
        (2, 2, "2026-09-29 09:00:00", "In Progress"),
        (3, 2, "2026-09-30 10:30:00", "Assigned"),
        (4, 3, "2026-10-01 08:00:00", "In Progress"),
        (5, 2, "2026-09-26 06:30:00", "Completed"),
        (6, 7, "2026-10-01 09:15:00", "Assigned")
    ]
    cursor.executemany(
        "INSERT INTO MAINTENANCE_ASSIGNMENT (request_id, employee_id, assigned_date, assignment_status) VALUES (?, ?, ?, ?)",
        maintenance_assignments
    )

    # 16. Purchases, Purchase Details, Payments & Offer Usages
    # We will insert purchases directly and populate payment and details
    purchases_data = [
        # cust_id, shop_id, purchase_date, payment_method, items: [(prod_id, qty, unit_price, discount)], offer_id
        (1, 2, "2026-09-15 15:30:00", "Credit Card", [(5, 1, 1199.00, 119.90), (7, 1, 249.00, 0.0)], 2),
        (1, 3, "2026-09-15 17:00:00", "UPI", [(9, 2, 6.50, 0.0), (11, 1, 8.25, 0.0)], None),
        (1, 7, "2026-09-22 18:30:00", "Credit Card", [(23, 2, 18.00, 0.0), (24, 1, 12.50, 0.0)], None),
        
        (2, 1, "2026-09-18 14:10:00", "Debit Card", [(1, 2, 49.99, 20.00), (2, 1, 69.99, 14.00)], 1),
        (2, 8, "2026-09-18 16:00:00", "UPI", [(26, 1, 145.00, 21.75)], 7),
        (2, 3, "2026-09-25 11:30:00", "UPI", [(9, 1, 6.50, 0.98), (10, 1, 5.75, 0.86)], 3),
        
        (3, 4, "2026-09-20 13:00:00", "Credit Card", [(13, 1, 160.00, 40.00), (14, 2, 35.00, 17.50)], 4),
        (3, 11, "2026-09-20 15:00:00", "Cash", [(33, 1, 11.49, 0.0)], None),
        
        (4, 2, "2026-09-22 12:40:00", "Credit Card", [(6, 1, 1299.00, 129.90)], 2),
        (4, 1, "2026-09-22 14:20:00", "Net Banking", [(3, 1, 149.99, 30.00)], 1),
        (4, 9, "2026-09-29 17:30:00", "Credit Card", [(29, 1, 16.99, 0.0), (31, 1, 24.00, 0.0)], None),
        
        (5, 6, "2026-09-23 16:15:00", "Credit Card", [(20, 1, 1299.99, 156.00)], 5),
        (5, 10, "2026-09-23 18:00:00", "UPI", [(32, 2, 19.99, 4.00), (33, 3, 8.99, 2.70)], 8),
        
        (6, 5, "2026-09-24 11:00:00", "Debit Card", [(17, 1, 59.99, 0.0), (18, 2, 29.99, 0.0)], None),
        (6, 7, "2026-09-27 19:00:00", "UPI", [(25, 2, 22.00, 13.20), (24, 2, 12.50, 0.0)], 6),
        
        (7, 11, "2026-09-25 13:20:00", "Cash", [(33, 2, 11.49, 0.0), (34, 1, 7.99, 0.0)], None),
        (7, 12, "2026-09-25 14:30:00", "UPI", [(35, 1, 50.00, 0.0)], None),
        
        (8, 8, "2026-09-26 15:45:00", "Credit Card", [(27, 1, 68.00, 10.20), (28, 1, 22.00, 3.30)], 7),
        
        (9, 4, "2026-09-28 17:15:00", "UPI", [(15, 1, 130.00, 32.50)], 4),
        (9, 10, "2026-09-28 18:30:00", "Cash", [(34, 2, 7.50, 0.0)], None),
        
        (10, 9, "2026-09-29 16:00:00", "UPI", [(30, 1, 18.50, 0.0)], None),
        
        (12, 1, "2026-09-30 14:00:00", "Credit Card", [(4, 1, 119.99, 24.00)], 1),
        (12, 3, "2026-09-30 16:30:00", "Debit Card", [(10, 2, 5.75, 1.72), (12, 1, 24.50, 0.0)], 3),
        
        (15, 12, "2026-10-01 11:20:00", "UPI", [(36, 1, 100.00, 0.0)], None)
    ]

    for cust_id, shop_id, p_date, pay_method, items, offer_id in purchases_data:
        total = 0.0
        for p_id, qty, u_price, disc in items:
            total += (qty * u_price) - disc
        total = round(total, 2)
        
        cursor.execute(
            "INSERT INTO PURCHASE (customer_id, shop_id, purchase_date, total_amount) VALUES (?, ?, ?, ?)",
            (cust_id, shop_id, p_date, total)
        )
        purchase_id = cursor.lastrowid
        
        for p_id, qty, u_price, disc in items:
            cursor.execute(
                "INSERT INTO PURCHASE_DETAIL (purchase_id, product_id, quantity, unit_price, discount) VALUES (?, ?, ?, ?, ?)",
                (purchase_id, p_id, qty, u_price, disc)
            )
            # decrement stock
            cursor.execute(
                "UPDATE PRODUCT SET stock_quantity = stock_quantity - ? WHERE product_id = ?",
                (qty, p_id)
            )
            
        cursor.execute(
            "INSERT INTO PAYMENT (purchase_id, payment_date, amount, payment_method, payment_status) VALUES (?, ?, ?, ?, ?)",
            (purchase_id, p_date, total, pay_method, "Completed")
        )
        
        if offer_id:
            cursor.execute(
                "INSERT INTO OFFER_USAGE (offer_id, customer_id, purchase_id, used_date) VALUES (?, ?, ?, ?)",
                (offer_id, cust_id, purchase_id, p_date)
            )

    conn.commit()
    conn.close()
    print("Database successfully seeded with realistic sample data!")

if __name__ == "__main__":
    seed_database()
