import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from './Header';
import Footer from './Footer';

function Login() {
  const [isRegistering, setIsRegistering] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');

    if (isRegistering) {
      // Check if account already exists
      const existingPassword = localStorage.getItem(`user_${email}`);
      if (existingPassword) {
        setError("An account with this email already exists!");
        return;
      }
      // Save with unique prefix to avoid conflicts
      localStorage.setItem(`user_${email}`, password);
      localStorage.setItem('currentUser', email);
      // Go to onboarding for new users
      navigate('/onboarding');

    } else {
      // Login — check with unique prefix
      const savedPassword = localStorage.getItem(`user_${email}`);
      if (!savedPassword) {
        setError("Account not found. Please create an account first.");
        return;
      }
      if (savedPassword !== password) {
        setError("Incorrect password. Please try again.");
        return;
      }
      localStorage.setItem('currentUser', email);
      navigate('/dashboard');
    }
  };

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      minHeight: '100vh',
      padding: '20px'
    }}>
      <Header />
      <div style={{
        flex: 1,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center'
      }}>
        <div className="glass-card" style={{ width: '100%', maxWidth: '400px', padding: '40px', textAlign: 'center' }}>
          <div style={{ fontSize: '40px', marginBottom: '10px' }}>🧬</div>
          <h2 style={{ margin: '0 0 5px 0', color: 'var(--primary-blue)' }}>NutriAI Portal</h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginBottom: '20px' }}>
            {isRegistering ? "Create a new patient account" : "Clinical Explainable AI System"}
          </p>

          {error && (
            <div style={{ background: '#ffebee', color: '#c62828', padding: '10px', borderRadius: '8px', marginBottom: '15px', fontSize: '13px', fontWeight: 'bold' }}>
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ textAlign: 'left' }}>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 'bold', color: '#555', marginBottom: '5px' }}>
                EMAIL ADDRESS
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="jane.doe@example.com"
                required
                style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #ddd', fontSize: '14px', boxSizing: 'border-box' }}
              />
            </div>

            <div style={{ textAlign: 'left' }}>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 'bold', color: '#555', marginBottom: '5px' }}>
                PASSWORD
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
                style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #ddd', fontSize: '14px', boxSizing: 'border-box' }}
              />
            </div>

            <button type="submit" className="btn-primary" style={{ marginTop: '10px' }}>
              {isRegistering ? "Create Account" : "Secure Sign In"}
            </button>
          </form>

          <div style={{ marginTop: '20px', fontSize: '13px', color: '#777' }}>
            {isRegistering ? "Already have an account? " : "Don't have an account? "}
            <button
              onClick={() => { setIsRegistering(!isRegistering); setError(''); }}
              style={{ background: 'none', border: 'none', color: 'var(--primary-blue)', fontWeight: 'bold', cursor: 'pointer', padding: 0 }}
            >
              {isRegistering ? "Sign In Here" : "Create One"}
            </button>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}

export default Login;