import React from 'react';

function Footer() {
  return (
    <footer style={{ marginTop: '40px', padding: '20px', textAlign: 'center', background: '#f8f9fa', borderRadius: '12px', color: '#777', fontSize: '12px' }}>
      <p style={{ margin: '0 0 10px 0', fontWeight: 'bold' }}>© 2026 NutriAI Dissertation Project</p>
      <p style={{ margin: 0, maxWidth: '600px', display: 'inline-block', lineHeight: '1.5' }}>
        <strong>Disclaimer:</strong> This system is a university research prototype. The AI advice and glucose predictions are generated for educational purposes using a simulated dataset and should not replace professional medical advice.
      </p>
    </footer>
  );
}

export default Footer;