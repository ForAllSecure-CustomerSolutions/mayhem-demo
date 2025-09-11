import React, { useState } from 'react';
import axios from 'axios';
import './styles/App.css';
import MapView from './components/MapView';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [username, setUsername] = useState('me@me.com');
  const [password, setPassword] = useState('123456');
  const [loginError, setLoginError] = useState('');



  const handleLogin = async () => {
    try {
      // Proxy will redirect to API server.
      await axios.get('/info', {
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
    // Keep the credentials populated for easy re-login
    setUsername("me@me.com");
    setPassword("123456");
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
        {loginError && <span className="error">{loginError}</span>}
      </header>
      <div className="content">
        <MapView 
          isAuthenticated={isAuthenticated}
          username={username}
          password={password}
        />
      </div>
    </div>
  );
}

export default App;
