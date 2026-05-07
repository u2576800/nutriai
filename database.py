import sqlite3
import os
from cryptography.fernet import Fernet
from dotenv import load_dotenv

# 1. Load environment variables from the .env file
load_dotenv()

# 2. Grab the encryption key and initialize the lock (cipher)
SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY:
    raise ValueError("No SECRET_KEY found! Make sure it is in your .env file.")
cipher = Fernet(SECRET_KEY.encode())

# 3. Path to store the SQLite database (inside your existing data folder)
DB_PATH = "data/history.db"

def init_db():
    """Creates the history table and indexes if they don't exist."""
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS history_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                actor TEXT NOT NULL,
                encrypted_content BLOB NOT NULL
            )
        ''')
        # This makes searching by session super fast
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_session ON history_logs(session_id)')
        conn.commit()

def save_message(session_id: str, actor: str, raw_content: str):
    """Encrypts a plain text message and saves it to the database."""
    # Turn the text into bytes, then encrypt it
    encrypted_payload = cipher.encrypt(raw_content.encode())
    
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO history_logs (session_id, actor, encrypted_content)
            VALUES (?, ?, ?)
        ''', (session_id, actor, encrypted_payload))
        conn.commit()

def get_history(session_id: str):
    """Retrieves and decrypts the conversation history for a specific session."""
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT timestamp, actor, encrypted_content 
            FROM history_logs 
            WHERE session_id = ? 
            ORDER BY timestamp ASC
        ''', (session_id,))
        rows = cursor.fetchall()
        
    decrypted_history = []
    for row in rows:
        timestamp, actor, encrypted_content = row
        # Decrypt the BLOB back into readable string text
        decrypted_content = cipher.decrypt(encrypted_content).decode()
        decrypted_history.append({
            "timestamp": timestamp,
            "actor": actor,
            "content": decrypted_content
        })
        
    return decrypted_history

# Initialize the database when this file is run directly
if __name__ == "__main__":
    init_db()
    print("Database successfully initialized!")