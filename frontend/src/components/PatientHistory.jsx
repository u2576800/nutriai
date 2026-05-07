import { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, ReferenceLine } from 'recharts';

export default function PatientHistory() {
  const [userName, setUserName] = useState(""); 
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [expandedIndex, setExpandedIndex] = useState(null);

  useEffect(() => {
    // 1. Grab the email from memory
    const userEmail = localStorage.getItem("currentUser") || "user@test.com";
    
    let currentUserName = userEmail.split('@')[0].replace(/[.0-9]/g, '');
    currentUserName = currentUserName.charAt(0).toUpperCase() + currentUserName.slice(1);
    setUserName(currentUserName);

    // 2. We must use the EXACT SAME math formula as the Dashboard!
    let numericId = 0;
    for (let i = 0; i < userEmail.length; i++) {
      numericId = (numericId * 31) + userEmail.charCodeAt(i);
      numericId = Math.abs(numericId % 100000);
    }

    const fetchHistory = async () => {
      setLoading(true);
      setError(null);
      try {
        // 3. Aggressive cache-busting so the browser never shows an old empty page
        const response = await fetch(`http://localhost:8000/api/history/${numericId}`, {
          method: 'GET',
          headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0'
          },
          cache: 'no-store' 
        });
        
        if (response.status === 404 || response.status === 422) {
          setHistory([]);
          return;
        }

        if (!response.ok) throw new Error("Failed to fetch history");
        
        const data = await response.json();
        setHistory(data.history || []);

      } catch (err) {
        console.log("No history found:", err);
        setHistory([]);
      } finally {
        setLoading(false);
      }
    };

    fetchHistory();
  }, []); // Empty brackets here prevent reloading loops

  const toggleRow = (index) => {
    setExpandedIndex(expandedIndex === index ? null : index);
  };

  // --- CLINICAL FEATURE: EXPORT TO CSV ---
  const exportToCSV = () => {
    let csvContent = "Patient Name,Date,Time,Log Type,Predicted Spike (mg/dL),Clinical Notes\n";

    history.forEach(log => {
      const date = new Date(log.timestamp).toLocaleDateString();
      const time = new Date(log.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
      const type = log.actor;

      const match = log.content.match(/(\d+\.?\d*)\s*mg\/dL/i) || log.content.match(/spike of (\d+\.?\d*)/i);
      const spike = match ? match[1] : "N/A";

      const safeContent = `"${log.content.replace(/"/g, '""')}"`;
      
      csvContent += `${userName},${date},${time},${type},${spike},${safeContent}\n`;
    });

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement("a");
    const url = URL.createObjectURL(blob);
    link.setAttribute("href", url);
    link.setAttribute("download", `${userName}_Clinical_Nutrition_Report.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  
  const processChartData = () => {
    if (!history || history.length === 0) return [];

    const chartData = history
      .filter(log => log.actor === 'AI') 
      .map(log => {
        if (!log || !log.content) return { spike: null }; 

        const match = log.content.match(/(\d+\.?\d*)\s*mg\/dL/i) || log.content.match(/spike of (\d+\.?\d*)/i);
        const spikeValue = match ? parseFloat(match[1]) : null;

        return {
          date: new Date(log.timestamp).toLocaleDateString([], { month: 'short', day: 'numeric' }),
          spike: spikeValue,
          timestamp: new Date(log.timestamp).getTime() 
        };
      })
      .filter(data => data.spike !== null) 
      .sort((a, b) => a.timestamp - b.timestamp) 
      .slice(-7); 

    return chartData;
  };

  const trendData = processChartData();

  if (loading) return <div className="p-8 text-center text-gray-500">Loading patient data...</div>;
  if (error) return <div className="p-8 text-red-500 text-center font-bold">Connection Error: {error}</div>;

  return (
    <div className="max-w-4xl mx-auto mt-8 p-6 bg-white rounded-2xl shadow-lg border border-gray-100">
      
      {/* HEADER WITH EXPORT BUTTON */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px', borderBottom: '1px solid #E5E7EB', paddingBottom: '16px' }}>
        <div>
          <h3 style={{ fontSize: '24px', fontWeight: 'bold', color: '#111827', margin: 0 }}>{userName}'s Log History</h3>
          <p style={{ color: '#6B7280', margin: '4px 0 0 0' }}>Review your AI predictions and nutritional habits over time.</p>
        </div>
        
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '8px' }}>
          <span style={{ backgroundColor: '#EEF2FF', color: '#4F46E5', padding: '6px 16px', borderRadius: '9999px', fontWeight: 'bold', fontSize: '14px' }}>
            Total Logs: {history.length}
          </span>
          
          {history.length > 0 && (
            <button 
              onClick={exportToCSV}
              style={{ backgroundColor: 'white', color: '#374151', border: '1px solid #D1D5DB', padding: '6px 12px', borderRadius: '6px', fontSize: '13px', fontWeight: 'bold', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px', boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)' }}
            >
              <svg style={{ width: '16px', height: '16px', color: '#6B7280' }} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              Export Report (CSV)
            </button>
          )}
        </div>
      </div>

      {/* GRAPH SECTION */}
      {trendData.length > 0 && (
        <div className="mb-8 border border-gray-200 rounded-xl overflow-hidden shadow-sm">
          <div style={{ backgroundColor: '#F9FAFB', padding: '12px 20px', borderBottom: '1px solid #E5E7EB' }}>
            <h4 style={{ fontWeight: 'bold', color: '#374151', margin: 0 }}>7-Meal Glucose Spike Trend</h4>
          </div>
          <div style={{ height: '300px', width: '100%', padding: '16px', backgroundColor: 'white' }}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={trendData} margin={{ top: 10, right: 20, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E7EB" />
                <XAxis dataKey="date" axisLine={false} tickLine={false} tick={{fill: '#6B7280', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#6B7280', fontSize: 12}} domain={['dataMin - 10', 'dataMax + 10']} />
                <Tooltip contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' }} />
                <ReferenceLine y={30} stroke="#EF4444" strokeDasharray="3 3" label={{ position: 'top', value: 'High Spike Zone (>30)', fill: '#EF4444', fontSize: 11, fontWeight: 'bold' }} />
                <Line type="monotone" dataKey="spike" stroke="#10B981" strokeWidth={3} dot={{ r: 4, strokeWidth: 2, fill: '#fff' }} activeDot={{ r: 6, strokeWidth: 0, fill: '#10B981' }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      )}
      
      {/* TIMELINE SECTION */}
      <h4 style={{ fontSize: '18px', fontWeight: 'bold', color: '#374151', marginBottom: '16px' }}>Detailed Timeline</h4>
      
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {history.length === 0 ? (
           <p className="text-gray-500 text-center py-8">No meal logs found for {userName}. Start logging on the Dashboard!</p>
        ) : (
          history.map((log, index) => {
            const isExpanded = expandedIndex === index;
            const isAI = log.actor === 'AI';

            return (
              <div key={index} style={{ border: '1px solid #E5E7EB', borderRadius: '12px', overflow: 'hidden', backgroundColor: 'white', boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)' }}>
                <div 
                  onClick={() => toggleRow(index)}
                  style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px', cursor: 'pointer', backgroundColor: isExpanded ? '#F9FAFB' : 'white' }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                    <span style={{ 
                      backgroundColor: isAI ? '#2563EB' : '#10B981', 
                      color: 'white', 
                      padding: '4px 12px', 
                      borderRadius: '6px', 
                      fontSize: '12px', 
                      fontWeight: 'bold',
                      textTransform: 'uppercase',
                      letterSpacing: '0.05em'
                    }}>
                      {isAI ? 'NutriAI' : userName}
                    </span>
                    
                    <span style={{ color: '#4B5563', fontWeight: '500', fontSize: '14px' }}>
                      {new Date(log.timestamp).toLocaleDateString()} 
                      <span style={{ color: '#D1D5DB', margin: '0 8px' }}>|</span> 
                      {new Date(log.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                    </span>
                  </div>
                  
                  <div style={{ width: '24px', height: '24px', flexShrink: 0 }}>
                    <svg style={{ width: '100%', height: '100%', transform: isExpanded ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s', color: '#9CA3AF' }} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M19 9l-7 7-7-7" />
                    </svg>
                  </div>
                </div>

                {isExpanded && (
                  <div style={{ padding: '20px', borderTop: '1px solid #F3F4F6', backgroundColor: '#F9FAFB' }}>
                    <p style={{ color: '#374151', margin: 0, whiteSpace: 'pre-wrap', lineHeight: '1.6' }}>
                      {log.content}
                    </p>
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}