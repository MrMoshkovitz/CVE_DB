from motor.motor_asyncio import AsyncIOMotorClient
from bson.objectid import ObjectId
from decouple import config
VM_PUBLIC_IP = config("VM_PUBLIC_IP", default="localhost")
MONGO_DB_NAME = config("MONGO_DB_NAME", default="vuln_db")
CVE_COLLECTION_NAME = config("CVE_COLLECTION_NAME", default="cves")
# Replace with the public IP of your VM and MongoDB port
MONGO_DETAILS = config("MONGO_DETAILS", default=f"mongodb://127.0.0.1:27017/vuln_db")

client = AsyncIOMotorClient(MONGO_DETAILS)

# Database and collection configuration
database = client[MONGO_DB_NAME]
cve_collection = database.get_collection(CVE_COLLECTION_NAME)

def cve_helper(cve) -> dict:
    print("Processing CVE:", cve)  # Debugging line
    try:
        return {
            "_id": str(cve["_id"]),
            "cve_id": cve["cve_id"],
            "vulnerable_package_name": cve["vulnerable_package_name"],
            "vulnerable_package_version_example": cve["vulnerable_package_version_example"],
            "vulnerable_specific_package_name_single_word": cve["vulnerable_specific_package_name_single_word"],
            "assumed_programming_language_from_package": cve["assumed_programming_language_from_package"],
            "vuln_functions_import_commands_examples": cve["vuln_functions_import_commands_examples"],
            "functions_to_be_called_for_exploitability_list": cve["functions_to_be_called_for_exploitability_list"],
            "additional_steps_for_attackers": cve["additional_steps_for_attackers"],
            "access_prerequisite_for_attackers": cve["access_prerequisite_for_attackers"],
            "is_access_prerequisite_for_attackers_typical": cve["is_access_prerequisite_for_attackers_typical"],
            "exploit_applicable_at_sdlc_stage": cve["exploit_applicable_at_sdlc_stage"],
            "attackers_achievement_concise_title": cve["attackers_achievement_concise_title"],
            "potential_exploit_scenarios": cve["potential_exploit_scenarios"],
            "potential_data_exfiltration_methods": cve["potential_data_exfiltration_methods"],
            "exploit_mitigation_strategies": cve["exploit_mitigation_strategies"],
            "exploit_execution_context": cve["exploit_execution_context"],
            "exploit_entry_point": cve["exploit_entry_point"],
            "what_exploit_allows_adversaries": cve["what_exploit_allows_adversaries"],
            "vulnerability_affected_by": cve["vulnerability_affected_by"],
            "exploit_requires_special_input_to_function_or_any_input": cve["exploit_requires_special_input_to_function_or_any_input"],
            "description_to_show_when_exploit_applicable": cve["description_to_show_when_exploit_applicable"],
            "description_to_show_when_exploit_not_applicable": cve["description_to_show_when_exploit_not_applicable"],
            "example_attackers_code_detailed_implementation_steps": cve["example_attackers_code_detailed_implementation_steps"],
            "attackers_code_as_example": cve["attackers_code_as_example"]
            }
    except Exception as e:
        print(f"Error in cve_helper: {e}")
        raise e
