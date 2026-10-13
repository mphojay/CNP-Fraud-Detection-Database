#Data Rangers 
#4344603
#4334885
#449272
#4352698
#4476498
#4469626
#Python file: run_queries.py


import os
import mysql.connector
from dotenv import load_dotenv
import pandas as pd

# Load environment variables from .env
load_dotenv()

# Storing database information in a dictionary
db_config = {
    "host": os.getenv("DB_HOST"),
    "port": int(os.getenv("DB_PORT")),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASS"),
    "database": os.getenv("DB_NAME"),
    "allow_local_infile": True  # Permits client-side CSV loading
}


def execute_sql_file(cursor, filename):
    #Execute setup statements  from a .sql file.
    with open(filename, "r", encoding="utf-8") as file:
        sql_commands = file.read()

    # Spliting script by semicolon to execute each query sequentially
    statements = [stmt.strip() for stmt in sql_commands.split(";") if stmt.strip()]

    for statement in statements:
        cursor.execute(statement)
        try:
            cursor.fetchall()
        except mysql.connector.errors.InterfaceError:
            pass


def execute_and_display_sql(cursor, filename):
    """Read a SELECT SQL file, execute it, and return a formatted Pandas DataFrame."""
    with open(filename, "r", encoding="utf-8") as file:
        query = file.read()

    cursor.execute(query)
    results = cursor.fetchall()

    # Extracting column headers from query metadata
    columns = [column[0] for column in cursor.description]

    
    df = pd.DataFrame(results, columns=columns)

    # Inserting row numbers starting at 1
    df.insert(0, "#", range(1, len(df) + 1))

    return df


def run_queries():
    conn = None
    cursor = None

    query_files = [
        "SQ1.sql",
        "SQ2.sql",
        "SQ3.sql",
        "MQ1.sql",
        "MQ2.sql",
        "MQ3.sql",
        "MQ4.sql",
        "CQ1.sql",
        "CQ2.sql",
        "CQ3.sql",
        "CQ4.sql"
    ]

    try:
        # Connecting to MySQL
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(buffered=True)

        print("Connected to the database!")

        
        #Runing setup.sql to build tables & load CSV data
        
        setup_filepath = os.path.join("sql", "setup.sql")
        if os.path.exists(setup_filepath):
            print("\n" + "=" * 100)
            print("POPULATING DATABASE TABLES (setup.sql)")
            print("=" * 100)
            execute_sql_file(cursor, setup_filepath)
            conn.commit()
            print("Database successfully populated with data!")

        
        pd.set_option('display.max_columns', None)
        pd.set_option('display.width', 1000)
        pd.set_option('display.colheader_justify', 'left')

        
        #Executing query files and display results as DataFrames
        
        for filename in query_files:
            filepath = os.path.join("sql", filename)

            print("\n" + "=" * 100)
            print(f"RESULTS FOR {filename}")
            print("=" * 100)

            df = execute_and_display_sql(cursor, filepath)

            # Printing DataFrame with hidden zero-based index
            print(df.to_string(index=False))

        print("\n All setup tasks and queries executed successfully!")

    except mysql.connector.Error as err:
        print("\n Database error:", err)

    except FileNotFoundError as err:
        print("\n SQL file not found:", err)

    except Exception as err:
        print("\n Unexpected error:", err)

    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()
            print("\nConnection closed.")


if __name__ == "__main__":
    run_queries()