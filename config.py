# ====================================================================
# MALL MANAGEMENT SYSTEM - DATABASE CONFIGURATION
# File: config.py
# Toggle between SQLite (Default zero-config), PostgreSQL, or MySQL
# ====================================================================

import os

# Options: "sqlite", "postgresql", "mysql"
DB_ENGINE = os.environ.get("MALL_DB_ENGINE", "sqlite")

# SQLite Configuration
SQLITE_DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "mall_management.db")

# PostgreSQL Configuration (Matches local PostgreSQL on Windows)
POSTGRES_CONFIG = {
    "host": os.environ.get("PG_HOST", "localhost"),
    "port": int(os.environ.get("PG_PORT", 5432)),
    "database": os.environ.get("PG_DATABASE", "mall_management_db"),
    "user": os.environ.get("PG_USER", "postgres"),
    "password": os.environ.get("PG_PASSWORD", "postgres")
}

# MySQL Configuration
MYSQL_CONFIG = {
    "host": os.environ.get("MYSQL_HOST", "localhost"),
    "port": int(os.environ.get("MYSQL_PORT", 3306)),
    "database": os.environ.get("MYSQL_DATABASE", "mall_management_db"),
    "user": os.environ.get("MYSQL_USER", "root"),
    "password": os.environ.get("MYSQL_PASSWORD", "")
}
