// src/components/CVEList.js
import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { fetchAllCVEs } from '../api';

const CVEList = () => {
  const [cves, setCVEs] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getData = async () => {
      try {
        const data = await fetchAllCVEs();
        setCVEs(data);
      } catch (err) {
        setError(err.message);
      }
    };
    getData();
  }, []);

  if (error) return <p className="text-red-500">Error: {error}</p>;
  if (!cves.length) return <p>Loading...</p>;

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">CVE List</h1>
      <table className="table-auto w-full border-collapse border border-gray-200">
        <thead className="bg-gray-100">
          <tr>
            <th className="border border-gray-300 px-4 py-2 text-left">CVE ID</th>
            <th className="border border-gray-300 px-4 py-2 text-left">Package</th>
            <th className="border border-gray-300 px-4 py-2 text-left">Version</th>
          </tr>
        </thead>
        <tbody>
          {cves.map((cve, index) => (
            <tr
              key={cve._id}
              className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}
            >
              <td className="border border-gray-300 px-4 py-2">
                <Link
                  to={`/cves/${cve.cve_id}`}
                  className="text-blue-500 hover:underline"
                >
                  {cve.cve_id}
                </Link>
              </td>
              <td className="border border-gray-300 px-4 py-2">
                {cve.vulnerable_package_name}
              </td>
              <td className="border border-gray-300 px-4 py-2">
                {cve.vulnerable_package_version_example}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default CVEList;
