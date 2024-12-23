// src/components/Footer.js
import React from 'react';

const Footer = () => {
  return (
    <footer className="bg-gray-800 text-white text-center py-4">
      <p>© {new Date().getFullYear()} VulnDB. All rights reserved.</p>
      <div className="mt-2">
        <a href="/privacy" className="hover:text-gray-300 mx-2">
          Privacy Policy
        </a>
        <a href="/terms" className="hover:text-gray-300 mx-2">
          Terms of Service
        </a>
        <a href="/contact" className="hover:text-gray-300 mx-2">
          Contact
        </a>
      </div>
    </footer>
  );
};

export default Footer;
