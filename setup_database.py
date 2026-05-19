"""
Olist E-Commerce Project — Database Setup
=========================================
Run this FIRST. Loads all 9 Olist CSVs into a local SQLite database
so you can run SQL queries against them.

Usage:
    python setup_database.py

Requirements:
    pip install pandas
"""

import sqlite3
import pandas as pd
from pathlib import Path

DATA_PATH = Path("data")
DB_PATH   = "olist.db"

# Map: CSV filename → table name in SQLite
TABLES = {
    "olist_orders_dataset.csv":                    "orders",
    "olist_order_items_dataset.csv":               "order_items",
    "olist_order_payments_dataset.csv":            "order_payments",
    "olist_order_reviews_dataset.csv":             "order_reviews",
    "olist_products_dataset.csv":                  "products",
    "olist_customers_dataset.csv":                 "customers",
    "olist_sellers_dataset.csv":                   "sellers",
    "olist_geolocation_dataset.csv":               "geolocation",
    "product_category_name_translation.csv":       "product_category_name_translation",
}

def load_tables(conn):
    for csv_file, table_name in TABLES.items():
        csv_path = DATA_PATH / csv_file
        if not csv_path.exists():
            print(f"  ⚠  Not found: {csv_file} — skipping")
            continue
        df = pd.read_csv(csv_path)
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(f"  ✓  {table_name:<45} {len(df):>7,} rows")

def verify(conn):
    print("\nVerification:")
    cur = conn.cursor()
    for table in TABLES.values():
        try:
            count = cur.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            print(f"  {table:<45} {count:>7,} rows")
        except Exception:
            print(f"  {table:<45}   NOT LOADED")

if __name__ == "__main__":
    print(f"Loading CSVs into {DB_PATH} ...\n")
    with sqlite3.connect(DB_PATH) as conn:
        load_tables(conn)
        verify(conn)
    print(f"\nDone! Open {DB_PATH} with DB Browser for SQLite or query via Python.")
