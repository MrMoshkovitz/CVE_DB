import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';
import CVEDetailPage from './pages/CVEDetailPage';
import Header from './components/Header';
import Footer from './components/Footer';

const App = () => {
  return (
    <Router>
      <Header />
      <div className="container mx-auto px-4 py-6">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/cves/:id" element={<CVEDetailPage />} />
        </Routes>
      </div>
      <Footer />
    </Router>
  );
};

export default App;
