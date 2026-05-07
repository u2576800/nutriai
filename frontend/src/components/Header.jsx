import React from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';

function Header() {
  const navigate = useNavigate();
  const location = useLocation();
 

  // --- NEW: Calculate patientId directly during render ---
  const loggedInEmail = localStorage.getItem('currentUser');
  let patientId = 1; // Default fallback
  if (loggedInEmail) {
    const uniqueNumber = loggedInEmail.charCodeAt(0) + loggedInEmail.length;
    patientId = uniqueNumber % 45;
  }
  // --------------------------------------------------------
  const handleLogout = () => {
    localStorage.removeItem('currentUser'); 
    navigate('/');
  };
  
  const isActive = (path) => location.pathname.startsWith(path);
  const isLoginPage = location.pathname === '/'; 

  return (
    <header className="glass-card" style={{ 
      display: 'flex', 
      justifyContent: 'space-between', 
      alignItems: 'center', 
      padding: '12px 24px', 
      marginBottom: '30px',
      borderRadius: '20px',
      animation: 'none' 
    }}>
      
      {/* Brand Section */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
        <div style={{ fontSize: '24px' }}>🧬</div>
        <div style={{ 
          fontSize: '20px', 
          fontWeight: '800', 
          letterSpacing: '-0.5px',
          background: 'linear-gradient(90deg, var(--primary-blue), #5856D6)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent'
        }}>
          NutriAI
        </div>
      </div>

      {/* Navigation Section */}
      {!isLoginPage && (
        <nav style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          
          <Link 
            to="/dashboard" 
            style={{ 
              textDecoration: 'none', 
              color: isActive('/dashboard') ? 'white' : 'var(--text-main)', 
              background: isActive('/dashboard') ? 'var(--primary-blue)' : 'transparent',
              padding: '8px 20px',
              borderRadius: '14px',
              fontSize: '14px',
              fontWeight: '600',
              transition: 'all 0.2s ease'
            }}
          >
            Dashboard
          </Link>

          {/* --- UPDATED: History Button now uses the dynamic patientId --- */}
          <Link 
            to={`/history/${patientId}`} 
            style={{ 
              textDecoration: 'none', 
              color: isActive('/history') ? 'white' : 'var(--text-main)', 
              background: isActive('/history') ? 'var(--primary-blue)' : 'transparent',
              padding: '8px 20px',
              borderRadius: '14px',
              fontSize: '14px',
              fontWeight: '600',
              transition: 'all 0.2s ease'
            }}
          >
            History
          </Link>

          <button 
            onClick={handleLogout} 
            style={{ 
              background: 'rgba(255, 59, 48, 0.1)',
              border: 'none', 
              color: 'var(--danger)', 
              padding: '8px 20px', 
              borderRadius: '14px', 
              cursor: 'pointer', 
              fontWeight: '700', 
              fontSize: '14px',
              transition: 'all 0.2s ease'
            }}
            onMouseOver={(e) => e.target.style.background = 'rgba(255, 59, 48, 0.2)'}
            onMouseOut={(e) => e.target.style.background = 'rgba(255, 59, 48, 0.1)'}
          >
            Sign Out
          </button>
        </nav>
      )}
    </header>
  );
}

export default Header;