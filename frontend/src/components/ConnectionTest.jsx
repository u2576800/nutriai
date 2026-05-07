import React, { useState, useEffect } from 'react';

function ConnectionTest() {
  const [error, setError] = useState(null);

  useEffect(() => {
    const testConnection = async () => {
      try {
        const response = await fetch('http://localhost:8000/api/test-connection');
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        // We don't need to save the message anymore, just knowing it didn't crash is enough!
      } catch (err) {
        console.error("Connection error:", err); // Now the 'err' variable is being used!
        setError("System Offline: Cannot reach FastAPI backend.");
      }
    };
    testConnection();
  }, []);

  return (
    <div style={{ 
      backgroundColor: error ? '#fdf7f7' : '#e6f4ea', 
      color: error ? '#d9534f' : '#28a745',
      padding: '12px 20px', 
      borderRadius: '8px', 
      fontSize: '14px',
      fontWeight: '500',
      display: 'flex',
      alignItems: 'center',
      boxShadow: '0 2px 4px rgba(0,0,0,0.05)',
      marginBottom: '20px'
    }}>
      <span style={{ marginRight: '10px', fontSize: '18px' }}>{error ? '⚠️' : '🟢'}</span>
      {error ? error : "System Online: Core API is successfully connected."}
    </div>
  );
}

export default ConnectionTest;