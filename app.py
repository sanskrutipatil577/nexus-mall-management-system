from flask import Flask, render_template, request, jsonify, send_file, send_from_directory
import os
import math
from datetime import datetime
from db import get_db_connection, init_db, fetch_all, fetch_one, execute_query, run_custom_query, get_sql_logs
from config import DB_ENGINE, SQLITE_DB_PATH as DB_PATH

app = Flask(__name__, static_folder="static", template_folder="templates")
app.config['SECRET_KEY'] = 'mall-management-dbms-secret-key-2026'

# Ensure DB exists on startup
if not os.path.exists(DB_PATH):
    import seed_data
    seed_data.seed_database()

# --------------------------------------------------------------------
# WEB PAGE ROUTES
# --------------------------------------------------------------------

@app.route("/")
def index():
    return render_template("index.html")

# --------------------------------------------------------------------
# 1. DASHBOARD OVERVIEW METRICS
# --------------------------------------------------------------------

@app.route("/api/dashboard/stats", methods=["GET"])
def get_dashboard_stats():
    conn = get_db_connection()
    try:
        # Total Sales
        sales_row = conn.execute("SELECT COALESCE(SUM(total_amount), 0) AS total_sales, COUNT(purchase_id) as total_orders FROM PURCHASE").fetchone()
        
        # Shops & Occupancy
        shop_row = conn.execute("SELECT COUNT(shop_id) AS total_shops FROM SHOP").fetchone()
        lease_row = conn.execute("SELECT COUNT(lease_id) AS active_leases, COALESCE(SUM(monthly_rent), 0) AS total_rent FROM LEASE WHERE lease_status = 'Active'").fetchone()
        
        # Parking Occupancy
        parking_total = conn.execute("SELECT COUNT(slot_id) AS total_slots FROM PARKING_SLOT").fetchone()['total_slots']
        parking_occ = conn.execute("SELECT COUNT(slot_id) AS occupied_slots FROM PARKING_SLOT WHERE status = 'Occupied'").fetchone()['occupied_slots']
        parking_rate = round((parking_occ / parking_total * 100), 1) if parking_total > 0 else 0
        
        # Complaints & Maintenance
        open_complaints = conn.execute("SELECT COUNT(complaint_id) AS count FROM COMPLAINT WHERE status != 'Resolved'").fetchone()['count']
        urgent_complaints = conn.execute("SELECT COUNT(complaint_id) AS count FROM COMPLAINT WHERE status != 'Resolved' AND priority = 'Urgent'").fetchone()['count']
        pending_maintenance = conn.execute("SELECT COUNT(request_id) AS count FROM MAINTENANCE_REQUEST WHERE status != 'Completed'").fetchone()['count']
        
        # Customers & Loyalty
        cust_count = conn.execute("SELECT COUNT(customer_id) AS count FROM CUSTOMER").fetchone()['count']
        returning_cust = conn.execute("""
            SELECT COUNT(*) AS count FROM (
                SELECT customer_id FROM PURCHASE GROUP BY customer_id HAVING COUNT(purchase_id) > 1
            )
        """).fetchone()['count']
        
        # Upcoming Events
        upcoming_events = conn.execute("SELECT COUNT(event_id) AS count FROM EVENT WHERE event_date >= CURRENT_DATE").fetchone()['count']
        
        # Recent Activity
        recent_purchases = fetch_all("""
            SELECT p.purchase_id, c.customer_name, s.shop_name, p.total_amount, p.purchase_date, pay.payment_method
            FROM PURCHASE p
            JOIN CUSTOMER c ON p.customer_id = c.customer_id
            JOIN SHOP s ON p.shop_id = s.shop_id
            LEFT JOIN PAYMENT pay ON p.purchase_id = pay.purchase_id
            ORDER BY p.purchase_date DESC LIMIT 5
        """)
        
        return jsonify({
            "success": True,
            "stats": {
                "total_sales": round(sales_row['total_sales'], 2),
                "total_orders": sales_row['total_orders'],
                "total_shops": shop_row['total_shops'],
                "active_leases": lease_row['active_leases'],
                "monthly_rent_roll": round(lease_row['total_rent'], 2),
                "parking_total": parking_total,
                "parking_occupied": parking_occ,
                "parking_rate": parking_rate,
                "open_complaints": open_complaints,
                "urgent_complaints": urgent_complaints,
                "pending_maintenance": pending_maintenance,
                "total_customers": cust_count,
                "returning_customers": returning_cust,
                "upcoming_events": upcoming_events
            },
            "recent_purchases": recent_purchases
        })
    finally:
        conn.close()

# --------------------------------------------------------------------
# 2. CUSTOMER & MEMBERSHIP APIS
# --------------------------------------------------------------------

@app.route("/api/customers", methods=["GET"])
def get_customers():
    query = """
        SELECT 
            c.customer_id,
            c.customer_name,
            c.phone,
            c.email,
            c.registration_date,
            m.membership_id,
            COALESCE(m.membership_type, 'Regular') AS membership_type,
            COALESCE(m.points, 0) AS points,
            COALESCE(m.status, 'Active') AS membership_status,
            COUNT(p.purchase_id) AS order_count,
            COALESCE(SUM(p.total_amount), 0.0) AS total_spent,
            CASE WHEN COUNT(p.purchase_id) > 1 THEN 1 ELSE 0 END AS is_returning
        FROM CUSTOMER c
        LEFT JOIN MEMBERSHIP m ON c.customer_id = m.customer_id
        LEFT JOIN PURCHASE p ON c.customer_id = p.customer_id
        GROUP BY c.customer_id
        ORDER BY c.customer_id DESC
    """
    customers = fetch_all(query)
    return jsonify({"success": True, "customers": customers})

@app.route("/api/customers", methods=["POST"])
def create_customer():
    data = request.json or {}
    name = data.get("customer_name", "").strip()
    phone = data.get("phone", "").strip()
    email = data.get("email", "").strip() or None
    m_type = data.get("membership_type", "Regular")

    if not name or not phone:
        return jsonify({"success": False, "error": "Name and Phone are required."}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO CUSTOMER (customer_name, phone, email) VALUES (?, ?, ?)",
            (name, phone, email)
        )
        cid = cursor.lastrowid
        cursor.execute(
            "INSERT INTO MEMBERSHIP (customer_id, membership_type, points, status) VALUES (?, ?, 0, 'Active')",
            (cid, m_type)
        )
        conn.commit()
        return jsonify({"success": True, "customer_id": cid, "message": "Customer registered successfully!"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/customers/<int:cid>", methods=["GET"])
def get_customer_details(cid):
    customer = fetch_one("""
        SELECT c.*, m.membership_type, m.points, m.status AS membership_status, m.join_date
        FROM CUSTOMER c
        LEFT JOIN MEMBERSHIP m ON c.customer_id = m.customer_id
        WHERE c.customer_id = ?
    """, (cid,))
    if not customer:
        return jsonify({"success": False, "error": "Customer not found"}), 404

    vehicles = fetch_all("SELECT * FROM VEHICLE WHERE customer_id = ?", (cid,))
    purchases = fetch_all("""
        SELECT p.purchase_id, p.purchase_date, p.total_amount, s.shop_name, pay.payment_method, pay.payment_status
        FROM PURCHASE p
        JOIN SHOP s ON p.shop_id = s.shop_id
        LEFT JOIN PAYMENT pay ON p.purchase_id = pay.purchase_id
        WHERE p.customer_id = ?
        ORDER BY p.purchase_date DESC
    """, (cid,))
    events = fetch_all("""
        SELECT e.event_name, e.event_date, er.registration_date, er.attendance_status
        FROM EVENT_REGISTRATION er
        JOIN EVENT e ON er.event_id = e.event_id
        WHERE er.customer_id = ?
    """, (cid,))
    complaints = fetch_all("""
        SELECT complaint_id, complaint_type, description, status, priority, complaint_date
        FROM COMPLAINT
        WHERE customer_id = ?
        ORDER BY complaint_date DESC
    """, (cid,))

    return jsonify({
        "success": True,
        "customer": customer,
        "vehicles": vehicles,
        "purchases": purchases,
        "events": events,
        "complaints": complaints
    })

# --------------------------------------------------------------------
# 3. SHOPS, TENANTS & LEASES APIS
# --------------------------------------------------------------------

@app.route("/api/shops", methods=["GET"])
def get_shops():
    query = """
        SELECT 
            s.shop_id,
            s.shop_name,
            s.category,
            s.floor,
            s.contact_no,
            l.lease_id,
            l.monthly_rent,
            l.lease_start,
            l.lease_end,
            l.lease_status,
            t.tenant_name,
            t.contact_no AS tenant_contact,
            (SELECT COUNT(*) FROM PRODUCT p WHERE p.shop_id = s.shop_id) AS product_count,
            COALESCE((SELECT SUM(total_amount) FROM PURCHASE pur WHERE pur.shop_id = s.shop_id), 0) AS total_revenue
        FROM SHOP s
        LEFT JOIN LEASE l ON s.shop_id = l.shop_id
        LEFT JOIN TENANT t ON l.tenant_id = t.tenant_id
        ORDER BY s.floor, s.shop_name
    """
    shops = fetch_all(query)
    return jsonify({"success": True, "shops": shops})

@app.route("/api/shops", methods=["POST"])
def create_shop():
    data = request.json or {}
    name = data.get("shop_name", "").strip()
    category = data.get("category", "").strip()
    floor = data.get("floor", "").strip()
    contact = data.get("contact_no", "").strip()

    if not name or not category or not floor:
        return jsonify({"success": False, "error": "Shop Name, Category and Floor are required."}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO SHOP (shop_name, category, floor, contact_no) VALUES (?, ?, ?, ?)",
            (name, category, floor, contact)
        )
        shop_id = cursor.lastrowid
        
        # If tenant information is optionally provided
        tenant_name = data.get("tenant_name", "").strip()
        if tenant_name:
            cursor.execute("SELECT tenant_id FROM TENANT WHERE tenant_name = ?", (tenant_name,))
            existing_tenant = cursor.fetchone()
            if existing_tenant:
                tenant_id = existing_tenant['tenant_id']
            else:
                cursor.execute(
                    "INSERT INTO TENANT (tenant_name, contact_no, email) VALUES (?, ?, ?)",
                    (tenant_name, data.get("tenant_contact", contact), data.get("tenant_email", ""))
                )
                tenant_id = cursor.lastrowid

            rent = float(data.get("monthly_rent", 5000.0))
            l_start = data.get("lease_start", datetime.now().strftime("%Y-%m-%d"))
            l_end = data.get("lease_end", (datetime.now().replace(year=datetime.now().year + 3)).strftime("%Y-%m-%d"))
            cursor.execute(
                "INSERT INTO LEASE (shop_id, tenant_id, lease_start, lease_end, monthly_rent, lease_status) VALUES (?, ?, ?, ?, ?, 'Active')",
                (shop_id, tenant_id, l_start, l_end, rent)
            )

        conn.commit()
        return jsonify({"success": True, "shop_id": shop_id, "message": "Shop created successfully!"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/tenants", methods=["GET"])
def get_tenants():
    tenants = fetch_all("SELECT * FROM TENANT ORDER BY tenant_name")
    return jsonify({"success": True, "tenants": tenants})

@app.route("/api/leases", methods=["GET"])
def get_leases():
    leases = fetch_all("SELECT * FROM vw_lease_overview ORDER BY days_remaining ASC")
    return jsonify({"success": True, "leases": leases})

@app.route("/api/leases", methods=["POST"])
def create_lease():
    data = request.json or {}
    shop_id = data.get("shop_id")
    tenant_id = data.get("tenant_id")
    lease_start = data.get("lease_start")
    lease_end = data.get("lease_end")
    monthly_rent = data.get("monthly_rent", 0.0)
    status = data.get("lease_status", "Active")

    if not shop_id or not tenant_id or not lease_start or not lease_end:
        return jsonify({"success": False, "error": "All lease fields are required."}), 400

    try:
        execute_query(
            "INSERT INTO LEASE (shop_id, tenant_id, lease_start, lease_end, monthly_rent, lease_status) VALUES (?, ?, ?, ?, ?, ?)",
            (shop_id, tenant_id, lease_start, lease_end, monthly_rent, status),
            commit=True
        )
        return jsonify({"success": True, "message": "Lease contract created successfully!"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

# --------------------------------------------------------------------
# 4. PRODUCTS & OFFERS APIS
# --------------------------------------------------------------------

@app.route("/api/products", methods=["GET"])
def get_products():
    shop_id = request.args.get("shop_id")
    category = request.args.get("category")
    
    query = """
        SELECT p.*, s.shop_name, s.floor, s.category AS shop_category
        FROM PRODUCT p
        JOIN SHOP s ON p.shop_id = s.shop_id
        WHERE 1=1
    """
    params = []
    if shop_id:
        query += " AND p.shop_id = ?"
        params.append(shop_id)
    if category:
        query += " AND p.category = ?"
        params.append(category)
        
    query += " ORDER BY p.product_name"
    products = fetch_all(query, params)
    return jsonify({"success": True, "products": products})

@app.route("/api/products", methods=["POST"])
def create_product():
    data = request.json or {}
    shop_id = data.get("shop_id")
    name = data.get("product_name", "").strip()
    category = data.get("category", "").strip()
    price = float(data.get("price", 0.0))
    stock = int(data.get("stock_quantity", 0))

    if not shop_id or not name or not category or price <= 0:
        return jsonify({"success": False, "error": "Valid shop, product name, category and positive price required."}), 400

    try:
        pid = execute_query(
            "INSERT INTO PRODUCT (shop_id, product_name, category, price, stock_quantity) VALUES (?, ?, ?, ?, ?)",
            (shop_id, name, category, price, stock),
            commit=True
        )
        return jsonify({"success": True, "product_id": pid, "message": "Product added successfully!"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route("/api/products/<int:pid>", methods=["PUT"])
def update_product(pid):
    data = request.json or {}
    price = data.get("price")
    stock = data.get("stock_quantity")
    
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        if price is not None and stock is not None:
            cursor.execute("UPDATE PRODUCT SET price = ?, stock_quantity = ? WHERE product_id = ?", (price, stock, pid))
        elif price is not None:
            cursor.execute("UPDATE PRODUCT SET price = ? WHERE product_id = ?", (price, pid))
        elif stock is not None:
            cursor.execute("UPDATE PRODUCT SET stock_quantity = ? WHERE product_id = ?", (stock, pid))
        conn.commit()
        return jsonify({"success": True, "message": "Product updated successfully!"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/offers", methods=["GET"])
def get_offers():
    shop_id = request.args.get("shop_id")
    query = """
        SELECT o.*, s.shop_name 
        FROM OFFER o
        JOIN SHOP s ON o.shop_id = s.shop_id
        WHERE 1=1
    """
    params = []
    if shop_id:
        query += " AND o.shop_id = ?"
        params.append(shop_id)
    query += " ORDER BY o.end_date DESC"
    offers = fetch_all(query, params)
    return jsonify({"success": True, "offers": offers})

@app.route("/api/offers", methods=["POST"])
def create_offer():
    data = request.json or {}
    shop_id = data.get("shop_id")
    name = data.get("offer_name", "").strip()
    pct = float(data.get("discount_percentage", 0.0))
    s_date = data.get("start_date")
    e_date = data.get("end_date")

    if not shop_id or not name or pct <= 0 or not s_date or not e_date:
        return jsonify({"success": False, "error": "All offer details are required."}), 400

    try:
        oid = execute_query(
            "INSERT INTO OFFER (shop_id, offer_name, discount_percentage, start_date, end_date) VALUES (?, ?, ?, ?, ?)",
            (shop_id, name, pct, s_date, e_date),
            commit=True
        )
        return jsonify({"success": True, "offer_id": oid, "message": "Offer created successfully!"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

# --------------------------------------------------------------------
# 5. POINT OF SALE (POS) & PURCHASES APIS (ATOMIC TRANSACTION)
# --------------------------------------------------------------------

@app.route("/api/purchases", methods=["GET"])
def get_purchases():
    purchases = fetch_all("""
        SELECT 
            p.purchase_id,
            p.purchase_date,
            p.total_amount,
            c.customer_id,
            c.customer_name,
            c.phone,
            s.shop_id,
            s.shop_name,
            s.floor,
            pay.payment_method,
            pay.payment_status,
            (SELECT COUNT(*) FROM PURCHASE_DETAIL pd WHERE pd.purchase_id = p.purchase_id) AS item_count
        FROM PURCHASE p
        JOIN CUSTOMER c ON p.customer_id = c.customer_id
        JOIN SHOP s ON p.shop_id = s.shop_id
        LEFT JOIN PAYMENT pay ON p.purchase_id = pay.purchase_id
        ORDER BY p.purchase_date DESC
    """)
    return jsonify({"success": True, "purchases": purchases})

@app.route("/api/purchases/<int:pid>", methods=["GET"])
def get_purchase_receipt(pid):
    purchase = fetch_one("""
        SELECT p.*, c.customer_name, c.phone, c.email, s.shop_name, s.floor, s.contact_no AS shop_phone,
               pay.payment_method, pay.payment_status, pay.payment_date
        FROM PURCHASE p
        JOIN CUSTOMER c ON p.customer_id = c.customer_id
        JOIN SHOP s ON p.shop_id = s.shop_id
        LEFT JOIN PAYMENT pay ON p.purchase_id = pay.purchase_id
        WHERE p.purchase_id = ?
    """, (pid,))
    if not purchase:
        return jsonify({"success": False, "error": "Purchase not found"}), 404

    items = fetch_all("""
        SELECT pd.*, pr.product_name, pr.category
        FROM PURCHASE_DETAIL pd
        JOIN PRODUCT pr ON pd.product_id = pr.product_id
        WHERE pd.purchase_id = ?
    """, (pid,))

    offer = fetch_one("""
        SELECT o.offer_name, o.discount_percentage
        FROM OFFER_USAGE ou
        JOIN OFFER o ON ou.offer_id = o.offer_id
        WHERE ou.purchase_id = ?
    """, (pid,))

    return jsonify({
        "success": True,
        "purchase": purchase,
        "items": items,
        "offer": offer
    })

@app.route("/api/purchases", methods=["POST"])
def create_purchase_transaction():
    """
    Simulates a full POS checkout transaction:
    - Verifies items and stock
    - Calculates discounts / applies offer
    - Inserts Purchase & Details
    - Trigger automatically reduces stock & awards membership points
    - Inserts Payment & Offer Usage
    """
    data = request.json or {}
    customer_id = data.get("customer_id")
    shop_id = data.get("shop_id")
    items = data.get("items", []) # [{product_id, quantity}]
    offer_id = data.get("offer_id")
    payment_method = data.get("payment_method", "Cash")

    if not customer_id or not shop_id or not items:
        return jsonify({"success": False, "error": "Customer, Shop and at least one item are required."}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        
        # Verify Customer & Shop exist
        cursor.execute("SELECT customer_name FROM CUSTOMER WHERE customer_id = ?", (customer_id,))
        if not cursor.fetchone():
            return jsonify({"success": False, "error": "Customer does not exist."}), 404

        # Check offer if provided
        discount_rate = 0.0
        if offer_id:
            cursor.execute("SELECT discount_percentage FROM OFFER WHERE offer_id = ? AND shop_id = ?", (offer_id, shop_id))
            off_row = cursor.fetchone()
            if off_row:
                discount_rate = off_row['discount_percentage'] / 100.0

        # Validate stock and calculate total
        calculated_items = []
        total_amount = 0.0
        
        for itm in items:
            p_id = itm.get("product_id")
            qty = int(itm.get("quantity", 1))
            if qty <= 0:
                continue
                
            cursor.execute("SELECT product_name, price, stock_quantity FROM PRODUCT WHERE product_id = ? AND shop_id = ?", (p_id, shop_id))
            prod = cursor.fetchone()
            if not prod:
                conn.rollback()
                return jsonify({"success": False, "error": f"Product ID {p_id} not found in this shop."}), 400
                
            if prod['stock_quantity'] < qty:
                conn.rollback()
                return jsonify({"success": False, "error": f"Insufficient stock for {prod['product_name']}. Available: {prod['stock_quantity']}"}), 400

            unit_price = float(prod['price'])
            item_subtotal = unit_price * qty
            item_discount = round(item_subtotal * discount_rate, 2)
            item_final = item_subtotal - item_discount
            total_amount += item_final

            calculated_items.append({
                "product_id": p_id,
                "product_name": prod['product_name'],
                "quantity": qty,
                "unit_price": unit_price,
                "discount": item_discount,
                "subtotal": round(item_final, 2)
            })

        total_amount = round(total_amount, 2)

        # 1. Insert Purchase
        cursor.execute(
            "INSERT INTO PURCHASE (customer_id, shop_id, purchase_date, total_amount) VALUES (?, ?, CURRENT_TIMESTAMP, ?)",
            (customer_id, shop_id, total_amount)
        )
        purchase_id = cursor.lastrowid

        # 2. Insert Purchase Details (Triggers deduct stock)
        for c_itm in calculated_items:
            cursor.execute(
                "INSERT INTO PURCHASE_DETAIL (purchase_id, product_id, quantity, unit_price, discount) VALUES (?, ?, ?, ?, ?)",
                (purchase_id, c_itm["product_id"], c_itm["quantity"], c_itm["unit_price"], c_itm["discount"])
            )

        # 3. Insert Payment (Trigger awards membership loyalty points)
        cursor.execute(
            "INSERT INTO PAYMENT (purchase_id, payment_date, amount, payment_method, payment_status) VALUES (?, CURRENT_TIMESTAMP, ?, ?, 'Completed')",
            (purchase_id, total_amount, payment_method)
        )

        # 4. Insert Offer Usage if applicable
        if offer_id and discount_rate > 0:
            cursor.execute(
                "INSERT INTO OFFER_USAGE (offer_id, customer_id, purchase_id, used_date) VALUES (?, ?, ?, CURRENT_TIMESTAMP)",
                (offer_id, customer_id, purchase_id)
            )

        conn.commit()

        return jsonify({
            "success": True,
            "purchase_id": purchase_id,
            "total_amount": total_amount,
            "items_count": len(calculated_items),
            "message": "Transaction completed successfully and receipt generated!"
        })

    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

# --------------------------------------------------------------------
# 6. PARKING MANAGEMENT APIS
# --------------------------------------------------------------------

@app.route("/api/parking/slots", methods=["GET"])
def get_parking_slots():
    floor = request.args.get("floor")
    query = "SELECT * FROM vw_parking_status"
    params = []
    if floor:
        query += " WHERE floor = ?"
        params.append(floor)
    query += " ORDER BY floor, slot_number"
    slots = fetch_all(query, params)
    return jsonify({"success": True, "slots": slots})

@app.route("/api/parking/entry", methods=["POST"])
def parking_entry():
    data = request.json or {}
    v_num = data.get("vehicle_number", "").strip().upper()
    v_type = data.get("vehicle_type", "4-Wheeler")
    cust_id = data.get("customer_id") or None
    requested_slot_id = data.get("slot_id")

    if not v_num:
        return jsonify({"success": False, "error": "Vehicle number is required."}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        
        # Check/create vehicle
        cursor.execute("SELECT vehicle_id FROM VEHICLE WHERE vehicle_number = ?", (v_num,))
        veh = cursor.fetchone()
        if veh:
            vehicle_id = veh['vehicle_id']
            if cust_id:
                cursor.execute("UPDATE VEHICLE SET customer_id = ? WHERE vehicle_id = ?", (cust_id, vehicle_id))
        else:
            cursor.execute(
                "INSERT INTO VEHICLE (customer_id, vehicle_number, vehicle_type) VALUES (?, ?, ?)",
                (cust_id, v_num, v_type)
            )
            vehicle_id = cursor.lastrowid

        # Check if already parked
        cursor.execute("SELECT entry_id FROM PARKING_ENTRY WHERE vehicle_id = ? AND exit_time IS NULL", (vehicle_id,))
        active_entry = cursor.fetchone()
        if active_entry:
            return jsonify({"success": False, "error": "This vehicle is already parked inside the mall!"}), 400

        # Slot selection
        if requested_slot_id:
            cursor.execute("SELECT slot_id, status FROM PARKING_SLOT WHERE slot_id = ?", (requested_slot_id,))
            s_row = cursor.fetchone()
            if not s_row or s_row['status'] != 'Available':
                return jsonify({"success": False, "error": "Requested slot is not available."}), 400
            slot_id = requested_slot_id
        else:
            # Auto-assign available slot for vehicle type
            cursor.execute(
                "SELECT slot_id, slot_number FROM PARKING_SLOT WHERE vehicle_type = ? AND status = 'Available' ORDER BY floor, slot_number LIMIT 1",
                (v_type,)
            )
            s_row = cursor.fetchone()
            if not s_row:
                # Fallback to any available slot
                cursor.execute("SELECT slot_id, slot_number FROM PARKING_SLOT WHERE status = 'Available' LIMIT 1")
                s_row = cursor.fetchone()
                if not s_row:
                    return jsonify({"success": False, "error": "Parking full! No available slots."}), 400
            slot_id = s_row['slot_id']

        # Insert entry (Trigger will update slot status to Occupied)
        cursor.execute(
            "INSERT INTO PARKING_ENTRY (vehicle_id, slot_id, entry_time) VALUES (?, ?, CURRENT_TIMESTAMP)",
            (vehicle_id, slot_id)
        )
        entry_id = cursor.lastrowid
        conn.commit()

        return jsonify({
            "success": True,
            "entry_id": entry_id,
            "slot_id": slot_id,
            "vehicle_number": v_num,
            "message": "Vehicle checked in and slot assigned successfully!"
        })

    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/parking/exit", methods=["POST"])
def parking_exit():
    data = request.json or {}
    entry_id = data.get("entry_id")
    v_num = data.get("vehicle_number", "").strip().upper()

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        if entry_id:
            cursor.execute("""
                SELECT pe.*, v.vehicle_number, v.vehicle_type, ps.slot_number, ps.floor
                FROM PARKING_ENTRY pe
                JOIN VEHICLE v ON pe.vehicle_id = v.vehicle_id
                JOIN PARKING_SLOT ps ON pe.slot_id = ps.slot_id
                WHERE pe.entry_id = ? AND pe.exit_time IS NULL
            """, (entry_id,))
        else:
            cursor.execute("""
                SELECT pe.*, v.vehicle_number, v.vehicle_type, ps.slot_number, ps.floor
                FROM PARKING_ENTRY pe
                JOIN VEHICLE v ON pe.vehicle_id = v.vehicle_id
                JOIN PARKING_SLOT ps ON pe.slot_id = ps.slot_id
                WHERE v.vehicle_number = ? AND pe.exit_time IS NULL
            """, (v_num,))

        entry = cursor.fetchone()
        if not entry:
            return jsonify({"success": False, "error": "No active parking record found for this vehicle."}), 404

        # Calculate duration in hours
        entry_time = datetime.strptime(entry['entry_time'], "%Y-%m-%d %H:%M:%S")
        exit_time = datetime.now()
        duration_hours = max(1, math.ceil((exit_time - entry_time).total_seconds() / 3600.0))

        # Hourly fee based on vehicle type
        rates = {"2-Wheeler": 2.0, "EV": 3.0, "4-Wheeler": 5.0}
        rate = rates.get(entry['vehicle_type'], 4.0)
        fee = round(duration_hours * rate, 2)

        # Update exit_time (Trigger automatically frees PARKING_SLOT)
        cursor.execute(
            "UPDATE PARKING_ENTRY SET exit_time = CURRENT_TIMESTAMP, parking_fee = ? WHERE entry_id = ?",
            (fee, entry['entry_id'])
        )
        conn.commit()

        return jsonify({
            "success": True,
            "entry_id": entry['entry_id'],
            "vehicle_number": entry['vehicle_number'],
            "slot_number": entry['slot_number'],
            "floor": entry['floor'],
            "duration_hours": duration_hours,
            "fee": fee,
            "message": "Vehicle checked out and parking fee settled!"
        })

    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

# --------------------------------------------------------------------
# 7. EVENT MANAGEMENT APIS
# --------------------------------------------------------------------

@app.route("/api/events", methods=["GET"])
def get_events():
    events = fetch_all("SELECT * FROM vw_event_attendance ORDER BY event_date ASC")
    return jsonify({"success": True, "events": events})

@app.route("/api/events", methods=["POST"])
def create_event():
    data = request.json or {}
    name = data.get("event_name", "").strip()
    e_date = data.get("event_date")
    s_time = data.get("start_time")
    e_time = data.get("end_time")
    location = data.get("location", "").strip()
    capacity = int(data.get("capacity", 50))

    if not name or not e_date or not s_time or not location or capacity <= 0:
        return jsonify({"success": False, "error": "All event details and positive capacity are required."}), 400

    try:
        eid = execute_query(
            "INSERT INTO EVENT (event_name, event_date, start_time, end_time, location, capacity) VALUES (?, ?, ?, ?, ?, ?)",
            (name, e_date, s_time, e_time, location, capacity),
            commit=True
        )
        return jsonify({"success": True, "event_id": eid, "message": "Event created successfully!"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route("/api/events/<int:eid>/register", methods=["POST"])
def register_for_event(eid):
    data = request.json or {}
    customer_id = data.get("customer_id")
    if not customer_id:
        return jsonify({"success": False, "error": "Customer ID is required."}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        
        # Check capacity
        cursor.execute("SELECT capacity, (SELECT COUNT(*) FROM EVENT_REGISTRATION WHERE event_id = ?) AS registered FROM EVENT WHERE event_id = ?", (eid, eid))
        evt = cursor.fetchone()
        if not evt:
            return jsonify({"success": False, "error": "Event not found"}), 404
        if evt['registered'] >= evt['capacity']:
            return jsonify({"success": False, "error": "Event capacity full! No seats left."}), 400

        cursor.execute(
            "INSERT INTO EVENT_REGISTRATION (event_id, customer_id, registration_date, attendance_status) VALUES (?, ?, CURRENT_TIMESTAMP, 'Registered')",
            (eid, customer_id)
        )
        conn.commit()
        return jsonify({"success": True, "message": "Successfully registered for event!"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": "Customer is already registered for this event or error occurred."}), 400
    finally:
        conn.close()

@app.route("/api/events/<int:eid>/attendees", methods=["GET"])
def get_event_attendees(eid):
    attendees = fetch_all("""
        SELECT er.registration_id, er.registration_date, er.attendance_status, c.customer_name, c.phone, c.email
        FROM EVENT_REGISTRATION er
        JOIN CUSTOMER c ON er.customer_id = c.customer_id
        WHERE er.event_id = ?
        ORDER BY er.registration_date DESC
    """, (eid,))
    return jsonify({"success": True, "attendees": attendees})

@app.route("/api/events/attendance", methods=["POST"])
def update_event_attendance():
    data = request.json or {}
    reg_id = data.get("registration_id")
    status = data.get("attendance_status", "Attended")
    try:
        execute_query("UPDATE EVENT_REGISTRATION SET attendance_status = ? WHERE registration_id = ?", (status, reg_id), commit=True)
        return jsonify({"success": True, "message": "Attendance updated!"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

# --------------------------------------------------------------------
# 8. COMPLAINT & MAINTENANCE APIS
# --------------------------------------------------------------------

@app.route("/api/complaints", methods=["GET"])
def get_complaints():
    complaints = fetch_all("SELECT * FROM vw_complaints_detail ORDER BY complaint_date DESC")
    return jsonify({"success": True, "complaints": complaints})

@app.route("/api/complaints", methods=["POST"])
def create_complaint():
    data = request.json or {}
    customer_id = data.get("customer_id")
    c_type = data.get("complaint_type", "Cleanliness")
    desc = data.get("description", "").strip()
    priority = data.get("priority", "Medium")

    if not customer_id or not desc:
        return jsonify({"success": False, "error": "Customer and description are required."}), 400

    try:
        cid = execute_query(
            "INSERT INTO COMPLAINT (customer_id, complaint_type, description, priority, status) VALUES (?, ?, ?, ?, 'Pending')",
            (customer_id, c_type, desc, priority),
            commit=True
        )
        return jsonify({"success": True, "complaint_id": cid, "message": "Complaint logged successfully!"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route("/api/complaints/<int:cid>/assign", methods=["POST"])
def assign_complaint(cid):
    data = request.json or {}
    employee_id = data.get("employee_id")
    if not employee_id:
        return jsonify({"success": False, "error": "Employee ID is required."}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("UPDATE COMPLAINT SET status = 'In Progress' WHERE complaint_id = ?", (cid,))
        cursor.execute(
            "INSERT INTO COMPLAINT_ASSIGNMENT (complaint_id, employee_id, assigned_date, assignment_status) VALUES (?, ?, CURRENT_TIMESTAMP, 'In Progress')",
            (cid, employee_id)
        )
        conn.commit()
        return jsonify({"success": True, "message": "Complaint assigned to employee!"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/complaints/<int:cid>/status", methods=["POST"])
def update_complaint_status(cid):
    data = request.json or {}
    status = data.get("status", "Resolved")
    
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        if status == 'Resolved':
            cursor.execute("UPDATE COMPLAINT SET status = ?, resolution_date = CURRENT_TIMESTAMP WHERE complaint_id = ?", (status, cid))
            cursor.execute("UPDATE COMPLAINT_ASSIGNMENT SET assignment_status = 'Completed' WHERE complaint_id = ?", (cid,))
        else:
            cursor.execute("UPDATE COMPLAINT SET status = ? WHERE complaint_id = ?", (status, cid))
        conn.commit()
        return jsonify({"success": True, "message": f"Complaint marked as {status}."})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/maintenance", methods=["GET"])
def get_maintenance():
    maintenance = fetch_all("SELECT * FROM vw_maintenance_overview ORDER BY request_date DESC")
    return jsonify({"success": True, "maintenance": maintenance})

@app.route("/api/maintenance", methods=["POST"])
def create_maintenance():
    data = request.json or {}
    cust_id = data.get("customer_id") or None
    issue_type = data.get("issue_type", "Electrical")
    desc = data.get("description", "").strip()

    if not desc:
        return jsonify({"success": False, "error": "Description is required."}), 400

    try:
        mid = execute_query(
            "INSERT INTO MAINTENANCE_REQUEST (reported_by_customer_id, issue_type, description, status) VALUES (?, ?, ?, 'Pending')",
            (cust_id, issue_type, desc),
            commit=True
        )
        return jsonify({"success": True, "request_id": mid, "message": "Maintenance request submitted!"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route("/api/maintenance/<int:mid>/assign", methods=["POST"])
def assign_maintenance(mid):
    data = request.json or {}
    employee_id = data.get("employee_id")
    if not employee_id:
        return jsonify({"success": False, "error": "Employee ID is required."}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("UPDATE MAINTENANCE_REQUEST SET status = 'In Progress' WHERE request_id = ?", (mid,))
        cursor.execute(
            "INSERT INTO MAINTENANCE_ASSIGNMENT (request_id, employee_id, assigned_date, assignment_status) VALUES (?, ?, CURRENT_TIMESTAMP, 'In Progress')",
            (mid, employee_id)
        )
        conn.commit()
        return jsonify({"success": True, "message": "Maintenance assigned to technician!"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/maintenance/<int:mid>/status", methods=["POST"])
def update_maintenance_status(mid):
    data = request.json or {}
    status = data.get("status", "Completed")
    
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        if status == 'Completed':
            cursor.execute("UPDATE MAINTENANCE_REQUEST SET status = ?, completion_date = CURRENT_TIMESTAMP WHERE request_id = ?", (status, mid))
            cursor.execute("UPDATE MAINTENANCE_ASSIGNMENT SET assignment_status = 'Completed' WHERE request_id = ?", (mid,))
        else:
            cursor.execute("UPDATE MAINTENANCE_REQUEST SET status = ? WHERE request_id = ?", (status, mid))
        conn.commit()
        return jsonify({"success": True, "message": f"Maintenance marked as {status}."})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        conn.close()

@app.route("/api/employees", methods=["GET"])
def get_employees():
    employees = fetch_all("""
        SELECT e.*,
            (SELECT COUNT(*) FROM COMPLAINT_ASSIGNMENT ca WHERE ca.employee_id = e.employee_id AND ca.assignment_status != 'Completed') AS open_complaints,
            (SELECT COUNT(*) FROM MAINTENANCE_ASSIGNMENT ma WHERE ma.employee_id = e.employee_id AND ma.assignment_status != 'Completed') AS open_maintenance
        FROM EMPLOYEE e
        ORDER BY e.department, e.employee_name
    """)
    return jsonify({"success": True, "employees": employees})

# --------------------------------------------------------------------
# 9. REPORTING & ANALYTICS APIS (CASE STUDY SECTION H)
# --------------------------------------------------------------------

@app.route("/api/analytics/all", methods=["GET"])
def get_all_analytics():
    """Returns all 10 analytical datasets requested in the project specification."""
    
    # 1. Total sales by shop
    sales_by_shop = fetch_all("""
        SELECT s.shop_name, s.category, s.floor,
               COUNT(p.purchase_id) as total_orders,
               COALESCE(SUM(p.total_amount), 0) as total_revenue
        FROM SHOP s
        LEFT JOIN PURCHASE p ON s.shop_id = p.shop_id
        GROUP BY s.shop_id
        ORDER BY total_revenue DESC
    """)
    
    # 2. Popular product categories
    popular_categories = fetch_all("""
        SELECT pr.category,
               COUNT(pd.purchase_detail_id) as transactions_count,
               SUM(pd.quantity) as total_units_sold,
               ROUND(SUM((pd.quantity * pd.unit_price) - pd.discount), 2) as total_revenue
        FROM PURCHASE_DETAIL pd
        JOIN PRODUCT pr ON pd.product_id = pr.product_id
        GROUP BY pr.category
        ORDER BY total_units_sold DESC
    """)
    
    # 3. Customer purchase patterns
    customer_patterns = fetch_all("""
        SELECT 
            m.membership_type,
            COUNT(DISTINCT c.customer_id) as customer_count,
            ROUND(AVG(COALESCE(sub.cust_total, 0)), 2) as avg_spent_per_customer,
            ROUND(AVG(COALESCE(sub.order_count, 0)), 1) as avg_orders_per_customer
        FROM CUSTOMER c
        LEFT JOIN MEMBERSHIP m ON c.customer_id = m.customer_id
        LEFT JOIN (
            SELECT customer_id, COUNT(purchase_id) as order_count, SUM(total_amount) as cust_total
            FROM PURCHASE GROUP BY customer_id
        ) sub ON c.customer_id = sub.customer_id
        GROUP BY m.membership_type
        ORDER BY avg_spent_per_customer DESC
    """)
    
    # 4. Parking usage and peak hours
    parking_usage = fetch_all("""
        SELECT 
            ps.floor,
            COUNT(ps.slot_id) as total_slots,
            SUM(CASE WHEN ps.status = 'Occupied' THEN 1 ELSE 0 END) as occupied_slots,
            SUM(CASE WHEN ps.status = 'Available' THEN 1 ELSE 0 END) as available_slots,
            ROUND(CAST(SUM(CASE WHEN ps.status = 'Occupied' THEN 1 ELSE 0 END) AS REAL) / COUNT(ps.slot_id) * 100, 1) as occupancy_rate
        FROM PARKING_SLOT ps
        GROUP BY ps.floor
    """)
    
    parking_peak_hours = fetch_all("""
        SELECT 
            strftime('%H:00', entry_time) as hour_of_day,
            COUNT(entry_id) as vehicle_count,
            COALESCE(SUM(parking_fee), 0) as fee_collected
        FROM PARKING_ENTRY
        GROUP BY hour_of_day
        ORDER BY hour_of_day
    """)
    
    # 5. Event registrations and attendance
    event_stats = fetch_all("""
        SELECT 
            e.event_name,
            e.capacity,
            COUNT(er.registration_id) as registered,
            SUM(CASE WHEN er.attendance_status = 'Attended' THEN 1 ELSE 0 END) as attended,
            ROUND(CAST(COUNT(er.registration_id) AS REAL) / e.capacity * 100, 1) as capacity_utilization
        FROM EVENT e
        LEFT JOIN EVENT_REGISTRATION er ON e.event_id = er.event_id
        GROUP BY e.event_id
    """)
    
    # 6. Most common complaints
    common_complaints = fetch_all("""
        SELECT 
            complaint_type,
            COUNT(complaint_id) as total_complaints,
            SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) as resolved_count,
            SUM(CASE WHEN status != 'Resolved' THEN 1 ELSE 0 END) as pending_count
        FROM COMPLAINT
        GROUP BY complaint_type
        ORDER BY total_complaints DESC
    """)
    
    # 7. Pending maintenance requests
    pending_maintenance = fetch_all("""
        SELECT 
            issue_type,
            COUNT(request_id) as total_requests,
            SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed_count,
            SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as unassigned_pending,
            SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) as in_progress_count
        FROM MAINTENANCE_REQUEST
        GROUP BY issue_type
        ORDER BY total_requests DESC
    """)
    
    # 8. Active and expired leases
    lease_summary = fetch_all("""
        SELECT 
            lease_status,
            COUNT(lease_id) as lease_count,
            COALESCE(SUM(monthly_rent), 0) as total_monthly_rent
        FROM LEASE
        GROUP BY lease_status
    """)
    
    # 9. Payment method usage
    payment_methods = fetch_all("""
        SELECT 
            payment_method,
            COUNT(payment_id) as transaction_count,
            ROUND(SUM(amount), 2) as total_collected,
            ROUND(AVG(amount), 2) as avg_transaction_value
        FROM PAYMENT
        GROUP BY payment_method
        ORDER BY total_collected DESC
    """)
    
    # 10. Returning customers
    returning_customers = fetch_all("""
        SELECT 
            CASE WHEN order_count > 1 THEN 'Returning Customers' ELSE 'First-Time / Single Order' END as customer_type,
            COUNT(customer_id) as customer_count,
            ROUND(SUM(total_spent), 2) as total_spent,
            ROUND(AVG(total_spent), 2) as avg_spent
        FROM (
            SELECT c.customer_id, COUNT(p.purchase_id) as order_count, COALESCE(SUM(p.total_amount), 0) as total_spent
            FROM CUSTOMER c
            JOIN PURCHASE p ON c.customer_id = p.customer_id
            GROUP BY c.customer_id
        ) sub
        GROUP BY customer_type
    """)

    return jsonify({
        "success": True,
        "analytics": {
            "sales_by_shop": sales_by_shop,
            "popular_categories": popular_categories,
            "customer_patterns": customer_patterns,
            "parking_usage": parking_usage,
            "parking_peak_hours": parking_peak_hours,
            "event_stats": event_stats,
            "common_complaints": common_complaints,
            "pending_maintenance": pending_maintenance,
            "lease_summary": lease_summary,
            "payment_methods": payment_methods,
            "returning_customers": returning_customers
        }
    })

# --------------------------------------------------------------------
# 10. DBMS SQL CONSOLE & SCHEMA INTROSPECTION
# --------------------------------------------------------------------

@app.route("/api/sql-console", methods=["POST"])
def execute_sql_console():
    data = request.json or {}
    query = data.get("query", "").strip()
    explain = data.get("explain", False)
    
    if not query:
        return jsonify({"success": False, "error": "Query string is empty."}), 400

    # Basic safety: avoid drop database
    forbidden = ["drop database", "attach database", "detach database"]
    if any(f in query.lower() for f in forbidden):
        return jsonify({"success": False, "error": "Destructive database drop commands are disabled in student console."}), 403

    result = run_custom_query(query, explain=explain)
    return jsonify(result)

@app.route("/api/schema/tables", methods=["GET"])
def get_schema_tables():
    conn = get_db_connection()
    try:
        tables = conn.execute("SELECT name, type FROM sqlite_master WHERE type IN ('table', 'view') AND name NOT LIKE 'sqlite_%' ORDER BY type, name").fetchall()
        schema_info = []
        for t in tables:
            t_name = t['name']
            t_type = t['type']
            cols = conn.execute(f"PRAGMA table_info('{t_name}')").fetchall()
            schema_info.append({
                "name": t_name,
                "type": t_type,
                "columns": [
                    {
                        "cid": c['cid'],
                        "name": c['name'],
                        "type": c['type'],
                        "notnull": bool(c['notnull']),
                        "dflt_value": c['dflt_value'],
                        "pk": bool(c['pk'])
                    } for c in cols
                ]
            })
        return jsonify({"success": True, "schema": schema_info})
    finally:
        conn.close()

@app.route("/api/sql/logs", methods=["GET"])
def get_sql_execution_logs():
    return jsonify({
        "success": True,
        "engine": DB_ENGINE,
        "logs": get_sql_logs()
    })

@app.route("/api/download/<filename>", methods=["GET"])
def download_file(filename):
    # Check in sql/ directory first
    sql_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sql")
    filepath = os.path.join(sql_dir, filename)
    if os.path.exists(filepath):
        return send_file(filepath, as_attachment=True)
        
    # Check in root and data
    allowed = ["schema.sql", "mysql_schema.sql", "seed_data.sql"]
    if filename in allowed:
        filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), filename)
        if not os.path.exists(filepath):
            filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", filename)
        if os.path.exists(filepath):
            return send_file(filepath, as_attachment=True)
    return jsonify({"error": "File not found"}), 404

if __name__ == "__main__":
    print("Starting Mall Management System on http://127.0.0.1:5000")
    app.run(host="0.0.0.0", port=5000, debug=True)
