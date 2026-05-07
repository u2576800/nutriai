import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

function Onboarding() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [profile, setProfile] = useState({
    ageRange: '',
    sex: '',
    weightRange: '',
    activityLevel: '',
    diabetesStatus: '',
    dietaryPreference: '',
    primaryGoal: '',
  });

  const totalSteps = 3;

  const updateProfile = (key, value) => {
    setProfile(prev => ({ ...prev, [key]: value }));
  };

  const handleNext = () => {
    if (step < totalSteps) setStep(step + 1);
    else {
      // Save profile to localStorage
      const email = localStorage.getItem('currentUser');
      localStorage.setItem(`profile_${email}`, JSON.stringify(profile));
      localStorage.setItem(`onboarded_${email}`, 'true');
      navigate('/dashboard');
    }
  };

  const handleSkip = () => {
    const email = localStorage.getItem('currentUser');
    localStorage.setItem(`onboarded_${email}`, 'true');
    navigate('/dashboard');
  };

  const isStepValid = () => {
    if (step === 1) return profile.ageRange && profile.sex && profile.weightRange;
    if (step === 2) return profile.activityLevel && profile.diabetesStatus && profile.dietaryPreference;
    if (step === 3) return profile.primaryGoal;
    return false;
  };

  const OptionButton = ({ value, current, onClick, emoji, label }) => (
    <button
      onClick={() => onClick(value)}
      style={{
        padding: '12px 16px',
        borderRadius: '12px',
        border: `2px solid ${current === value ? '#4F46E5' : '#e5e7eb'}`,
        background: current === value ? '#EEF2FF' : 'white',
        color: current === value ? '#4F46E5' : '#374151',
        fontWeight: current === value ? '700' : '500',
        fontSize: '14px',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        transition: 'all 0.2s ease',
        textAlign: 'left',
        width: '100%',
      }}
    >
      <span style={{ fontSize: '18px' }}>{emoji}</span>
      {label}
    </button>
  );

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #f0f4ff 0%, #faf5ff 100%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
      fontFamily: 'sans-serif',
    }}>
      <div style={{
        background: 'white',
        borderRadius: '24px',
        padding: '40px',
        width: '100%',
        maxWidth: '480px',
        boxShadow: '0 20px 60px rgba(0,0,0,0.1)',
      }}>

        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: '30px' }}>
          <div style={{ fontSize: '40px', marginBottom: '8px' }}>🧬</div>
          <h2 style={{ margin: '0 0 4px 0', color: '#4F46E5', fontSize: '22px' }}>
            Personalise Your Profile
          </h2>
          <p style={{ margin: 0, color: '#6b7280', fontSize: '14px' }}>
            Help NutriAI give you more accurate predictions
          </p>
        </div>

        {/* Progress Bar */}
        <div style={{ marginBottom: '30px' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            marginBottom: '8px',
            fontSize: '12px',
            color: '#9ca3af',
            fontWeight: '600',
          }}>
            <span>Step {step} of {totalSteps}</span>
            <span>{Math.round((step / totalSteps) * 100)}% Complete</span>
          </div>
          <div style={{ background: '#f3f4f6', borderRadius: '999px', height: '6px' }}>
            <div style={{
              background: 'linear-gradient(90deg, #4F46E5, #7C3AED)',
              borderRadius: '999px',
              height: '6px',
              width: `${(step / totalSteps) * 100}%`,
              transition: 'width 0.4s ease',
            }} />
          </div>
        </div>

        {/* ============ STEP 1 ============ */}
        {step === 1 && (
          <div>
            <h3 style={{ margin: '0 0 20px 0', fontSize: '16px', color: '#111827' }}>
              Basic Information
            </h3>

            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#6b7280', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Age Range
            </label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginBottom: '20px' }}>
              {[
                { v: '18-25', e: '🧑', l: '18 – 25' },
                { v: '26-35', e: '👨', l: '26 – 35' },
                { v: '36-45', e: '🧔', l: '36 – 45' },
                { v: '46-55', e: '👴', l: '46 – 55' },
                { v: '55+',   e: '👵', l: '55+' },
              ].map(({ v, e, l }) => (
                <OptionButton key={v} value={v} current={profile.ageRange}
                  onClick={val => updateProfile('ageRange', val)} emoji={e} label={l} />
              ))}
            </div>

            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#6b7280', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Biological Sex
            </label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '8px', marginBottom: '20px' }}>
              {[
                { v: 'Male',   e: '♂️', l: 'Male' },
                { v: 'Female', e: '♀️', l: 'Female' },
                { v: 'Other',  e: '⚧️', l: 'Other' },
              ].map(({ v, e, l }) => (
                <OptionButton key={v} value={v} current={profile.sex}
                  onClick={val => updateProfile('sex', val)} emoji={e} label={l} />
              ))}
            </div>

            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#6b7280', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Weight Range
            </label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
              {[
                { v: 'under-60', e: '⚡', l: 'Under 60kg' },
                { v: '60-75',   e: '🏃', l: '60 – 75kg' },
                { v: '75-90',   e: '💪', l: '75 – 90kg' },
                { v: '90+',     e: '🏋️', l: '90kg+' },
              ].map(({ v, e, l }) => (
                <OptionButton key={v} value={v} current={profile.weightRange}
                  onClick={val => updateProfile('weightRange', val)} emoji={e} label={l} />
              ))}
            </div>
          </div>
        )}

        {/* ============ STEP 2 ============ */}
        {step === 2 && (
          <div>
            <h3 style={{ margin: '0 0 20px 0', fontSize: '16px', color: '#111827' }}>
              Health & Lifestyle
            </h3>

            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#6b7280', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Activity Level
            </label>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
              {[
                { v: 'sedentary',   e: '🪑', l: 'Sedentary — little or no exercise' },
                { v: 'light',       e: '🚶', l: 'Lightly active — 1-3 days/week' },
                { v: 'moderate',    e: '🏃', l: 'Moderately active — 3-5 days/week' },
                { v: 'very-active', e: '🏋️', l: 'Very active — 6-7 days/week' },
              ].map(({ v, e, l }) => (
                <OptionButton key={v} value={v} current={profile.activityLevel}
                  onClick={val => updateProfile('activityLevel', val)} emoji={e} label={l} />
              ))}
            </div>

            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#6b7280', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Diabetes Status
            </label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginBottom: '20px' }}>
              {[
                { v: 'none',         e: '✅', l: 'No diabetes' },
                { v: 'type1',        e: '💉', l: 'Type 1' },
                { v: 'type2',        e: '📊', l: 'Type 2' },
                { v: 'prediabetic',  e: '⚠️', l: 'Pre-diabetic' },
              ].map(({ v, e, l }) => (
                <OptionButton key={v} value={v} current={profile.diabetesStatus}
                  onClick={val => updateProfile('diabetesStatus', val)} emoji={e} label={l} />
              ))}
            </div>

            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#6b7280', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Dietary Preference
            </label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
              {[
                { v: 'none',        e: '🍽️', l: 'No restriction' },
                { v: 'vegetarian',  e: '🥗', l: 'Vegetarian' },
                { v: 'vegan',       e: '🌱', l: 'Vegan' },
                { v: 'gluten-free', e: '🌾', l: 'Gluten-free' },
              ].map(({ v, e, l }) => (
                <OptionButton key={v} value={v} current={profile.dietaryPreference}
                  onClick={val => updateProfile('dietaryPreference', val)} emoji={e} label={l} />
              ))}
            </div>
          </div>
        )}

        {/* ============ STEP 3 ============ */}
        {step === 3 && (
          <div>
            <h3 style={{ margin: '0 0 20px 0', fontSize: '16px', color: '#111827' }}>
              Your Primary Goal
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {[
                { v: 'manage-sugar',   e: '📉', l: 'Manage blood sugar levels' },
                { v: 'lose-weight',    e: '⚖️', l: 'Lose weight' },
                { v: 'gut-health',     e: '🦠', l: 'Improve gut health' },
                { v: 'general',        e: '💚', l: 'General wellness' },
                { v: 'diabetes-mgmt',  e: '💉', l: 'Diabetes management' },
              ].map(({ v, e, l }) => (
                <OptionButton key={v} value={v} current={profile.primaryGoal}
                  onClick={val => updateProfile('primaryGoal', val)} emoji={e} label={l} />
              ))}
            </div>
          </div>
        )}

        {/* Navigation Buttons */}
        <div style={{ display: 'flex', gap: '12px', marginTop: '30px' }}>
          {step > 1 && (
            <button
              onClick={() => setStep(step - 1)}
              style={{
                flex: 1,
                padding: '14px',
                borderRadius: '12px',
                border: '2px solid #e5e7eb',
                background: 'white',
                color: '#374151',
                fontWeight: '600',
                fontSize: '15px',
                cursor: 'pointer',
              }}
            >
              ← Back
            </button>
          )}
          <button
            onClick={handleNext}
            disabled={!isStepValid()}
            style={{
              flex: 2,
              padding: '14px',
              borderRadius: '12px',
              border: 'none',
              background: isStepValid()
                ? 'linear-gradient(135deg, #4F46E5, #7C3AED)'
                : '#e5e7eb',
              color: isStepValid() ? 'white' : '#9ca3af',
              fontWeight: '700',
              fontSize: '15px',
              cursor: isStepValid() ? 'pointer' : 'not-allowed',
              transition: 'all 0.2s ease',
            }}
          >
            {step === totalSteps ? '🚀 Go to Dashboard' : 'Continue →'}
          </button>
        </div>

        {/* Skip option */}
        <div style={{ textAlign: 'center', marginTop: '16px' }}>
          <button
            onClick={handleSkip}
            style={{
              background: 'none',
              border: 'none',
              color: '#9ca3af',
              fontSize: '13px',
              cursor: 'pointer',
              textDecoration: 'underline',
            }}
          >
            Skip for now
          </button>
        </div>

      </div>
    </div>
  );
}

export default Onboarding;