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
      <ul>
        {cves.map((cve) => (
          <li key={cve._id} className="mb-2">
            <Link to={`/cves/${cve.cve_id}`} className="text-blue-500 underline">
              {cve.cve_id} - {cve.vulnerable_package_name} ({cve.vulnerable_package_version_example})
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default CVEList;
