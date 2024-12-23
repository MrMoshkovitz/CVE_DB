// src/components/Header.js
import React from 'react';
import { Link } from 'react-router-dom';

const Header = () => {
  return (
    <header className="bg-gray-800 text-white">
      <div className="container mx-auto flex items-center justify-between p-4">
        <Link to="/" className="text-xl font-bold">
          VulnDB
        </Link>
        <div className="flex items-center space-x-4">
          <input
            type="text"
            placeholder="Search CVEs..."
            className="rounded px-2 py-1"
          />
          <button className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-1 rounded">
            Search
          </button>
        </div>
        <nav className="space-x-4">
          <Link to="/" className="hover:text-gray-300">
            Home
          </Link>
          <Link to="/about" className="hover:text-gray-300">
            About
          </Link>
          <Link to="/contact" className="hover:text-gray-300">
            Contact
          </Link>
        </nav>
      </div>
    </header>
  );
};

export default Header;
