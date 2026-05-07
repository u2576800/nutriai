import React from 'react';
import { BrowserRouter as Router, Routes, Route, useLocation } from 'react-router-dom';
import Header from './components/Header';
import Footer from './components/Footer';
import Login from './components/Login';
import PremiumDashboard from './components/PremiumDashboard';
import PatientHistory from './components/PatientHistory';
import Onboarding from './components/Onboarding'; // NEW

function AppLayout() {
  const location = useLocation();
  const isLoginPage = location.pathname === '/';
  const isOnboardingPage = location.pathname === '/onboarding'; // NEW

  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '20px', fontFamily: 'sans-serif' }}>
      {!isLoginPage && !isOnboardingPage && <Header />}

      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/onboarding" element={<Onboarding />} /> {/* NEW */}
        <Route path="/dashboard" element={<PremiumDashboard />} />
        <Route path="/history/:patientId" element={<PatientHistory />} />
      </Routes>

      {!isLoginPage && !isOnboardingPage && <Footer />}
    </div>
  );
}

function App() {
  return (
    <Router>
      <AppLayout />
    </Router>
  );
}

export default App;