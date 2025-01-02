from motor.motor_asyncio import AsyncIOMotorClient
from bson.objectid import ObjectId
from app.config import settings
import logging
from fastapi import HTTPException, status

# Configure logging
logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

VM_PUBLIC_IP = settings.VM_PUBLIC_IP
MONGO_DB_NAME = settings.MONGO_DB_NAME
CVE_COLLECTION_NAME = settings.CVE_COLLECTION_NAME
# Replace with the public IP of your VM and MongoDB port
MONGO_DETAILS = settings.MONGO_DETAILS

# Database connection with error handling
try:
    client = AsyncIOMotorClient(MONGO_DETAILS)
    database = client[MONGO_DB_NAME]
    cve_collection = database.get_collection(CVE_COLLECTION_NAME)
    logger.info("Successfully connected to MongoDB")
except Exception as e:
    logger.error(f"Failed to connect to MongoDB: {e}")
    raise

# Helper function to format CVE data
def cve_helper(cve) -> dict:
    try:
        return {
            "id": str(cve["_id"]),
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
    except KeyError as e:
        logger.error(f"Missing required field in CVE document: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Invalid CVE document structure: missing field {str(e)}"
        )
    except Exception as e:
        logger.error(f"Error processing CVE document: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing CVE document: {str(e)}"
        )

# Database initialization function
async def init_db():
    try:
        # Test the connection
        await client.server_info()
        logger.info("Database connection verified")
        
        # Create indexes
        await cve_collection.create_index("cve_id", unique=True)
        await cve_collection.create_index("vulnerable_package_name")
        await cve_collection.create_index("assumed_programming_language_from_package")
        logger.info("Database indexes created successfully")
        
    except Exception as e:
        logger.error(f"Database initialization failed: {e}")
        raise