import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';
import CVEDetailPage from './pages/CVEDetailPage';

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/cves" element={<HomePage />} />
        <Route path="/cves/:id" element={<CVEDetailPage />} />
        <Route path="/" element={<HomePage />} />
      </Routes>
    </Router>
  );
};

export default App;
