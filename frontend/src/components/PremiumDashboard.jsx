import React, { useState, useRef, useEffect } from 'react';
import './PremiumDashboard.css'; 

function PremiumDashboard() {
  const [imagePreview, setImagePreview] = useState(null);
  const [_imageFile, setImageFile] = useState(null);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [foodStats, setFoodStats] = useState({ carbs: 0, protein: 0, fiber: 0, cals: 0 });
  const [error, setError] = useState(null);
  const [analyzing, setAnalyzing] = useState(false);

  const [cameraActive, setCameraActive] = useState(false); 
  const videoRef = useRef(null); 
  const canvasRef = useRef(null);
  
  const [userName, setUserName] = useState('Patient');
  const [userInitials, setUserInitials] = useState('PT');
  const [userPatientId, setUserPatientId] = useState(0);
  const [microbiome, setMicrobiome] = useState({ type: "Loading...", desc: "" });

  useEffect(() => {
    const loggedInEmail = localStorage.getItem('currentUser') || "user@test.com";
    const namePart = loggedInEmail.split('@')[0].replace(/[.0-9]/g, '');
    const formattedName = namePart.charAt(0).toUpperCase() + namePart.slice(1);
    
    setUserName(formattedName);
    setUserInitials(formattedName.substring(0, 2).toUpperCase());

    let numericId = 0;
    for (let i = 0; i < loggedInEmail.length; i++) {
      numericId = (numericId * 31) + loggedInEmail.charCodeAt(i);
      numericId = Math.abs(numericId % 100000);
    }
    setUserPatientId(numericId);

    const enterotypes = [
      { type: "Enterotype 1 (Prevotella-dominant)", desc: "Excellent complex carb metabolism." },
      { type: "Enterotype 2 (Bacteroides-dominant)", desc: "Standard metabolism, sensitive to refined sugars." },
      { type: "Enterotype 3 (Firmicutes-dominant)", desc: "Prone to higher glycemic spikes." }
    ];
    setMicrobiome(enterotypes[numericId % 3]);
  }, []);

  useEffect(() => {
    const currentVideoRef = videoRef.current; 
    return () => {
      if (currentVideoRef && currentVideoRef.srcObject) {
        currentVideoRef.srcObject.getTracks().forEach(track => track.stop());
      }
    };
  }, []);

  const analyzeImageWithCNN = async (file) => {
    if (!file) return;
    setAnalyzing(true);
    setError(null);

    try {
      const formData = new FormData();
      formData.append('file', file);

      const response = await fetch('http://localhost:8000/api/analyse-food-image', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) throw new Error(`CNN API error: ${response.status}`);
      
      const data = await response.json();
      const nutrition = data.nutrition_per_100g;
      const portionScale = 1.5;
      
      setFoodStats({
        cals: Math.round(nutrition.calories * portionScale),
        carbs: Math.round(nutrition.carbs * portionScale * 10) / 10,
        protein: Math.round(nutrition.protein * portionScale * 10) / 10,
        fiber: Math.round(nutrition.fiber * portionScale * 10) / 10,
      });

      if (data.confidence < 40) {
        setError(`⚠️ Low confidence detection (${data.confidence}%). Nutrition values are estimated.`);
      }

    } catch {
      console.error("CNN Analysis failed.");
      setFoodStats({ cals: 200, carbs: 25, protein: 8, fiber: 2 });
      setError("Could not analyse image automatically. Using estimated values.");
    } finally {
      setAnalyzing(false);
    }
  };

  const startCamera = async () => {
    setImagePreview(null);
    setImageFile(null);
    setCameraActive(true);
    setError(null);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.play();
      }
    } catch {
      setError("Failed to access camera. Please check your browser permissions.");
      setCameraActive(false);
    }
  };

  const capturePhoto = () => {
    if (!videoRef.current || !canvasRef.current) return;
    const canvas = canvasRef.current;
    const video = videoRef.current;
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
    if (video.srcObject) video.srcObject.getTracks().forEach(track => track.stop());
    const dataUrl = canvas.toDataURL('image/png');
    setImagePreview(dataUrl);
    setCameraActive(false);
    canvas.toBlob((blob) => {
      const file = new File([blob], 'capture.png', { type: 'image/png' });
      setImageFile(file);
      analyzeImageWithCNN(file);
    }, 'image/png');
  };

  const handleImageChange = (e) => {
    if (videoRef.current && videoRef.current.srcObject) {
      videoRef.current.srcObject.getTracks().forEach(track => track.stop());
      setCameraActive(false);
    }
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => setImagePreview(reader.result);
      reader.readAsDataURL(file);
      setImageFile(file);
      analyzeImageWithCNN(file);
    }
  };

  const analyzeMeal = async () => {
    if (!imagePreview) return;
    setLoading(true);
    setResult(null);
    setError(null);
    try {
      const response = await fetch('http://localhost:8000/api/predict', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          patient_id: userPatientId,
          microbiome_type: microbiome.type,
          carbs: foodStats.carbs,
          fiber: foodStats.fiber,
          protein: foodStats.protein,
          calories: foodStats.cals
        }),
      });
      if (!response.ok) throw new Error(`Server responded with a ${response.status} error.`);
      setResult(await response.json());
    } catch {
      setError("Failed to connect to the backend API. Is the Python server running?");
    } finally {
      setLoading(false);
    }
  };

  // ── Helper: what to show in the SHAP/status section ──────────────
  const renderStatusBanner = () => {
    if (!result) return null;

    // EMPTY PLATE — show warning, not drink message
    if (result.status === 'empty_plate') {
      return (
        <div style={{
          background: '#fff7ed',
          borderRadius: '12px',
          padding: '15px',
          textAlign: 'center',
          border: '1px solid #fed7aa'
        }}>
          <p style={{ margin: 0, color: '#c2410c', fontSize: '14px' }}>
            <strong>⚠️ Empty Plate Detected</strong> — No food was found in this photo.
            Please retake the photo with your meal present before eating.
          </p>
        </div>
      );
    }

    // DRINK — show drink message
    if (!result.shap_image_base64) {
      return (
        <div style={{
          background: '#f0f9ff',
          borderRadius: '12px',
          padding: '15px',
          textAlign: 'center',
          border: '1px solid #bae6fd'
        }}>
          <p style={{ margin: 0, color: '#0369a1', fontSize: '14px' }}>
            <strong>Drink Detected</strong> — No glucose model analysis needed.
            Beverages with zero carbohydrates have negligible glycaemic impact.
          </p>
        </div>
      );
    }

    // NORMAL MEAL — show SHAP chart
    return (
      <>
        <button onClick={() => setShowAdvanced(!showAdvanced)} className="btn-toggle-shap">
          {showAdvanced ? '- Hide Clinical Data (SHAP)' : '+ View Clinical Data (SHAP)'}
        </button>
        {showAdvanced && (
          <div className="shap-img-wrapper">
            <img src={`data:image/png;base64,${result.shap_image_base64}`} alt="SHAP" className="shap-img" />
          </div>
        )}
      </>
    );
  };
  // ─────────────────────────────────────────────────────────────────

  return (
    <div className="premium-dashboard-main-wrapper">
      <div className="dashboard-layout">
        
        {/* LEFT COLUMN */}
        <div className="glass-card">
          <div className="profile-header">
            <div className="avatar">{userInitials}</div>
            <div>
              <h2 className="profile-name">{userName}</h2>
              <p className="profile-goal" style={{ color: '#4F46E5', fontWeight: 'bold', fontSize: '13px' }}>
                🧬 Gut Profile: {microbiome.type}
              </p>
              <p style={{ margin: '2px 0 0 0', fontSize: '12px', color: '#6B7280' }}>
                {microbiome.desc}
              </p>
            </div>
          </div>

          <h3 className="section-title">Log Your Next Meal</h3>
          {error && <div className="error-alert">{error}</div>}
          
          <div className="upload-area upload-area-extended">
            {cameraActive ? (
              <div className="camera-container">
                <video ref={videoRef} className="camera-video" />
                <div onClick={capturePhoto} className="capture-btn"></div>
              </div>
            ) : imagePreview ? (
              <div className="scan-container">
                <img src={imagePreview} alt="Meal" className="preview-image" />
                {(loading || analyzing) && (
                  <>
                    <div className="scan-overlay"></div>
                    <div className="scan-line"></div>
                    <div className="scan-badge">
                      {analyzing ? '🔍 IDENTIFYING FOOD...' : 'ANALYZING BIOMARKERS...'}
                    </div>
                  </>
                )}
              </div>
            ) : (
              <div>
                <div style={{ fontSize: '45px', marginBottom: '10px' }}>📸</div>
                <p style={{ margin: 0, fontWeight: '600', color: 'var(--primary-blue)', fontSize: '16px' }}>Scan Your Food</p>
                <p style={{ margin: '5px 0 0 0', fontSize: '13px', color: 'var(--text-muted)' }}>Snap a live photo or upload from library</p>
              </div>
            )}
            {!cameraActive && !imagePreview && (
              <input type="file" accept="image/*" onChange={handleImageChange} className="hidden-file-input" />
            )}
          </div>

          {!imagePreview && !cameraActive && (
            <div className="action-buttons-grid">
              <button onClick={startCamera} className="btn-secondary">📸 Take Photo</button>
              <div style={{ position: 'relative' }}>
                <button className="btn-tertiary">📁 Choose from Library</button>
                <input type="file" accept="image/*" onChange={handleImageChange} className="hidden-file-input" />
              </div>
            </div>
          )}

          {imagePreview && (
            <div className="fade-in" style={{ marginBottom: '25px' }}>
              <div className="nutrition-header">
                <h4 className="nutrition-title">
                  {analyzing ? '🔍 Detecting Nutrition...' : 'Detected Nutrition'}
                </h4>
                <button 
                  onClick={() => { setImagePreview(null); setImageFile(null); if(result) setResult(null); setCameraActive(false); setError(null); }} 
                  className="btn-retake"
                >
                  ✖ Retake
                </button>
              </div>
              {analyzing ? (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px' }}>
                  {[1,2,3,4].map(i => (
                    <div key={i} className="shimmer" style={{ height: '60px', borderRadius: '12px' }}></div>
                  ))}
                </div>
              ) : (
                <div className="macro-grid">
                  <div className="macro-card cals"><div className="macro-value">{foodStats.cals}</div><div className="macro-label">Cals</div></div>
                  <div className="macro-card carbs"><div className="macro-value">{foodStats.carbs}g</div><div className="macro-label">Carbs</div></div>
                  <div className="macro-card protein"><div className="macro-value">{foodStats.protein}g</div><div className="macro-label">Protein</div></div>
                  <div className="macro-card fiber"><div className="macro-value">{foodStats.fiber}g</div><div className="macro-label">Fiber</div></div>
                </div>
              )}
            </div>
          )}

          <button 
            className="btn-primary" 
            onClick={analyzeMeal} 
            disabled={loading || analyzing || !imagePreview || cameraActive}
          >
            {loading ? 'AI is analyzing your biology...' : analyzing ? 'Detecting food...' : 'Predict Glucose Impact'}
          </button>
        </div>

        {/* RIGHT COLUMN */}
        <div className="glass-card" style={{ display: 'flex', flexDirection: 'column' }}>
          <h2 className="dashboard-title">Your Health Dashboard</h2>
          
          {!result && !loading && (
            <div className="empty-state">
              <p>Upload a photo of your food to get personalized AI health insights and track your daily glucose load.</p>
            </div>
          )}

          {loading && (
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '15px' }}>
              <div className="shimmer" style={{ height: '120px', borderRadius: '16px' }}></div>
              <div className="shimmer" style={{ height: '80px', borderRadius: '16px' }}></div>
            </div>
          )}

          {result && !loading && (
            <div className="fade-in">
              <div className="result-header-row">
                <div className="ring-wrapper">
                  <svg width="90" height="90" style={{ position: 'absolute', top: 0, left: 0 }}>
                    <circle cx="45" cy="45" r="36" fill="none" stroke="#f0f0f0" strokeWidth="8" />
                    <circle 
                      cx="45" cy="45" r="36" fill="none" 
                      stroke={result.predicted_spike > 40 ? 'var(--danger)' : 'var(--success)'} 
                      strokeWidth="8" strokeLinecap="round"
                      strokeDasharray="226" 
                      strokeDashoffset={226 - (226 * (Math.min(result.predicted_spike, 80) / 80))} 
                      className="animated-ring"
                    />
                  </svg>
                  <span className="ring-number" style={{ color: result.predicted_spike > 40 ? 'var(--danger)' : 'var(--success)' }}>
                    {result.predicted_spike}
                  </span>
                </div>
                <div>
                  <h3 className="spike-title">Estimated Spike</h3>
                  <p className="spike-subtitle">mg/dL post-meal rise</p>
                </div>
              </div>

              {(() => {
                const loadPercentage = Math.min(Math.round((result.predicted_spike / 80) * 100), 100);
                const isHigh = loadPercentage > 75;
                return (
                  <div className="glucose-load-section">
                    <div className="glucose-load-header">
                      <span>Meal Glucose Load</span>
                      <span style={{ color: isHigh ? 'var(--danger)' : 'var(--text-muted)', transition: 'color 0.5s ease' }}>
                        {loadPercentage}% of limit
                      </span>
                    </div>
                    <div className="progress-container">
                      <div className="progress-fill" style={{ 
                        width: `${loadPercentage}%`,
                        background: isHigh ? 'linear-gradient(90deg, #FF9500, #FF3B30)' : 'linear-gradient(90deg, #34C759, #FFCC00)'
                      }}></div>
                    </div>
                  </div>
                );
              })()}

              {result.status !== 'empty_plate' && (
                <div style={{ marginBottom: '30px' }}>
                  <h4 className="advice-title">AI Nutritionist Advice</h4>
                  <div className="advice-box">
                    {result.ai_advice 
                      ? <span dangerouslySetInnerHTML={{ __html: 
                          result.ai_advice
                            .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
                            .replace(/\n/g, '<br/>')
                        }} />
                      : "Analyzing your meal metrics..."}
                  </div>
                </div>
              )}

              <div className="shap-section">
                {renderStatusBanner()}
              </div>
            </div>
          )}
        </div>
      </div>
      <canvas ref={canvasRef} style={{ display: 'none' }}></canvas>
    </div>
  );
}

export default PremiumDashboard;