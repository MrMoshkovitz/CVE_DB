import axios from 'axios';

const API_URL = 'http://localhost:8000/cves'; // Update this if your backend is on a different port/IP
const TIMEOUT = 5000; // 5 seconds timeout

const api = axios.create({
  baseURL: API_URL,
  timeout: TIMEOUT,
  headers: {
    'Content-Type': 'application/json'
  }
});

export const fetchAllCVEs = async () => {
  const response = await api.get('/');
  return response.data;
};

export const fetchCVEById = async (cve_id) => {
  const response = await api.get(`/?cve=${cve_id}`);
  return response.data;
};







