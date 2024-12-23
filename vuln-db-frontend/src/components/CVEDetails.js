import React, { useEffect, useState } from 'react';
import { fetchCVEById } from '../api';
import { useParams, Link } from 'react-router-dom';

const CVEDetails = () => {
  const { id } = useParams();
  const [cve, setCVE] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getData = async () => {
      try {
        const data = await fetchCVEById(id);
        setCVE(data);
      } catch (err) {
        setError(err.message);
      }
    };
    getData();
  }, [id]);

  if (error) return <p className="text-red-500">Error: {error}</p>;
  if (!cve) return <p>Loading...</p>;

  return (
    <div className="max-w-6xl mx-auto p-6">
      {/* Breadcrumb Navigation */}
      <nav className="text-sm text-gray-500 mb-4">
        <Link to="/" className="hover:underline text-blue-500">
          Home
        </Link>{' '}
        /{' '}
        <Link to="/" className="hover:underline text-blue-500">
          CVE List
        </Link>{' '}
        / {cve.cve_id}
      </nav>

      {/* Title and Summary */}
      <h1 className="text-3xl font-bold mb-2">{cve.cve_id}</h1>
      <p className="text-gray-600 mb-6">
        {cve.description_to_show_when_exploit_applicable}
      </p>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Basic Information */}
        <section className="space-y-4">
          <h2 className="text-xl font-semibold">Basic Information</h2>
          <div className="bg-white p-4 rounded-lg shadow">
            <p>
              <span className="font-semibold">Package:</span>{' '}
              {cve.vulnerable_package_name}
            </p>
            <p>
              <span className="font-semibold">Version:</span>{' '}
              {cve.vulnerable_package_version_example}
            </p>
            <p>
              <span className="font-semibold">Language:</span>{' '}
              {cve.assumed_programming_language_from_package}
            </p>
          </div>
        </section>

        {/* Exploit Details */}
        <section className="space-y-4">
          <h2 className="text-xl font-semibold">Exploit Details</h2>
          <div className="bg-white p-4 rounded-lg shadow">
            <p>
              <span className="font-semibold">Attack Vector:</span>{' '}
              {cve.access_prerequisite_for_attackers}
            </p>
            <p>
              <span className="font-semibold">Entry Point:</span>{' '}
              {cve.exploit_entry_point}
            </p>
            <p>
              <span className="font-semibold">Execution Context:</span>{' '}
              {cve.exploit_execution_context}
            </p>
          </div>
        </section>
      </div>

      {/* Impact & Scenarios */}
      <div className="mt-6 space-y-4">
        <h2 className="text-xl font-semibold">Impact & Scenarios</h2>
        <div className="bg-white p-4 rounded-lg shadow">
          <p>
            <span className="font-semibold">Impact:</span>{' '}
            {cve.attackers_achievement_concise_title}
          </p>
          <ul className="list-disc pl-5 mt-2">
            {cve.potential_exploit_scenarios.map((scenario, index) => (
              <li key={index}>{scenario}</li>
            ))}
          </ul>
        </div>
      </div>

      {/* Mitigation Strategies */}
      <div className="mt-6 space-y-4">
        <h2 className="text-xl font-semibold">Mitigation Strategies</h2>
        <div className="bg-white p-4 rounded-lg shadow">
          <ul className="list-disc pl-5">
            {cve.exploit_mitigation_strategies.map((strategy, index) => (
              <li key={index}>{strategy}</li>
            ))}
          </ul>
        </div>
      </div>

      {/* Technical Details */}
      <div className="mt-6 space-y-4">
        <h2 className="text-xl font-semibold">Technical Details</h2>
        <div className="bg-white p-4 rounded-lg shadow">
          <p className="font-semibold">Vulnerable Function Import:</p>
          <code className="block bg-gray-100 p-2 rounded mb-4">
            {cve.vuln_functions_import_commands_examples}
          </code>

          <p className="font-semibold">Vulnerable Functions:</p>
          <ul className="list-disc pl-5 mt-2">
            {cve.functions_to_be_called_for_exploitability_list.map(
              (func, index) => (
                <li key={index}>
                  <code className="bg-gray-100 px-2 py-1 rounded">{func}</code>
                </li>
              )
            )}
          </ul>

          {cve.attackers_code_as_example && (
            <div className="mt-4">
              <p className="font-semibold">Example Exploit Code:</p>
              <pre className="bg-gray-100 p-2 rounded overflow-x-auto">
                <code>{cve.attackers_code_as_example}</code>
              </pre>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default CVEDetails;
