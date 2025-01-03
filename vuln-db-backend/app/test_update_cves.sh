#!/bin/bash

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
