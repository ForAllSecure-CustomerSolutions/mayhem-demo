import React, { useState } from 'react';
import axios from 'axios';
import './styles/App.css';
import MapView from './components/MapView';

function App() {
  const [latitude, setLatitude] = useState('');
  const [longitude, setLongitude] = useState('');
  const [pois, setPois] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loginError, setLoginError] = useState('');

  const fetchPOIs = async () => {
    setLoading(true);
    try {
      const response = await axios.get(`http://localhost:8000/pois?latitude=${latitude}&longitude=${longitude}`);
      setPois(response.data.pois);
    } catch (error) {
      console.error("Error fetching POIs:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = async () => {
    try {
      await axios.get('http://localhost:8000/info', {
        auth: {
          username: username,
          password: password
        }
      });
      setIsAuthenticated(true);
      setLoginError('');
    } catch (error) {
      setLoginError('Login failed: Invalid username or password');
      console.error("Login error:", error);
    }
  };

  const handleLogout = async () => {
    username = "";
    password = "";
    setIsAuthenticated(false);
  };

  return (
    <div className="App">
      <header className="header">
        <h1>Car GPS Telemetry</h1>
        {isAuthenticated ? (
          <button className="btn-logout" onClick={handleLogout}>Logout</button>
        ) : (
          <div className="login-form">
            <input
              type="text"
              placeholder="me@me.com"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
            <input
              type="password"
              placeholder="123456"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <button onClick={handleLogin}>Login</button>

          </div>
        )}
      </header>
      {isAuthenticated ? (
        <div className="content">
          <MapView />
        </div>
      ) : (
        <div>
          {loginError && <p className="error">{loginError}</p>}
          <p className="login-prompt">Please log in to see GPS telemetry.</p>
        </div>
      )}
    </div>
  );
}

export default App;
