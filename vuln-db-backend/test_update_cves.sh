#!/bin/bash

export GOOGLE_APPLICATION_CREDENTIALS=~/cve-db-sa.json

#*                  Bash Functions
#? ================================================
HARD_LINE_BREAK=$(echo $(yes "=" | head -n100 | tr -d "\n"))
SOFT_LINE_BREAK=$(echo $(yes "-" | head -n100 | tr -d "\n"))
BLUE="\e[1;34m"
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
NORMAL="\e[0m"

DEBUG="$BLUE DEBUG: $NORMAL"
SUCCESS="$GREEN SUCCESS: $NORMAL"
WARNING="$YELLOW WARNING: $NORMAL"
ERROR="$RED ERROR: $NORMAL"

PROJECT_DIR="${HOME}/Code/CVE_DB/"
PROJECT_BACKEND_DIR="${PROJECT_DIR}/vuln-db-backend"
PROJECT_UPDATE_SCRIPT="${PROJECT_BACKEND_DIR}/update_cves.sh"
PROJECT_DB_DIR="${PROJECT_DIR}/data/db"
VM_DB_DIR="${HOME}/data/db"
EXAMPLE_FILE_NAME="enriched-cves-example.json"
LATEST_FILE_NAME="enriched-cves-latest.json"
FINAL_FILE_NAME="enriched-cves.json"
BUCKET_NAME="cve-storage-bucket"
FILE_NAME_PREFIX="enriched-cves-"

MONGO_CONTAINER_NAME="mongodb"
MONGO_DB_DIR="~/data/db"
MONGO_DB_NAME="vuln_db"
MONGO_DB_COLLECTION_NAME="cves"





example_data='[
    {
        "cve_id": "CVE-0000-000001",
        "vulnerable_package_name": "body-parser",
        "vulnerable_package_version_example": "<1.20.3",
        "vulnerable_specific_package_name_single_word": "body-parser",
        "assumed_programming_language_from_package": "JavaScript",
        "vuln_functions_import_commands_examples": "const bodyParser = require('body-parser');",
        "functions_to_be_called_for_exploitability_list": [
            "bodyParser.urlencoded({ extended: true })"
        ],
        "additional_steps_for_attackers": "Crafting malicious payloads that exploit the url encoding vulnerability.",
        "access_prerequisite_for_attackers": "Ability to send HTTP requests to the server.",
        "is_access_prerequisite_for_attackers_typical": true,
        "exploit_applicable_at_sdlc_stage": "Production",
        "attackers_achievement_concise_title": "Denial of Service",
        "potential_exploit_scenarios": [
            "Overloading a web server by sending numerous requests with specially crafted payloads to exhaust resources.",
            "Disrupting service for legitimate users by making the application unresponsive."
        ],
        "potential_data_exfiltration_methods": "Not applicable for denial of service.",
        "exploit_mitigation_strategies": [
            "Updating to body-parser version 1.20.3 or later.",
            "Implementing rate limiting to prevent abuse from excessive requests.",
            "Monitoring and logging to detect unusual spikes in traffic."
        ],
        "exploit_execution_context": "Server-side",
        "exploit_entry_point": "HTTP request handling",
        "what_exploit_allows_adversaries": "To render the web service unavailable by overwhelming it with requests.",
        "vulnerability_affected_by": "Improper handling of URL encoded input.",
        "exploit_requires_special_input_to_function_or_any_input": "crafted input",
        "description_to_show_when_exploit_applicable": "This vulnerability allows attackers to cause a denial of service by sending specially crafted payloads that exploit weaknesses in URL encoding handling.",
        "description_to_show_when_exploit_not_applicable": "If the server is not using a vulnerable version of body-parser or has mitigations like rate limiting, the exploit may not be applicable.",
        "example_attackers_code_detailed_implementation_steps": "1. Identify a target server using a vulnerable version of body-parser.\n2. Craft a payload that exploits the URL encoding vulnerability.\n3. Use a tool like curl or a script to send multiple requests with the crafted payload to the server.\n4. Monitor the server response to determine if the service becomes unavailable or degraded.",
        "attackers_code_as_example": "const axios = require('axios');\nconst payload = 'a='.repeat(1000) + '%';\naxios.post('http://target-server.com', payload);\n"
    },
    {
        "cve_id": "CVE-0000-000002",
        "vulnerable_package_name": "express",
        "vulnerable_package_version_example": "<4.19.2",
        "vulnerable_specific_package_name_single_word": "express",
        "assumed_programming_language_from_package": "JavaScript",
        "vuln_functions_import_commands_examples": "const express = require('express');",
        "functions_to_be_called_for_exploitability_list": [
            "app.use(express.json())"
        ],
        "additional_steps_for_attackers": "Crafting malicious payloads that exploit the url encoding vulnerability.",
        "access_prerequisite_for_attackers": "Ability to send HTTP requests to the server.",
        "is_access_prerequisite_for_attackers_typical": true,
        "exploit_applicable_at_sdlc_stage": "Production",
        "attackers_achievement_concise_title": "Denial of Service",
        "potential_exploit_scenarios": [
            "Overloading a web server by sending numerous requests with specially crafted payloads to exhaust resources.",
            "Disrupting service for legitimate users by making the application unresponsive."
        ],
        "potential_data_exfiltration_methods": "Not applicable for denial of service.",
        "exploit_mitigation_strategies": [
            "Updating to express version 4.19.2 or later.",
            "Implementing rate limiting to prevent abuse from excessive requests.",
            "Monitoring and logging to detect unusual spikes in traffic."
        ],
        "exploit_execution_context": "Server-side",
        "exploit_entry_point": "HTTP request handling",
        "what_exploit_allows_adversaries": "To render the web service unavailable by overwhelming it with requests.",
        "vulnerability_affected_by": "Improper handling of URL encoded input.",
        "exploit_requires_special_input_to_function_or_any_input": "crafted input",
        "description_to_show_when_exploit_applicable": "This vulnerability allows attackers to cause a denial of service by sending specially crafted payloads that exploit weaknesses in URL encoding handling.",
        "description_to_show_when_exploit_not_applicable": "If the server is not using a vulnerable version of express or has mitigations like rate limiting, the exploit may not be applicable.",
        "example_attackers_code_detailed_implementation_steps": "1. Identify a target server using a vulnerable version of express.\n2. Craft a payload that exploits the URL encoding vulnerability.\n3. Use a tool like curl or a script to send multiple requests with the crafted payload to the server.\n4. Monitor the server response to determine if the service becomes unavailable or degraded.",
        "attackers_code_as_example": "const axios = require('axios');\nconst payload = 'a='.repeat(1000) + '%';\naxios.post('http://target-server.com', payload);\n"
    },
]'
latest_example_data='[
    {
        "cve_id": "CVE-1111-111111",
        "vulnerable_package_name": "body-parser",
        "vulnerable_package_version_example": "<1.20.3",
        "vulnerable_specific_package_name_single_word": "body-parser",
        "assumed_programming_language_from_package": "JavaScript",
        "vuln_functions_import_commands_examples": "const bodyParser = require('body-parser');",
        "functions_to_be_called_for_exploitability_list": [
            "bodyParser.urlencoded({ extended: true })"
        ],
        "additional_steps_for_attackers": "Crafting malicious payloads that exploit the url encoding vulnerability.",
        "access_prerequisite_for_attackers": "Ability to send HTTP requests to the server.",
        "is_access_prerequisite_for_attackers_typical": true,
        "exploit_applicable_at_sdlc_stage": "Production",
        "attackers_achievement_concise_title": "Denial of Service",
        "potential_exploit_scenarios": [
            "Overloading a web server by sending numerous requests with specially crafted payloads to exhaust resources.",
            "Disrupting service for legitimate users by making the application unresponsive."
        ],
        "potential_data_exfiltration_methods": "Not applicable for denial of service.",
        "exploit_mitigation_strategies": [
            "Updating to body-parser version 1.20.3 or later.",
            "Implementing rate limiting to prevent abuse from excessive requests.",
            "Monitoring and logging to detect unusual spikes in traffic."
        ],
        "exploit_execution_context": "Server-side",
        "exploit_entry_point": "HTTP request handling",
        "what_exploit_allows_adversaries": "To render the web service unavailable by overwhelming it with requests.",
        "vulnerability_affected_by": "Improper handling of URL encoded input.",
        "exploit_requires_special_input_to_function_or_any_input": "crafted input",
        "description_to_show_when_exploit_applicable": "This vulnerability allows attackers to cause a denial of service by sending specially crafted payloads that exploit weaknesses in URL encoding handling.",
        "description_to_show_when_exploit_not_applicable": "If the server is not using a vulnerable version of body-parser or has mitigations like rate limiting, the exploit may not be applicable.",
        "example_attackers_code_detailed_implementation_steps": "1. Identify a target server using a vulnerable version of body-parser.\n2. Craft a payload that exploits the URL encoding vulnerability.\n3. Use a tool like curl or a script to send multiple requests with the crafted payload to the server.\n4. Monitor the server response to determine if the service becomes unavailable or degraded.",
        "attackers_code_as_example": "const axios = require('axios');\nconst payload = 'a='.repeat(1000) + '%';\naxios.post('http://target-server.com', payload);\n"
    },
    {
        "cve_id": "CVE-2222-222222",
        "vulnerable_package_name": "express",
        "vulnerable_package_version_example": "<4.19.2",
        "vulnerable_specific_package_name_single_word": "express",
        "assumed_programming_language_from_package": "JavaScript",
        "vuln_functions_import_commands_examples": "const express = require('express');",
        "functions_to_be_called_for_exploitability_list": [
            "app.use(express.json())"
        ],
        "additional_steps_for_attackers": "Crafting malicious payloads that exploit the url encoding vulnerability.",
        "access_prerequisite_for_attackers": "Ability to send HTTP requests to the server.",
        "is_access_prerequisite_for_attackers_typical": true,
        "exploit_applicable_at_sdlc_stage": "Production",
        "attackers_achievement_concise_title": "Denial of Service",
        "potential_exploit_scenarios": [
            "Overloading a web server by sending numerous requests with specially crafted payloads to exhaust resources.",
            "Disrupting service for legitimate users by making the application unresponsive."
        ],
        "potential_data_exfiltration_methods": "Not applicable for denial of service.",
        "exploit_mitigation_strategies": [
            "Updating to express version 4.19.2 or later.",
            "Implementing rate limiting to prevent abuse from excessive requests.",
            "Monitoring and logging to detect unusual spikes in traffic."
        ],
        "exploit_execution_context": "Server-side",
        "exploit_entry_point": "HTTP request handling",
        "what_exploit_allows_adversaries": "To render the web service unavailable by overwhelming it with requests.",
        "vulnerability_affected_by": "Improper handling of URL encoded input.",
        "exploit_requires_special_input_to_function_or_any_input": "crafted input",
        "description_to_show_when_exploit_applicable": "This vulnerability allows attackers to cause a denial of service by sending specially crafted payloads that exploit weaknesses in URL encoding handling.",
        "description_to_show_when_exploit_not_applicable": "If the server is not using a vulnerable version of express or has mitigations like rate limiting, the exploit may not be applicable.",
        "example_attackers_code_detailed_implementation_steps": "1. Identify a target server using a vulnerable version of express.\n2. Craft a payload that exploits the URL encoding vulnerability.\n3. Use a tool like curl or a script to send multiple requests with the crafted payload to the server.\n4. Monitor the server response to determine if the service becomes unavailable or degraded.",
        "attackers_code_as_example": "const axios = require('axios');\nconst payload = 'a='.repeat(1000) + '%';\naxios.post('http://target-server.com', payload);\n"
    },
]'

#* Setup Tests:
#? ================================================

#* Cleanup Environment
function cleanup_environment() {
    """
    Reset environment to known state before each test.
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Stop and remove MongoDB container
    sudo docker stop mongodb || true
    sudo docker rm mongodb || true

    #* Clean up test files but preserve example file
    rm -f $PROJECT_DB_DIR/enriched-cves-latest.json
    rm -f $PROJECT_DB_DIR/enriched-cves.json
    rm -f $VM_DB_DIR/enriched-cves-latest.json
    rm -f $VM_DB_DIR/enriched-cves.json    
    
    #* Stop docker daemon
    sudo systemctl stop docker || true
    
    #* Ensure example file exists and has correct permissions
    if [ ! -f "$PROJECT_DB_DIR/enriched-cves-example.json" ]; then
        echo '{"test": "example_data"}' > $PROJECT_DB_DIR/enriched-cves-example.json
    fi
    sudo chmod 755 $PROJECT_DB_DIR/enriched-cves-example.json
}

function setup_test_files() {
    """
    Create Test files with Sample Data for testing.
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    echo '{"test": "example_data"}' > $PROJECT_DB_DIR/enriched-cves-example.json
    echo '{"test": "latest_data"}' > $PROJECT_DB_DIR/enriched-cves-latest.json
}


#* Test Cases
#? ================================================
function test_case_1_no__files_exist()
function test_case_1() {
    """
    Test Case 1: No Files exist At All - should use example file.
    Proof of Success:
    - Example file is copied to the project directory.
    - Example file is copied to the VM directory.
    - MongoDB container is started.
    - MongoDB collection is updated with the example data.

    
    Command to check Success:
    # Should return the example data.
    - sudo docker exec -it mongodb mongo vuln-db-backend --eval \"db.enriched_cves.find({}).pretty()\"
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Cleanup Environment First
    cleanup_environment
    
    #* Should use Example file and not Create any new files
    ./update_cves.sh

    #* Check if the example data is in the MongoDB collection
    sudo docker exec -it mongodb mongo vuln-db-backend --eval "db.enriched_cves.find({}).pretty()"
    #* Check if the example file is in the project directory
    ls -l $PROJECT_DB_DIR/enriched-cves-example.json
    #* Check if the example file is in the VM directory
    ls -l $VM_DB_DIR/enriched-cves-example.json
}

function test_case_2() {
    """
    Test Case 2: Latest File Exists Only in the Bucket - should use the latest file.

    Proof of Success:
    - Latest file is copied to the project directory.
    - Latest file is copied to the VM directory.
    - MongoDB container is started.
    - MongoDB collection is updated with the latest file data.

    Command to check Success:
    # Should return the latest data.
    - sudo docker exec -it mongodb mongo vuln-db-backend --eval \"db.enriched_cves.find({}).pretty()\"
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Cleanup Environment First
    cleanup_environment

    #* Should use Latest file and not Create any new files
    ./update_cves.sh

    #* Check if the latest file is in the MongoDB collection
    sudo docker exec -it mongodb mongo vuln-db-backend --eval "db.enriched_cves.find({}).pretty()"
    #* Check if the latest file is in the project directory
    ls -l $PROJECT_DB_DIR/enriched-cves-latest.json
    #* Check if the latest file is in the VM directory
    ls -l $VM_DB_DIR/enriched-cves-latest.json
}

function test_case_3() {
    """
    Test Case 3: Latest File Exists Only in the VM - should use the latest file.

    Proof of Success:
    - Latest file is copied to the project directory.
    - Latest file is copied to the VM directory.
    - MongoDB container is started.
    - MongoDB collection is updated with the latest file data.

    Command to check Success:
    # Should return the latest data.
    - sudo docker exec -it mongodb mongo vuln-db-backend --eval \"db.enriched_cves.find({}).pretty()\"
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Cleanup Environment First
    cleanup_environment

    #* Should use Latest file and not Create any new files
    ./update_cves.sh

    #* Check if the latest file is in the MongoDB collection
    sudo docker exec -it mongodb mongo vuln-db-backend --eval "db.enriched_cves.find({}).pretty()"
    #* Check if the latest file is in the project directory
    ls -l $PROJECT_DB_DIR/enriched-cves-latest.json
    #* Check if the latest file is in the VM directory
    ls -l $VM_DB_DIR/enriched-cves-latest.json
}

function test_case_4() {
    """
    Test Case 4: Docker Deamon not running - should start the docker deamon.
    Proof of Success:
    - Docker deamon is started.
    - MongoDB container is created and started.
    - MongoDB collection is updated with the latest file data.

    Command to check Success:
    # Should return the latest data.
    - sudo docker exec -it mongodb mongo vuln-db-backend --eval \"db.enriched_cves.find({}).pretty()\"
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Cleanup Environment First
    cleanup_environment

    #* Should use Latest file and not Create any new files
    ./update_cves.sh

    #* Check if the latest file is in the MongoDB collection
    sudo docker exec -it mongodb mongo vuln-db-backend --eval "db.enriched_cves.find({}).pretty()"
    #* Check if the latest file is in the project directory
    ls -l $PROJECT_DB_DIR/enriched-cves-latest.json
    #* Check if the latest file is in the VM directory
    ls -l $VM_DB_DIR/enriched-cves-latest.json
}

function test_case_5() {
    """
    Test Case 5: No MongoDB Container Exists - should create and start the container.
    Proof of Success:
    - MongoDB container is created and started.
    - MongoDB collection is updated with the latest file data.

    Command to check Success:
    # Should return the latest data.
    - sudo docker exec -it mongodb mongo vuln-db-backend --eval \"db.enriched_cves.find({}).pretty()\"
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Cleanup Environment First
    cleanup_environment

    #* Should use Latest file and not Create any new files
    ./update_cves.sh

    #* Check if the latest file is in the MongoDB collection
    sudo docker exec -it mongodb mongo vuln-db-backend --eval "db.enriched_cves.find({}).pretty()"
    #* Check if the latest file is in the project directory
    ls -l $PROJECT_DB_DIR/enriched-cves-latest.json
    #* Check if the latest file is in the VM directory
    ls -l $VM_DB_DIR/enriched-cves-latest.json
}

function test_case_6() {
    """
    Test Case 6: MongoDB Container Exists but Stopped - should start the container.
    Proof of Success:
    - MongoDB container is started.
    - MongoDB collection is updated with the latest file data.

    Command to check Success:
    # Should return the latest data.
    - sudo docker exec -it mongodb mongo vuln-db-backend --eval \"db.enriched_cves.find({}).pretty()\"
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Cleanup Environment First
    cleanup_environment

    #* Should use Latest file and not Create any new files
    ./update_cves.sh

    #* Check if the latest file is in the MongoDB collection
    sudo docker exec -it mongodb mongo vuln-db-backend --eval "db.enriched_cves.find({}).pretty()"
    #* Check if the latest file is in the project directory
    ls -l $PROJECT_DB_DIR/enriched-cves-latest.json
    #* Check if the latest file is in the VM directory
    ls -l $VM_DB_DIR/enriched-cves-latest.json
}

function test_case_7() {
    """
    Test Case 7: File Not Found in the Container - should copy the file to the container.
    Proof of Success:
    - File is copied to the container.
    - MongoDB collection is updated with the file data.

    Command to check Success:
    # Should return the file data.
    - sudo docker exec -it mongodb mongo vuln-db-backend --eval \"db.enriched_cves.find({}).pretty()\"
    """
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    #* Cleanup Environment First
    cleanup_environment

    #* Should use Latest file and not Create any new files
    ./update_cves.sh

    #* Check if the latest file is in the MongoDB collection
    sudo docker exec -it mongodb mongo vuln-db-backend --eval "db.enriched_cves.find({}).pretty()"
    #* Check if the latest file is in the project directory
    ls -l $PROJECT_DB_DIR/enriched-cves-latest.json
    #* Check if the latest file is in the VM directory
    ls -l $VM_DB_DIR/enriched-cves-latest.json
}


function run_all_tests() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    echo -e "$HARD_LINE_BREAK" >&2
    test_case_1
    test_case_2
    test_case_3
    test_case_4
    test_case_5
    test_case_6
    test_case_7
    
}

#* Verify Functions
#? ================================================
function verify_mongodb_running() {
    if ! sudo docker ps | grep -q mongodb; then
        echo "Test failed: MongoDB not running"
        exit 1
    fi
}

function verify_data_imported() {
    local expected_data=$1
    local actual_data=$(sudo docker exec mongodb mongosh --quiet --eval "db.cves.findOne()")
    if [[ "$actual_data" != *"$expected_data"* ]]; then
        echo "Test failed: Data mismatch"
        exit 1
    fi
}

function create_test_data() {
    # Create test files with known content
    cd $PROJECT_BACKEND_DIR
    mkdir -p test_data
    echo $latest_example_data > test_data/enriched-cves-latest.json
    echo $example_data > test_data/enriched-cves-example.json
}

#* Logging
#? ================================================
function log_test_case_start() {
    local test_name=$1
    echo -e "$DEBUG Running Test: $test_name" >&2
    echo "=== Running test: $test_name ==="
    echo -e "$HARD_LINE_BREAK" >&2
}

