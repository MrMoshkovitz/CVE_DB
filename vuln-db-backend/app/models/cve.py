from pydantic import BaseModel, Field
from typing import List, Optional

class CVEModel(BaseModel):
    id: Optional[str] = Field(alias="_id")
    cve_id: str
    vulnerable_package_name: str
    vulnerable_package_version_example: str
    vulnerable_specific_package_name_single_word: str
    assumed_programming_language_from_package: str
    vuln_functions_import_commands_examples: str
    functions_to_be_called_for_exploitability_list: List[str]
    additional_steps_for_attackers: str
    access_prerequisite_for_attackers: str
    is_access_prerequisite_for_attackers_typical: bool
    exploit_applicable_at_sdlc_stage: str
    attackers_achievement_concise_title: str
    potential_exploit_scenarios: List[str]
    potential_data_exfiltration_methods: str
    exploit_mitigation_strategies: List[str]
    exploit_execution_context: str
    exploit_entry_point: str
    what_exploit_allows_adversaries: str
    vulnerability_affected_by: str
    exploit_requires_special_input_to_function_or_any_input: str
    description_to_show_when_exploit_applicable: str
    description_to_show_when_exploit_not_applicable: str
    example_attackers_code_detailed_implementation_steps: str
    attackers_code_as_example: str

    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "cve_id": "CVE-2024-123456",
                "vulnerable_package_name": "example-package",
                "vulnerable_package_version_example": "<1.0.0",
                "vulnerable_specific_package_name_single_word": "example",
                "assumed_programming_language_from_package": "Python",
                "vuln_functions_import_commands_examples": "import example",
                "functions_to_be_called_for_exploitability_list": ["example.function()"],
                "additional_steps_for_attackers": "Crafting malicious payloads.",
                "access_prerequisite_for_attackers": "Ability to send HTTP requests.",
                "is_access_prerequisite_for_attackers_typical": True,
                "exploit_applicable_at_sdlc_stage": "Production",
                "attackers_achievement_concise_title": "Denial of Service",
                "potential_exploit_scenarios": [
                    "Overloading the server with requests.",
                    "Disrupting service for legitimate users."
                ],
                "potential_data_exfiltration_methods": "Not applicable.",
                "exploit_mitigation_strategies": [
                    "Update to the latest version.",
                    "Implement rate limiting.",
                    "Monitor traffic for anomalies."
                ],
                "exploit_execution_context": "Server-side",
                "exploit_entry_point": "HTTP request handling",
                "what_exploit_allows_adversaries": "Denial of service.",
                "vulnerability_affected_by": "Improper input handling.",
                "exploit_requires_special_input_to_function_or_any_input": "Specially crafted input.",
                "description_to_show_when_exploit_applicable": "This vulnerability allows attackers to cause a denial of service.",
                "description_to_show_when_exploit_not_applicable": "Not applicable if patched.",
                "example_attackers_code_detailed_implementation_steps": "1. Identify vulnerable server.\n2. Craft payload.\n3. Send multiple requests.",
                "attackers_code_as_example": "import requests\npayload = {'data': 'malicious'}\nrequests.post('http://target-server.com', data=payload)"
            }
        }
