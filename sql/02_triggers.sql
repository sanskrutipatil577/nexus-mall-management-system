-- ====================================================================
-- MALL MANAGEMENT SYSTEM - DATABASE TRIGGERS
-- File: sql/02_triggers.sql
-- 4 Automated Business Triggers for Stock, Loyalty, and Parking State
-- ====================================================================

-- --------------------------------------------------------------------
-- TRIGGER 1: Deduct Product Stock Automatically Upon Purchase Item Insert
-- --------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_reduce_product_stock
AFTER INSERT ON PURCHASE_DETAIL
FOR EACH ROW
BEGIN
    UPDATE PRODUCT
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END;

-- --------------------------------------------------------------------
-- TRIGGER 2: Award Loyalty Points & Auto-Upgrade Membership Tier
-- Points Rule: 1 Point per $10 spent on Completed Payment
-- Tier Progression: >=150 Silver, >=400 Gold, >=1000 Platinum
-- --------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_award_loyalty_points
AFTER INSERT ON PAYMENT
WHEN NEW.payment_status = 'Completed'
BEGIN
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

-- --------------------------------------------------------------------
-- TRIGGER 3: Automatically Mark Parking Slot as 'Occupied' on Vehicle Check-In
-- --------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_occupy_parking_slot
AFTER INSERT ON PARKING_ENTRY
BEGIN
    UPDATE PARKING_SLOT
    SET status = 'Occupied'
    WHERE slot_id = NEW.slot_id;
END;

-- --------------------------------------------------------------------
-- TRIGGER 4: Automatically Free Parking Slot to 'Available' on Vehicle Check-Out
-- --------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_release_parking_slot
AFTER UPDATE OF exit_time ON PARKING_ENTRY
WHEN NEW.exit_time IS NOT NULL AND OLD.exit_time IS NULL
BEGIN
    UPDATE PARKING_SLOT
    SET status = 'Available'
    WHERE slot_id = NEW.slot_id;
END;
