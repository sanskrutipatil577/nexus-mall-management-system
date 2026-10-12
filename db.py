import sqlite3
import os
import time
from datetime import datetime
from config import DB_ENGINE, SQLITE_DB_PATH, POSTGRES_CONFIG, MYSQL_CONFIG

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SCHEMA_PATH = os.path.join(BASE_DIR, "sql", "01_ddl_tables_and_constraints.sql")
TRIGGERS_PATH = os.path.join(BASE_DIR, "sql", "02_triggers.sql")
VIEWS_PATH = os.path.join(BASE_DIR, "sql", "03_views.sql")

# In-Memory SQL Query Execution Logger for Viva Demonstration
SQL_QUERY_LOG = []
MAX_LOG_ENTRIES = 100

def record_sql_log(query, params, duration_ms, is_write=False):
    """Logs raw SQL executions with timing and timestamps for teacher examination."""
    global SQL_QUERY_LOG
    query_clean = " ".join(query.strip().split())
    
    # Classify query
    upper_q = query_clean.upper()
    q_type = "SELECT"
    if upper_q.startswith("INSERT"): q_type = "INSERT"
    elif upper_q.startswith("UPDATE"): q_type = "UPDATE"
    elif upper_q.startswith("DELETE"): q_type = "DELETE"
    elif "TRIGGER" in upper_q: q_type = "TRIGGER"
    elif upper_q.startswith("CREATE VIEW"): q_type = "VIEW"
    elif upper_q.startswith("EXPLAIN"): q_type = "EXPLAIN"

    entry = {
        "id": len(SQL_QUERY_LOG) + 1,
        "timestamp": datetime.now().strftime("%H:%M:%S.%f")[:-3],
        "type": q_type,
        "query": query_clean,
        "params": [str(p) for p in params] if params else [],
        "duration_ms": round(duration_ms, 2)
    }
    SQL_QUERY_LOG.insert(0, entry)
    if len(SQL_QUERY_LOG) > MAX_LOG_ENTRIES:
        SQL_QUERY_LOG.pop()

def get_sql_logs():
    return SQL_QUERY_LOG

def get_db_connection():
    """Create and return a database connection based on configured engine."""
    if DB_ENGINE == "postgresql":
        import psycopg2
        import psycopg2.extras
        conn = psycopg2.connect(**POSTGRES_CONFIG)
        conn.autocommit = True
        return conn
    elif DB_ENGINE == "mysql":
        import pymysql
        conn = pymysql.connect(**MYSQL_CONFIG, cursorclass=pymysql.cursors.DictCursor)
        return conn
    else:
        # Default SQLite with foreign keys active
        conn = sqlite3.connect(SQLITE_DB_PATH)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON;")
        return conn

def init_db(force=False):
    """Initialize database tables, views, indexes, and triggers from modular SQL files."""
    os.makedirs(os.path.dirname(SQLITE_DB_PATH), exist_ok=True)
    
    if force and os.path.exists(SQLITE_DB_PATH):
        try:
            os.remove(SQLITE_DB_PATH)
        except Exception as e:
            print(f"Could not remove DB file: {e}")

    conn = get_db_connection()
    try:
        # 1. Run DDL
        if os.path.exists(SCHEMA_PATH):
            with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
                conn.executescript(f.read())
        # 2. Run Views
        if os.path.exists(VIEWS_PATH):
            with open(VIEWS_PATH, "r", encoding="utf-8") as f:
                conn.executescript(f.read())
        # 3. Run Triggers
        if os.path.exists(TRIGGERS_PATH):
            with open(TRIGGERS_PATH, "r", encoding="utf-8") as f:
                conn.executescript(f.read())
        conn.commit()
    finally:
        conn.close()

def execute_query(query, params=(), commit=False):
    """Execute a query and optionally commit. Logs query execution."""
    conn = get_db_connection()
    cursor = conn.cursor()
    start_time = time.time()
    try:
        cursor.execute(query, params)
        duration_ms = (time.time() - start_time) * 1000.0
        record_sql_log(query, params, duration_ms, is_write=True)
        if commit:
            conn.commit()
            return cursor.lastrowid or cursor.rowcount
        return cursor
    finally:
        if not commit:
            conn.close()

def fetch_all(query, params=()):
    """Fetch all rows for a query returned as a list of dicts. Logs query execution."""
    conn = get_db_connection()
    start_time = time.time()
    try:
        cursor = conn.cursor()
        cursor.execute(query, params)
        rows = cursor.fetchall()
        duration_ms = (time.time() - start_time) * 1000.0
        record_sql_log(query, params, duration_ms, is_write=False)
        return [dict(row) for row in rows]
    finally:
        conn.close()

def fetch_one(query, params=()):
    """Fetch a single row returned as a dict or None. Logs query execution."""
    conn = get_db_connection()
    start_time = time.time()
    try:
        cursor = conn.cursor()
        cursor.execute(query, params)
        row = cursor.fetchone()
        duration_ms = (time.time() - start_time) * 1000.0
        record_sql_log(query, params, duration_ms, is_write=False)
        return dict(row) if row else None
    finally:
        conn.close()

def run_custom_query(sql_text, explain=False):
    """Safely run user-provided SQL query for DBMS lab demonstration."""
    conn = get_db_connection()
    start_time = time.time()
    try:
        cursor = conn.cursor()
        if explain:
            cursor.execute(f"EXPLAIN QUERY PLAN {sql_text}")
        else:
            cursor.execute(sql_text)
            
        is_select = cursor.description is not None
        duration_ms = (time.time() - start_time) * 1000.0
        record_sql_log(sql_text, [], duration_ms)

        if is_select:
            columns = [col[0] for col in cursor.description]
            raw_rows = cursor.fetchall()
            rows = [list(row) for row in raw_rows]
            return {
                "success": True,
                "columns": columns,
                "rows": rows,
                "row_count": len(rows),
                "duration_ms": round(duration_ms, 2),
                "is_select": True
            }
        else:
            conn.commit()
            return {
                "success": True,
                "columns": ["Result"],
                "rows": [[f"Query executed successfully. Affected rows: {cursor.rowcount}"]],
                "row_count": cursor.rowcount,
                "duration_ms": round(duration_ms, 2),
                "is_select": False
            }
    except Exception as e:
        duration_ms = (time.time() - start_time) * 1000.0
        record_sql_log(sql_text, [], duration_ms)
        return {
            "success": False,
            "error": str(e),
            "duration_ms": round(duration_ms, 2)
        }
    finally:
        conn.close()
