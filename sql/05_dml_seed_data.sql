BEGIN TRANSACTION;
CREATE TABLE COMPLAINT (
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
INSERT INTO "COMPLAINT" VALUES(1,1,'Cleanliness','Restroom on 2nd floor near cinema was out of hand wash soap and paper towels.','2026-09-28 14:30:00','Resolved','Medium','2026-09-28 16:00:00');
INSERT INTO "COMPLAINT" VALUES(2,2,'Parking','Parking ticket gate at Basement B2 took money but barrier didn''t open immediately.','2026-09-29 11:15:00','Resolved','High','2026-09-29 11:45:00');
INSERT INTO "COMPLAINT" VALUES(3,3,'Facilities','Central escalator moving from Floor 1 to Floor 2 made squeaking sounds and jerked.','2026-09-30 16:45:00','In Progress','Urgent',NULL);
INSERT INTO "COMPLAINT" VALUES(4,4,'Staff Behavior','Store attendant at fashion outlet refused return without supervisor who was unavailable.','2026-10-01 10:00:00','Pending','Medium',NULL);
INSERT INTO "COMPLAINT" VALUES(5,5,'Noise','Acoustics from the promotional speakers at ground atrium were excessively loud for dining.','2026-09-27 19:20:00','Resolved','Low','2026-09-27 20:30:00');
INSERT INTO "COMPLAINT" VALUES(6,6,'Facilities','Water cooler on 3rd floor food court is dispensing warm water.','2026-10-01 11:30:00','Pending','Low',NULL);
INSERT INTO "COMPLAINT" VALUES(7,7,'Security','Unattended luggage seen near cinema entrance for 20 minutes.','2026-09-29 20:00:00','Resolved','Urgent','2026-09-29 20:25:00');
CREATE TABLE COMPLAINT_ASSIGNMENT (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    complaint_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    FOREIGN KEY (complaint_id) REFERENCES COMPLAINT(complaint_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);
INSERT INTO "COMPLAINT_ASSIGNMENT" VALUES(1,1,7,'2026-09-28 14:40:00','Completed');
INSERT INTO "COMPLAINT_ASSIGNMENT" VALUES(2,2,8,'2026-09-29 11:20:00','Completed');
INSERT INTO "COMPLAINT_ASSIGNMENT" VALUES(3,3,3,'2026-09-30 17:00:00','In Progress');
INSERT INTO "COMPLAINT_ASSIGNMENT" VALUES(4,4,4,'2026-10-01 10:15:00','Assigned');
INSERT INTO "COMPLAINT_ASSIGNMENT" VALUES(5,5,1,'2026-09-27 19:30:00','Completed');
INSERT INTO "COMPLAINT_ASSIGNMENT" VALUES(6,6,2,'2026-10-01 11:45:00','Assigned');
INSERT INTO "COMPLAINT_ASSIGNMENT" VALUES(7,7,6,'2026-09-29 20:05:00','Completed');
CREATE TABLE CUSTOMER (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);
INSERT INTO "CUSTOMER" VALUES(1,'Aarav Sharma','+91 98201 11223','aarav.sharma@example.com','2025-10-15');
INSERT INTO "CUSTOMER" VALUES(2,'Priya Patel','+91 98202 22334','priya.patel@example.com','2025-11-01');
INSERT INTO "CUSTOMER" VALUES(3,'Rohan Verma','+91 98203 33445','rohan.verma@example.com','2025-11-20');
INSERT INTO "CUSTOMER" VALUES(4,'Ananya Iyer','+91 98204 44556','ananya.iyer@example.com','2025-12-05');
INSERT INTO "CUSTOMER" VALUES(5,'Vikram Malhotra','+91 98205 55667','vikram.m@example.com','2026-01-10');
INSERT INTO "CUSTOMER" VALUES(6,'Sneha Kulkarni','+91 98206 66778','sneha.k@example.com','2026-01-18');
INSERT INTO "CUSTOMER" VALUES(7,'Kabir Mehta','+91 98207 77889','kabir.mehta@example.com','2026-02-01');
INSERT INTO "CUSTOMER" VALUES(8,'Neha Reddy','+91 98208 88990','neha.reddy@example.com','2026-02-14');
INSERT INTO "CUSTOMER" VALUES(9,'Aditya Roy','+91 98209 99001','aditya.roy@example.com','2026-03-01');
INSERT INTO "CUSTOMER" VALUES(10,'Ishita Sen','+91 98210 10112','ishita.sen@example.com','2026-03-10');
INSERT INTO "CUSTOMER" VALUES(11,'Rahul Deshmukh','+91 98211 12123','rahul.d@example.com','2026-04-05');
INSERT INTO "CUSTOMER" VALUES(12,'Pooja Nair','+91 98212 13134','pooja.nair@example.com','2026-05-12');
INSERT INTO "CUSTOMER" VALUES(13,'Karan Kapoor','+91 98213 14145','karan.k@example.com','2026-06-20');
INSERT INTO "CUSTOMER" VALUES(14,'Ritu Aggarwal','+91 98214 15156','ritu.a@example.com','2026-07-08');
INSERT INTO "CUSTOMER" VALUES(15,'Devendra Singh','+91 98215 16167','dev.singh@example.com','2026-08-15');
CREATE TABLE EMPLOYEE (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL CHECK(department IN ('Security', 'Maintenance', 'Customer Service', 'Housekeeping', 'Operations', 'Management')),
    designation VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL
);
INSERT INTO "EMPLOYEE" VALUES(1,'Rajesh Kulkarni','Operations','Mall Operations Director','+91 98330 11001');
INSERT INTO "EMPLOYEE" VALUES(2,'Suresh Sharma','Maintenance','Chief HVAC & Electrical Tech','+91 98330 22002');
INSERT INTO "EMPLOYEE" VALUES(3,'Amitabh Sen','Maintenance','Elevator & Plumbing Specialist','+91 98330 33003');
INSERT INTO "EMPLOYEE" VALUES(4,'Sunita Desai','Customer Service','Senior Helpdesk Executive','+91 98330 44004');
INSERT INTO "EMPLOYEE" VALUES(5,'Pooja Hegde','Customer Service','Guest Relations Officer','+91 98330 55005');
INSERT INTO "EMPLOYEE" VALUES(6,'Vikramaditya Rao','Security','Head of Mall Security','+91 98330 66006');
INSERT INTO "EMPLOYEE" VALUES(7,'Ramesh Jadhav','Housekeeping','Facility Cleanliness Supervisor','+91 98330 77007');
INSERT INTO "EMPLOYEE" VALUES(8,'Deepak Chawla','Security','Parking & Traffic Warden','+91 98330 88008');
CREATE TABLE EVENT (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_name VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100) NOT NULL,
    capacity INTEGER NOT NULL CHECK(capacity > 0)
);
INSERT INTO "EVENT" VALUES(1,'Grand Autumn Tech Expo 2026','2026-10-10','11:00:00','20:00:00','Central Atrium Ground Floor',250);
INSERT INTO "EVENT" VALUES(2,'Diwali Fashion Gala & Runway','2026-10-18','17:00:00','21:30:00','Main Plaza Level 1',300);
INSERT INTO "EVENT" VALUES(3,'Kids Robotics & STEM Workshop','2026-10-05','10:30:00','13:30:00','Community Hub Level 2',50);
INSERT INTO "EVENT" VALUES(4,'World Food & Artisan Coffee Carnival','2026-10-24','12:00:00','22:00:00','Open Air Terrace Level 4',400);
INSERT INTO "EVENT" VALUES(5,'E-Sports Gaming Championship 2026','2026-10-12','14:00:00','20:00:00','Timezone Arena Level 3',100);
CREATE TABLE EVENT_REGISTRATION (
    registration_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status VARCHAR(20) NOT NULL DEFAULT 'Registered' CHECK(attendance_status IN ('Registered', 'Attended', 'Cancelled')),
    FOREIGN KEY (event_id) REFERENCES EVENT(event_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE,
    UNIQUE(event_id, customer_id)
);
INSERT INTO "EVENT_REGISTRATION" VALUES(1,1,1,'2026-09-20 10:00:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(2,1,2,'2026-09-20 11:30:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(3,1,3,'2026-09-21 15:40:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(4,1,4,'2026-09-22 09:20:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(5,1,5,'2026-09-22 18:10:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(6,2,2,'2026-09-21 12:00:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(7,2,4,'2026-09-23 14:00:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(8,2,6,'2026-09-24 16:30:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(9,3,7,'2026-09-25 11:15:00','Attended');
INSERT INTO "EVENT_REGISTRATION" VALUES(10,3,8,'2026-09-25 12:00:00','Attended');
INSERT INTO "EVENT_REGISTRATION" VALUES(11,4,1,'2026-09-26 14:20:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(12,4,9,'2026-09-26 17:00:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(13,5,3,'2026-09-27 10:00:00','Registered');
INSERT INTO "EVENT_REGISTRATION" VALUES(14,5,10,'2026-09-27 11:45:00','Registered');
CREATE TABLE LEASE (
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
INSERT INTO "LEASE" VALUES(1,1,1,'2024-01-01','2027-12-31',12500,'Active');
INSERT INTO "LEASE" VALUES(2,2,2,'2024-03-01','2028-02-28',16000,'Active');
INSERT INTO "LEASE" VALUES(3,3,3,'2024-05-01','2027-04-30',6500,'Active');
INSERT INTO "LEASE" VALUES(4,4,4,'2024-06-01','2027-05-31',7200,'Active');
INSERT INTO "LEASE" VALUES(5,5,5,'2024-01-15','2026-10-15',9800,'Pending Renewal');
INSERT INTO "LEASE" VALUES(6,6,6,'2024-08-01','2027-07-31',8500,'Active');
INSERT INTO "LEASE" VALUES(7,7,7,'2023-09-01','2028-08-31',22000,'Active');
INSERT INTO "LEASE" VALUES(8,8,8,'2024-11-01','2027-10-31',5800,'Active');
INSERT INTO "LEASE" VALUES(9,9,9,'2023-12-01','2026-09-01',3400,'Expired');
INSERT INTO "LEASE" VALUES(10,10,10,'2024-02-01','2027-01-31',11000,'Active');
INSERT INTO "LEASE" VALUES(11,11,11,'2024-04-01','2027-03-31',4500,'Active');
INSERT INTO "LEASE" VALUES(12,12,12,'2024-07-01','2027-06-30',9000,'Active');
CREATE TABLE MAINTENANCE_ASSIGNMENT (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    request_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    assigned_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Assigned' CHECK(assignment_status IN ('Assigned', 'In Progress', 'Completed')),
    FOREIGN KEY (request_id) REFERENCES MAINTENANCE_REQUEST(request_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);
INSERT INTO "MAINTENANCE_ASSIGNMENT" VALUES(1,1,3,'2026-09-25 09:15:00','Completed');
INSERT INTO "MAINTENANCE_ASSIGNMENT" VALUES(2,2,2,'2026-09-29 09:00:00','In Progress');
INSERT INTO "MAINTENANCE_ASSIGNMENT" VALUES(3,3,2,'2026-09-30 10:30:00','Assigned');
INSERT INTO "MAINTENANCE_ASSIGNMENT" VALUES(4,4,3,'2026-10-01 08:00:00','In Progress');
INSERT INTO "MAINTENANCE_ASSIGNMENT" VALUES(5,5,2,'2026-09-26 06:30:00','Completed');
INSERT INTO "MAINTENANCE_ASSIGNMENT" VALUES(6,6,7,'2026-10-01 09:15:00','Assigned');
CREATE TABLE MAINTENANCE_REQUEST (
    request_id INTEGER PRIMARY KEY AUTOINCREMENT,
    reported_by_customer_id INTEGER,
    issue_type VARCHAR(50) NOT NULL CHECK(issue_type IN ('Electrical', 'HVAC / AC', 'Plumbing', 'Escalator / Elevator', 'Structural', 'Lighting', 'Cleaning & Sanitation')),
    description TEXT NOT NULL,
    request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    completion_date TIMESTAMP,
    FOREIGN KEY (reported_by_customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);
INSERT INTO "MAINTENANCE_REQUEST" VALUES(1,1,'Escalator / Elevator','Routine quarterly lubrication and sensor tuning of main escalator E-03.','2026-09-25 09:00:00','Completed','2026-09-25 14:00:00');
INSERT INTO "MAINTENANCE_REQUEST" VALUES(2,NULL,'HVAC / AC','Cooling tower chiller unit #2 showing lower refrigerant pressure.','2026-09-29 08:30:00','In Progress',NULL);
INSERT INTO "MAINTENANCE_REQUEST" VALUES(3,2,'Lighting','LED strip lighting along west atrium walkway is flickering.','2026-09-30 10:00:00','Pending',NULL);
INSERT INTO "MAINTENANCE_REQUEST" VALUES(4,NULL,'Plumbing','Main drainage trap in B1 food service corridor needs descaling.','2026-10-01 07:30:00','In Progress',NULL);
INSERT INTO "MAINTENANCE_REQUEST" VALUES(5,NULL,'Electrical','Emergency backup diesel generator test run and battery replacement.','2026-09-26 06:00:00','Completed','2026-09-26 11:00:00');
INSERT INTO "MAINTENANCE_REQUEST" VALUES(6,3,'Cleaning & Sanitation','Post-event deep pressure wash of open-air plaza pavers.','2026-10-01 09:00:00','Pending',NULL);
CREATE TABLE MEMBERSHIP (
    membership_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL UNIQUE,
    membership_type VARCHAR(20) NOT NULL DEFAULT 'Regular' CHECK(membership_type IN ('Regular', 'Silver', 'Gold', 'Platinum')),
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    points INTEGER NOT NULL DEFAULT 0 CHECK(points >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK(status IN ('Active', 'Suspended', 'Expired')),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE
);
INSERT INTO "MEMBERSHIP" VALUES(1,1,'Platinum','2025-10-15',1588,'Active');
INSERT INTO "MEMBERSHIP" VALUES(2,2,'Gold','2025-11-01',646,'Active');
INSERT INTO "MEMBERSHIP" VALUES(3,3,'Silver','2025-11-20',298,'Active');
INSERT INTO "MEMBERSHIP" VALUES(4,4,'Platinum','2025-12-05',1251,'Active');
INSERT INTO "MEMBERSHIP" VALUES(5,5,'Gold','2026-01-10',660,'Active');
INSERT INTO "MEMBERSHIP" VALUES(6,6,'Silver','2026-01-18',206,'Active');
INSERT INTO "MEMBERSHIP" VALUES(7,7,'Regular','2026-02-01',68,'Active');
INSERT INTO "MEMBERSHIP" VALUES(8,8,'Regular','2026-02-14',97,'Active');
INSERT INTO "MEMBERSHIP" VALUES(9,9,'Silver','2026-03-01',220,'Active');
INSERT INTO "MEMBERSHIP" VALUES(10,10,'Regular','2026-03-10',41,'Active');
INSERT INTO "MEMBERSHIP" VALUES(11,11,'Regular','2026-04-05',0,'Active');
INSERT INTO "MEMBERSHIP" VALUES(12,12,'Gold','2026-05-12',492,'Active');
INSERT INTO "MEMBERSHIP" VALUES(13,13,'Regular','2026-06-20',30,'Active');
INSERT INTO "MEMBERSHIP" VALUES(14,14,'Regular','2026-07-08',0,'Suspended');
INSERT INTO "MEMBERSHIP" VALUES(15,15,'Silver','2026-08-15',185,'Active');
CREATE TABLE OFFER (
    offer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    offer_name VARCHAR(100) NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL CHECK(discount_percentage >= 0 AND discount_percentage <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);
INSERT INTO "OFFER" VALUES(1,1,'Summer Chic 20% Off',20,'2026-06-01','2026-10-31');
INSERT INTO "OFFER" VALUES(2,2,'Apple Student Advantage',10,'2026-08-01','2026-11-30');
INSERT INTO "OFFER" VALUES(3,3,'Happy Hour Coffee 15%',15,'2026-09-01','2026-12-31');
INSERT INTO "OFFER" VALUES(4,4,'Marathon Season 25% Off',25,'2026-09-15','2026-10-25');
INSERT INTO "OFFER" VALUES(5,6,'Galaxy Fest 12% Off',12,'2026-09-01','2026-10-30');
INSERT INTO "OFFER" VALUES(6,7,'Cinema Tuesday Special 30%',30,'2026-01-01','2026-12-31');
INSERT INTO "OFFER" VALUES(7,8,'Glamour Week 15% Off',15,'2026-09-20','2026-10-10');
INSERT INTO "OFFER" VALUES(8,10,'Gourmet Weekend 10% Off',10,'2026-09-01','2026-12-31');
CREATE TABLE OFFER_USAGE (
    usage_id INTEGER PRIMARY KEY AUTOINCREMENT,
    offer_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    purchase_id INTEGER NOT NULL,
    used_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offer_id) REFERENCES OFFER(offer_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);
INSERT INTO "OFFER_USAGE" VALUES(1,2,1,1,'2026-09-15 15:30:00');
INSERT INTO "OFFER_USAGE" VALUES(2,1,2,4,'2026-09-18 14:10:00');
INSERT INTO "OFFER_USAGE" VALUES(3,7,2,5,'2026-09-18 16:00:00');
INSERT INTO "OFFER_USAGE" VALUES(4,3,2,6,'2026-09-25 11:30:00');
INSERT INTO "OFFER_USAGE" VALUES(5,4,3,7,'2026-09-20 13:00:00');
INSERT INTO "OFFER_USAGE" VALUES(6,2,4,9,'2026-09-22 12:40:00');
INSERT INTO "OFFER_USAGE" VALUES(7,1,4,10,'2026-09-22 14:20:00');
INSERT INTO "OFFER_USAGE" VALUES(8,5,5,12,'2026-09-23 16:15:00');
INSERT INTO "OFFER_USAGE" VALUES(9,8,5,13,'2026-09-23 18:00:00');
INSERT INTO "OFFER_USAGE" VALUES(10,6,6,15,'2026-09-27 19:00:00');
INSERT INTO "OFFER_USAGE" VALUES(11,7,8,18,'2026-09-26 15:45:00');
INSERT INTO "OFFER_USAGE" VALUES(12,4,9,19,'2026-09-28 17:15:00');
INSERT INTO "OFFER_USAGE" VALUES(13,1,12,22,'2026-09-30 14:00:00');
INSERT INTO "OFFER_USAGE" VALUES(14,3,12,23,'2026-09-30 16:30:00');
CREATE TABLE PARKING_ENTRY (
    entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
    vehicle_id INTEGER NOT NULL,
    slot_id INTEGER NOT NULL,
    entry_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exit_time TIMESTAMP,
    parking_fee DECIMAL(8,2) DEFAULT 0 CHECK(parking_fee >= 0),
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    FOREIGN KEY (slot_id) REFERENCES PARKING_SLOT(slot_id)
);
INSERT INTO "PARKING_ENTRY" VALUES(1,1,1,'2026-10-01 10:15:00',NULL,0);
INSERT INTO "PARKING_ENTRY" VALUES(2,2,2,'2026-10-01 11:00:00',NULL,0);
INSERT INTO "PARKING_ENTRY" VALUES(3,3,6,'2026-10-01 11:30:00',NULL,0);
INSERT INTO "PARKING_ENTRY" VALUES(4,4,8,'2026-10-01 12:05:00',NULL,0);
INSERT INTO "PARKING_ENTRY" VALUES(5,5,3,'2026-09-30 14:00:00','2026-09-30 17:30:00',12);
INSERT INTO "PARKING_ENTRY" VALUES(6,6,4,'2026-09-30 15:15:00','2026-09-30 18:45:00',12);
INSERT INTO "PARKING_ENTRY" VALUES(7,7,7,'2026-09-30 16:00:00','2026-09-30 17:15:00',4);
INSERT INTO "PARKING_ENTRY" VALUES(8,8,8,'2026-09-30 12:30:00','2026-09-30 16:00:00',15);
INSERT INTO "PARKING_ENTRY" VALUES(9,9,1,'2026-09-29 18:00:00','2026-09-29 21:00:00',10);
INSERT INTO "PARKING_ENTRY" VALUES(10,10,2,'2026-09-29 11:00:00','2026-09-29 14:00:00',10);
INSERT INTO "PARKING_ENTRY" VALUES(11,1,5,'2026-09-28 17:00:00','2026-09-28 19:30:00',8);
INSERT INTO "PARKING_ENTRY" VALUES(12,2,9,'2026-09-28 13:00:00','2026-09-28 16:45:00',14);
CREATE TABLE PARKING_SLOT (
    slot_id INTEGER PRIMARY KEY AUTOINCREMENT,
    floor VARCHAR(10) NOT NULL CHECK(floor IN ('B1', 'B2', 'B3')),
    slot_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK(vehicle_type IN ('2-Wheeler', '4-Wheeler', 'EV')),
    status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK(status IN ('Available', 'Occupied', 'Reserved', 'Maintenance'))
);
INSERT INTO "PARKING_SLOT" VALUES(1,'B1','B1-101','4-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(2,'B1','B1-102','4-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(3,'B1','B1-103','4-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(4,'B1','B1-104','4-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(5,'B1','B1-105','4-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(6,'B1','B1-106','2-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(7,'B1','B1-107','2-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(8,'B1','B1-108','EV','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(9,'B2','B2-101','4-Wheeler','Occupied');
INSERT INTO "PARKING_SLOT" VALUES(10,'B2','B2-102','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(11,'B2','B2-103','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(12,'B2','B2-104','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(13,'B2','B2-105','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(14,'B2','B2-106','2-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(15,'B2','B2-107','2-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(16,'B2','B2-108','EV','Available');
INSERT INTO "PARKING_SLOT" VALUES(17,'B3','B3-101','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(18,'B3','B3-102','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(19,'B3','B3-103','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(20,'B3','B3-104','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(21,'B3','B3-105','4-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(22,'B3','B3-106','2-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(23,'B3','B3-107','2-Wheeler','Available');
INSERT INTO "PARKING_SLOT" VALUES(24,'B3','B3-108','EV','Available');
CREATE TABLE PAYMENT (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL UNIQUE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
    payment_method VARCHAR(30) NOT NULL CHECK(payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'UPI', 'Net Banking')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Completed' CHECK(payment_status IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE
);
INSERT INTO "PAYMENT" VALUES(1,1,'2026-09-15 15:30:00',1328.1,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(2,2,'2026-09-15 17:00:00',21.25,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(3,3,'2026-09-22 18:30:00',48.5,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(4,4,'2026-09-18 14:10:00',135.97,'Debit Card','Completed');
INSERT INTO "PAYMENT" VALUES(5,5,'2026-09-18 16:00:00',123.25,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(6,6,'2026-09-25 11:30:00',10.41,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(7,7,'2026-09-20 13:00:00',172.5,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(8,8,'2026-09-20 15:00:00',11.49,'Cash','Completed');
INSERT INTO "PAYMENT" VALUES(9,9,'2026-09-22 12:40:00',1169.1,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(10,10,'2026-09-22 14:20:00',119.99,'Net Banking','Completed');
INSERT INTO "PAYMENT" VALUES(11,11,'2026-09-29 17:30:00',40.99,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(12,12,'2026-09-23 16:15:00',1143.99,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(13,13,'2026-09-23 18:00:00',60.25,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(14,14,'2026-09-24 11:00:00',119.97,'Debit Card','Completed');
INSERT INTO "PAYMENT" VALUES(15,15,'2026-09-27 19:00:00',55.8,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(16,16,'2026-09-25 13:20:00',30.97,'Cash','Completed');
INSERT INTO "PAYMENT" VALUES(17,17,'2026-09-25 14:30:00',50,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(18,18,'2026-09-26 15:45:00',76.5,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(19,19,'2026-09-28 17:15:00',97.5,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(20,20,'2026-09-28 18:30:00',15,'Cash','Completed');
INSERT INTO "PAYMENT" VALUES(21,21,'2026-09-29 16:00:00',18.5,'UPI','Completed');
INSERT INTO "PAYMENT" VALUES(22,22,'2026-09-30 14:00:00',95.99,'Credit Card','Completed');
INSERT INTO "PAYMENT" VALUES(23,23,'2026-09-30 16:30:00',34.28,'Debit Card','Completed');
INSERT INTO "PAYMENT" VALUES(24,24,'2026-10-01 11:20:00',100,'UPI','Completed');
CREATE TABLE PRODUCT (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK(stock_quantity >= 0),
    FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id) ON DELETE CASCADE
);
INSERT INTO "PRODUCT" VALUES(1,1,'Oversized Linen Shirt','Fashion & Apparel',49.99,41);
INSERT INTO "PRODUCT" VALUES(2,1,'Tailored Slim Trousers','Fashion & Apparel',69.99,28);
INSERT INTO "PRODUCT" VALUES(3,1,'Wool Blend Trench Coat','Fashion & Apparel',149.99,13);
INSERT INTO "PRODUCT" VALUES(4,1,'Casual Cotton Blazer','Fashion & Apparel',119.99,18);
INSERT INTO "PRODUCT" VALUES(5,2,'iPhone 15 Pro Max 256GB','Electronics & Gadgets',1199,23);
INSERT INTO "PRODUCT" VALUES(6,2,'MacBook Air 15-inch M3','Electronics & Gadgets',1299,16);
INSERT INTO "PRODUCT" VALUES(7,2,'AirPods Pro (2nd Gen)','Electronics & Gadgets',249,48);
INSERT INTO "PRODUCT" VALUES(8,2,'Apple Watch Series 9','Electronics & Gadgets',399,32);
INSERT INTO "PRODUCT" VALUES(9,3,'Caramel Macchiato Venti','Food & Dining',6.5,94);
INSERT INTO "PRODUCT" VALUES(10,3,'Cold Brew Reserve','Food & Dining',5.75,114);
INSERT INTO "PRODUCT" VALUES(11,3,'Smoked Turkey Bagel Sandwich','Food & Dining',8.25,38);
INSERT INTO "PRODUCT" VALUES(12,3,'Starbucks Tumbler 16oz','Food & Dining',24.5,33);
INSERT INTO "PRODUCT" VALUES(13,4,'Air Max 270 Sneakers','Footwear & Sportswear',160,38);
INSERT INTO "PRODUCT" VALUES(14,4,'Dri-FIT Training Tee','Footwear & Sportswear',35,71);
INSERT INTO "PRODUCT" VALUES(15,4,'Pegasus 40 Running Shoes','Footwear & Sportswear',130,26);
INSERT INTO "PRODUCT" VALUES(16,4,'Tech Fleece Jogger','Footwear & Sportswear',110,35);
INSERT INTO "PRODUCT" VALUES(17,5,'Relaxed Fit Denim Jacket','Fashion & Apparel',59.99,48);
INSERT INTO "PRODUCT" VALUES(18,5,'Classic Crewneck Sweater','Fashion & Apparel',29.99,61);
INSERT INTO "PRODUCT" VALUES(19,5,'Chino Shorts','Fashion & Apparel',24.99,80);
INSERT INTO "PRODUCT" VALUES(20,6,'Galaxy S24 Ultra 512GB','Electronics & Gadgets',1299.99,20);
INSERT INTO "PRODUCT" VALUES(21,6,'Galaxy Tab S9 128GB','Electronics & Gadgets',799.99,15);
INSERT INTO "PRODUCT" VALUES(22,6,'Galaxy Buds2 Pro','Electronics & Gadgets',199.99,45);
INSERT INTO "PRODUCT" VALUES(23,7,'VIP Recliner Movie Ticket','Entertainment',18,196);
INSERT INTO "PRODUCT" VALUES(24,7,'Popcorn & Soda Combo XL','Entertainment',12.5,144);
INSERT INTO "PRODUCT" VALUES(25,7,'IMAX 3D Laser Ticket','Entertainment',22,176);
INSERT INTO "PRODUCT" VALUES(26,8,'Dior Sauvage Eau de Parfum','Beauty & Cosmetics',145,28);
INSERT INTO "PRODUCT" VALUES(27,8,'Huda Beauty Eyeshadow Palette','Beauty & Cosmetics',68,38);
INSERT INTO "PRODUCT" VALUES(28,8,'Fenty Gloss Bomb','Beauty & Cosmetics',22,58);
INSERT INTO "PRODUCT" VALUES(29,9,'Atomic Habits by James Clear','Books & Stationery',16.99,53);
INSERT INTO "PRODUCT" VALUES(30,9,'Sapiens by Yuval Noah Harari','Books & Stationery',18.5,40);
INSERT INTO "PRODUCT" VALUES(31,9,'Moleskine Hardcover Journal','Books & Stationery',24,33);
INSERT INTO "PRODUCT" VALUES(32,10,'Extra Virgin Cold Pressed Olive Oil','Supermarket & Groceries',19.99,36);
INSERT INTO "PRODUCT" VALUES(33,10,'Organic Hass Avocados (Pack of 4)','Supermarket & Groceries',8.99,58);
INSERT INTO "PRODUCT" VALUES(34,10,'Belgian Artisanal Dark Chocolate','Supermarket & Groceries',7.5,79);
INSERT INTO "PRODUCT" VALUES(35,11,'Double Whopper Meal with Fries','Food & Dining',11.49,118);
INSERT INTO "PRODUCT" VALUES(36,11,'Crispy Chicken Tenders (8 Pcs)','Food & Dining',7.99,88);
INSERT INTO "PRODUCT" VALUES(37,12,'Gold Play Card ($50 Credits)','Entertainment',50,100);
INSERT INTO "PRODUCT" VALUES(38,12,'VIP Power Card ($100 Credits)','Entertainment',100,80);
CREATE TABLE PURCHASE (
    purchase_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    purchase_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (shop_id) REFERENCES SHOP(shop_id)
);
INSERT INTO "PURCHASE" VALUES(1,1,2,'2026-09-15 15:30:00',1328.1);
INSERT INTO "PURCHASE" VALUES(2,1,3,'2026-09-15 17:00:00',21.25);
INSERT INTO "PURCHASE" VALUES(3,1,7,'2026-09-22 18:30:00',48.5);
INSERT INTO "PURCHASE" VALUES(4,2,1,'2026-09-18 14:10:00',135.97);
INSERT INTO "PURCHASE" VALUES(5,2,8,'2026-09-18 16:00:00',123.25);
INSERT INTO "PURCHASE" VALUES(6,2,3,'2026-09-25 11:30:00',10.41);
INSERT INTO "PURCHASE" VALUES(7,3,4,'2026-09-20 13:00:00',172.5);
INSERT INTO "PURCHASE" VALUES(8,3,11,'2026-09-20 15:00:00',11.49);
INSERT INTO "PURCHASE" VALUES(9,4,2,'2026-09-22 12:40:00',1169.1);
INSERT INTO "PURCHASE" VALUES(10,4,1,'2026-09-22 14:20:00',119.99);
INSERT INTO "PURCHASE" VALUES(11,4,9,'2026-09-29 17:30:00',40.99);
INSERT INTO "PURCHASE" VALUES(12,5,6,'2026-09-23 16:15:00',1143.99);
INSERT INTO "PURCHASE" VALUES(13,5,10,'2026-09-23 18:00:00',60.25);
INSERT INTO "PURCHASE" VALUES(14,6,5,'2026-09-24 11:00:00',119.97);
INSERT INTO "PURCHASE" VALUES(15,6,7,'2026-09-27 19:00:00',55.8);
INSERT INTO "PURCHASE" VALUES(16,7,11,'2026-09-25 13:20:00',30.97);
INSERT INTO "PURCHASE" VALUES(17,7,12,'2026-09-25 14:30:00',50);
INSERT INTO "PURCHASE" VALUES(18,8,8,'2026-09-26 15:45:00',76.5);
INSERT INTO "PURCHASE" VALUES(19,9,4,'2026-09-28 17:15:00',97.5);
INSERT INTO "PURCHASE" VALUES(20,9,10,'2026-09-28 18:30:00',15);
INSERT INTO "PURCHASE" VALUES(21,10,9,'2026-09-29 16:00:00',18.5);
INSERT INTO "PURCHASE" VALUES(22,12,1,'2026-09-30 14:00:00',95.99);
INSERT INTO "PURCHASE" VALUES(23,12,3,'2026-09-30 16:30:00',34.28);
INSERT INTO "PURCHASE" VALUES(24,15,12,'2026-10-01 11:20:00',100);
CREATE TABLE PURCHASE_DETAIL (
    purchase_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK(unit_price >= 0),
    discount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(discount >= 0),
    FOREIGN KEY (purchase_id) REFERENCES PURCHASE(purchase_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
);
INSERT INTO "PURCHASE_DETAIL" VALUES(1,1,5,1,1199,119.9);
INSERT INTO "PURCHASE_DETAIL" VALUES(2,1,7,1,249,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(3,2,9,2,6.5,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(4,2,11,1,8.25,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(5,3,23,2,18,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(6,3,24,1,12.5,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(7,4,1,2,49.99,20);
INSERT INTO "PURCHASE_DETAIL" VALUES(8,4,2,1,69.99,14);
INSERT INTO "PURCHASE_DETAIL" VALUES(9,5,26,1,145,21.75);
INSERT INTO "PURCHASE_DETAIL" VALUES(10,6,9,1,6.5,0.98);
INSERT INTO "PURCHASE_DETAIL" VALUES(11,6,10,1,5.75,0.86);
INSERT INTO "PURCHASE_DETAIL" VALUES(12,7,13,1,160,40);
INSERT INTO "PURCHASE_DETAIL" VALUES(13,7,14,2,35,17.5);
INSERT INTO "PURCHASE_DETAIL" VALUES(14,8,33,1,11.49,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(15,9,6,1,1299,129.9);
INSERT INTO "PURCHASE_DETAIL" VALUES(16,10,3,1,149.99,30);
INSERT INTO "PURCHASE_DETAIL" VALUES(17,11,29,1,16.99,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(18,11,31,1,24,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(19,12,20,1,1299.99,156);
INSERT INTO "PURCHASE_DETAIL" VALUES(20,13,32,2,19.99,4);
INSERT INTO "PURCHASE_DETAIL" VALUES(21,13,33,3,8.99,2.7);
INSERT INTO "PURCHASE_DETAIL" VALUES(22,14,17,1,59.99,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(23,14,18,2,29.99,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(24,15,25,2,22,13.2);
INSERT INTO "PURCHASE_DETAIL" VALUES(25,15,24,2,12.5,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(26,16,33,2,11.49,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(27,16,34,1,7.99,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(28,17,35,1,50,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(29,18,27,1,68,10.2);
INSERT INTO "PURCHASE_DETAIL" VALUES(30,18,28,1,22,3.3);
INSERT INTO "PURCHASE_DETAIL" VALUES(31,19,15,1,130,32.5);
INSERT INTO "PURCHASE_DETAIL" VALUES(32,20,34,2,7.5,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(33,21,30,1,18.5,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(34,22,4,1,119.99,24);
INSERT INTO "PURCHASE_DETAIL" VALUES(35,23,10,2,5.75,1.72);
INSERT INTO "PURCHASE_DETAIL" VALUES(36,23,12,1,24.5,0);
INSERT INTO "PURCHASE_DETAIL" VALUES(37,24,36,1,100,0);
CREATE TABLE SHOP (
    shop_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    contact_no VARCHAR(20)
);
INSERT INTO "SHOP" VALUES(1,'Zara Flagship','Fashion & Apparel','Ground Floor','+91 22 6678 1001');
INSERT INTO "SHOP" VALUES(2,'Apple Store Central','Electronics & Gadgets','Ground Floor','+91 22 4005 2001');
INSERT INTO "SHOP" VALUES(3,'Starbucks Reserve','Food & Dining','Ground Floor','+91 22 6755 3001');
INSERT INTO "SHOP" VALUES(4,'Nike Town','Footwear & Sportswear','1st Floor','+91 80 4123 4001');
INSERT INTO "SHOP" VALUES(5,'H&M Trend','Fashion & Apparel','1st Floor','+91 11 4987 5001');
INSERT INTO "SHOP" VALUES(6,'Samsung Experience Hub','Electronics & Gadgets','1st Floor','+91 12 4488 6001');
INSERT INTO "SHOP" VALUES(7,'Cinepolis VIP Multiplex','Entertainment','3rd Floor','+91 12 4677 7001');
INSERT INTO "SHOP" VALUES(8,'Sephora Beauty Lounge','Beauty & Cosmetics','2nd Floor','+91 22 3555 8001');
INSERT INTO "SHOP" VALUES(9,'Crossword Book Emporium','Books & Stationery','2nd Floor','+91 22 2498 9001');
INSERT INTO "SHOP" VALUES(10,'Nature''s Basket Gourmet','Supermarket & Groceries','Basement B1','+91 22 6123 1112');
INSERT INTO "SHOP" VALUES(11,'Burger King Express','Food & Dining','3rd Floor','+91 22 7100 2223');
INSERT INTO "SHOP" VALUES(12,'Timezone Gaming Arena','Entertainment','3rd Floor','+91 22 6177 3334');
CREATE TABLE TENANT (
    tenant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_name VARCHAR(100) NOT NULL,
    contact_no VARCHAR(20) NOT NULL,
    email VARCHAR(100)
);
INSERT INTO "TENANT" VALUES(1,'Inditex Trent Retail Ltd','+91 22 6678 1000','leasing@inditex.com');
INSERT INTO "TENANT" VALUES(2,'Apple India Retail Pvt Ltd','+91 22 4005 2000','store_leasing@apple.com');
INSERT INTO "TENANT" VALUES(3,'Tata Starbucks Private Ltd','+91 22 6755 3000','realestate@starbucks.co.in');
INSERT INTO "TENANT" VALUES(4,'Nike India Retail Operations','+91 80 4123 4000','retail@nike.com');
INSERT INTO "TENANT" VALUES(5,'H&M Hennes & Mauritz Retail','+91 11 4987 5000','expansion@hm.com');
INSERT INTO "TENANT" VALUES(6,'Samsung Electronics India','+91 12 4488 6000','retail_ops@samsung.com');
INSERT INTO "TENANT" VALUES(7,'Cinepolis Cinemas India','+91 12 4677 7000','projects@cinepolis.com');
INSERT INTO "TENANT" VALUES(8,'Reliance Brands (Sephora)','+91 22 3555 8000','leasing@relbrands.com');
INSERT INTO "TENANT" VALUES(9,'Crossword Bookstores Ltd','+91 22 2498 9000','franchise@crossword.in');
INSERT INTO "TENANT" VALUES(10,'Nature''s Basket Fine Foods','+91 22 6123 1111','admin@naturesbasket.co.in');
INSERT INTO "TENANT" VALUES(11,'Restaurant Brands Asia (Burger King)','+91 22 7100 2222','property@bk.com');
INSERT INTO "TENANT" VALUES(12,'Timezone Family Entertainment','+91 22 6177 3333','operations@timezone.com');
CREATE TABLE VEHICLE (
    vehicle_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK(vehicle_type IN ('2-Wheeler', '4-Wheeler', 'EV')),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE SET NULL
);
INSERT INTO "VEHICLE" VALUES(1,1,'MH-01-AB-1234','4-Wheeler');
INSERT INTO "VEHICLE" VALUES(2,2,'MH-02-CD-5678','4-Wheeler');
INSERT INTO "VEHICLE" VALUES(3,3,'MH-03-EF-9012','2-Wheeler');
INSERT INTO "VEHICLE" VALUES(4,4,'MH-04-GH-3456','EV');
INSERT INTO "VEHICLE" VALUES(5,5,'MH-01-JK-7890','4-Wheeler');
INSERT INTO "VEHICLE" VALUES(6,6,'MH-02-LM-2345','4-Wheeler');
INSERT INTO "VEHICLE" VALUES(7,7,'MH-03-NP-6789','2-Wheeler');
INSERT INTO "VEHICLE" VALUES(8,8,'MH-04-QR-0123','EV');
INSERT INTO "VEHICLE" VALUES(9,9,'MH-01-ST-4567','4-Wheeler');
INSERT INTO "VEHICLE" VALUES(10,10,'MH-02-UV-8901','2-Wheeler');
CREATE INDEX idx_customer_phone ON CUSTOMER(phone);
CREATE INDEX idx_product_shop ON PRODUCT(shop_id);
CREATE INDEX idx_purchase_customer ON PURCHASE(customer_id);
CREATE INDEX idx_purchase_shop ON PURCHASE(shop_id);
CREATE INDEX idx_purchase_date ON PURCHASE(purchase_date);
CREATE INDEX idx_parking_slot_status ON PARKING_SLOT(status, floor);
CREATE INDEX idx_complaint_status ON COMPLAINT(status, priority);
CREATE INDEX idx_maintenance_status ON MAINTENANCE_REQUEST(status);
CREATE INDEX idx_lease_dates ON LEASE(lease_start, lease_end, lease_status);
CREATE VIEW vw_shop_sales AS
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
CREATE VIEW vw_customer_summary AS
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
CREATE VIEW vw_parking_status AS
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
CREATE VIEW vw_lease_overview AS
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
CREATE VIEW vw_complaints_detail AS
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
CREATE VIEW vw_maintenance_overview AS
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
CREATE VIEW vw_event_attendance AS
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
CREATE TRIGGER trg_reduce_product_stock
AFTER INSERT ON PURCHASE_DETAIL
FOR EACH ROW
BEGIN
    UPDATE PRODUCT
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END;
CREATE TRIGGER trg_award_loyalty_points
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
CREATE TRIGGER trg_occupy_parking_slot
AFTER INSERT ON PARKING_ENTRY
BEGIN
    UPDATE PARKING_SLOT
    SET status = 'Occupied'
    WHERE slot_id = NEW.slot_id;
END;
CREATE TRIGGER trg_release_parking_slot
AFTER UPDATE OF exit_time ON PARKING_ENTRY
WHEN NEW.exit_time IS NOT NULL AND OLD.exit_time IS NULL
BEGIN
    UPDATE PARKING_SLOT
    SET status = 'Available'
    WHERE slot_id = NEW.slot_id;
END;
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('CUSTOMER',15);
INSERT INTO "sqlite_sequence" VALUES('MEMBERSHIP',15);
INSERT INTO "sqlite_sequence" VALUES('TENANT',12);
INSERT INTO "sqlite_sequence" VALUES('SHOP',12);
INSERT INTO "sqlite_sequence" VALUES('LEASE',12);
INSERT INTO "sqlite_sequence" VALUES('PRODUCT',38);
INSERT INTO "sqlite_sequence" VALUES('OFFER',8);
INSERT INTO "sqlite_sequence" VALUES('PARKING_SLOT',24);
INSERT INTO "sqlite_sequence" VALUES('VEHICLE',10);
INSERT INTO "sqlite_sequence" VALUES('PARKING_ENTRY',12);
INSERT INTO "sqlite_sequence" VALUES('EMPLOYEE',8);
INSERT INTO "sqlite_sequence" VALUES('EVENT',5);
INSERT INTO "sqlite_sequence" VALUES('EVENT_REGISTRATION',14);
INSERT INTO "sqlite_sequence" VALUES('COMPLAINT',7);
INSERT INTO "sqlite_sequence" VALUES('COMPLAINT_ASSIGNMENT',7);
INSERT INTO "sqlite_sequence" VALUES('MAINTENANCE_REQUEST',6);
INSERT INTO "sqlite_sequence" VALUES('MAINTENANCE_ASSIGNMENT',6);
INSERT INTO "sqlite_sequence" VALUES('PURCHASE',24);
INSERT INTO "sqlite_sequence" VALUES('PURCHASE_DETAIL',37);
INSERT INTO "sqlite_sequence" VALUES('PAYMENT',24);
INSERT INTO "sqlite_sequence" VALUES('OFFER_USAGE',14);
COMMIT;