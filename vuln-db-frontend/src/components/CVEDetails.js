import React, { useEffect, useState } from 'react';
import { fetchCVEById } from '../api';
import { useParams } from 'react-router-dom';

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
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-2">{cve.vulnerable_package_name}</h1>
      <div className="bg-red-50 border-l-4 border-red-500 p-4 mb-6">
        <p className="text-red-700">{cve.description_to_show_when_exploit_applicable}</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="space-y-6">
          <section>
            <h2 className="text-xl font-semibold mb-3">Basic Information</h2>
            <div className="bg-white p-4 rounded-lg shadow">
              <p><span className="font-semibold">CVE ID:</span> {cve.cve_id}</p>
              <p><span className="font-semibold">Package:</span> {cve.vulnerable_package_name}</p>
              <p><span className="font-semibold">Affected Version:</span> {cve.vulnerable_package_version_example}</p>
              <p><span className="font-semibold">Language:</span> {cve.assumed_programming_language_from_package}</p>
            </div>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-3">Attack Details</h2>
            <div className="bg-white p-4 rounded-lg shadow">
              <p><span className="font-semibold">Attack Vector:</span> {cve.access_prerequisite_for_attackers}</p>
              <p><span className="font-semibold">Entry Point:</span> {cve.exploit_entry_point}</p>
              <p><span className="font-semibold">Execution Context:</span> {cve.exploit_execution_context}</p>
              <p><span className="font-semibold">SDLC Stage:</span> {cve.exploit_applicable_at_sdlc_stage}</p>
            </div>
          </section>
        </div>

        <div className="space-y-6">
          <section>
            <h2 className="text-xl font-semibold mb-3">Impact & Scenarios</h2>
            <div className="bg-white p-4 rounded-lg shadow">
              <p><span className="font-semibold">Impact:</span> {cve.attackers_achievement_concise_title}</p>
              <div className="mt-2">
                <p className="font-semibold">Potential Scenarios:</p>
                <ul className="list-disc pl-5">
                  {cve.potential_exploit_scenarios.map((scenario, index) => (
                    <li key={index}>{scenario}</li>
                  ))}
                </ul>
              </div>
            </div>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-3">Mitigation</h2>
            <div className="bg-white p-4 rounded-lg shadow">
              <ul className="list-disc pl-5">
                {cve.exploit_mitigation_strategies.map((strategy, index) => (
                  <li key={index}>{strategy}</li>
                ))}
              </ul>
            </div>
          </section>
        </div>
      </div>

      <section className="mt-6">
        <h2 className="text-xl font-semibold mb-3">Technical Details</h2>
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="mb-4">
            <p className="font-semibold">Vulnerable Function Import:</p>
            <code className="bg-gray-100 p-2 rounded block mt-1">
              {cve.vuln_functions_import_commands_examples}
            </code>
          </div>
          <div className="mb-4">
            <p className="font-semibold">Vulnerable Functions:</p>
            <ul className="list-disc pl-5">
              {cve.functions_to_be_called_for_exploitability_list.map((func, index) => (
                <li key={index}>
                  <code className="bg-gray-100 px-2 py-1 rounded">{func}</code>
                </li>
              ))}
            </ul>
          </div>
          {cve.attackers_code_as_example && (
            <div>
              <p className="font-semibold">Example Exploit Code:</p>
              <pre className="bg-gray-100 p-2 rounded mt-1 overflow-x-auto">
                <code>{cve.attackers_code_as_example}</code>
              </pre>
            </div>
          )}
        </div>
      </section>
    </div>
  );
};

export default CVEDetails;
