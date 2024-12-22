import axios from 'axios';

const API_URL = 'http://localhost:8000/cves'; // Backend API URL

export const fetchAllCVEs = async () => {
  const response = await axios.get(API_URL);
  return response.data;
};

export const fetchCVEById = async (cve_id) => {
  const response = await axios.get(`${API_URL}/${cve_id}`);
  return response.data;
};
