# sudo docker ps -a --filter "name=mongodb" --format "{{.Status}}"
# sudo docker ps --filter "name=mongodb" --filter "status=running"

mock_example_json=


#!/bin/bash

#* Set the Google Cloud credentials
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

PROJECT_DB_DIR="${HOME}/Code/CVE_DB/vuln-db-backend/data/db"
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

#* Check if the file exists in the VM
function find_file_in_vm() {
    local file_name=$1    
    local project_path=$PROJECT_DB_DIR
    local vm_path=$VM_DB_DIR
    
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    echo -e "$DEBUG File Name: $file_name" >&2
    echo -e "$DEBUG Project Path: $project_path" >&2
    echo -e "$DEBUG VM Path: $vm_path" >&2

    #* Check if the file exists in the project directory
    if [ -f "${project_path}/${file_name}" ]; then
        echo -e "$SUCCESS $GREEN Found in Project Data Directory$NORMAL" >&2
        echo -e "$SUCCESS $YELLOW ${project_path}/${file_name}$NORMAL" >&2
        echo "${project_path}/${file_name}"
        return 0
    #* Check if the file exists in the VM data directory
    elif [ -f "${vm_path}/${file_name}" ]; then
        echo -e "$SUCCESS $GREEN Found in VM Data Directory$NORMAL" >&2
        echo -e "$SUCCESS $YELLOW ${vm_path}/${file_name}$NORMAL" >&2
        echo "${vm_path}/${file_name}"
        return 0
    #* If the file is not found in the project or VM data directory
    else
        echo -e "$ERROR $RED File Not Found in Project or VM Data Directory$NORMAL" >&2
        echo -e "$ERROR $RED Project Path: $YELLOW ${project_path}/${file_name}$NORMAL" >&2
        echo -e "$ERROR $RED VM Path: $YELLOW ${vm_path}/${file_name}$NORMAL" >&2
        return 1
    fi
}

function get_latest_file_from_bucket() {
    local file_name_prefix=$1
    local bucket_name=$2
    
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    echo -e "$DEBUG File Name Prefix: $file_name_prefix" >&2
    echo -e "$DEBUG Bucket Name: $bucket_name" >&2
    echo -e "$DEBUG Bucket Path: gs://${bucket_name}/${file_name_prefix}*.json" >&2
    if [ -n "$(gsutil ls gs://${bucket_name}/${file_name_prefix}*.json)" ]; then
        # Count the number of files in the bucket
        local file_count=$(gsutil ls gs://${bucket_name}/${file_name_prefix}*.json | wc -l)
        echo -e "$SUCCESS $GREEN $file_count $file_name_prefix files found in the bucket $NORMAL" >&2
        local latest_bucket_file=$(gsutil ls gs://${bucket_name}/${file_name_prefix}*.json | sort -r | head -n1)
        echo -e "$SUCCESS $YELLOW $latest_bucket_file $NORMAL" >&2

        # Copy the latest file from the bucket to the VM (project directory)
        rm -f $PROJECT_DB_DIR/enriched-cves-latest.json
        gsutil -q cp $latest_bucket_file $PROJECT_DB_DIR/enriched-cves-latest.json
        sudo chmod -R 755 $PROJECT_DB_DIR/enriched-cves-latest.json
        echo -e "$SUCCESS $GREEN Latest file copied from the bucket to the VM $NORMAL" >&2
        echo -e "$SUCCESS Full File Path: $YELLOW $PROJECT_DB_DIR/enriched-cves-latest.json $NORMAL" >&2
        echo -e "$SUCCESS $GREEN Latest file renamed to enriched-cves.json $NORMAL" >&2
        echo -e "$SUCCESS Full File Path: $YELLOW $PROJECT_DB_DIR/enriched-cves.json $NORMAL" >&2
        sudo chmod -R 755 $PROJECT_DB_DIR/enriched-cves.json
        echo "${PROJECT_DB_DIR}/enriched-cves.json"
        return 0
    else
        echo -e "$ERROR $RED No latest file found in the bucket$NORMAL" >&2
        return 1
    fi
}

function check_docker_deamon() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    if [ -n "$(sudo systemctl is-active docker)" ]; then
        echo -e "$SUCCESS $GREEN Docker deamon is running$NORMAL" >&2
        return 0
    else
        echo -e "$WARNING Docker deamon is not running$NORMAL" >&2
        return 1
    fi
}

function check_mongodb_container_exists() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    if [ -z "$(sudo docker ps -a --filter "name=mongodb" --format '{{.Names}}')" ]; then
        echo -e "MongoDB container does not exist" >&2
        return 1
    else
        echo -e "MongoDB container exists" >&2
        return 0
    fi
}

function check_mongodb_container_running() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    if [ -z "$(sudo docker ps --filter "name=mongodb" --filter "status=running" --format '{{.Names}}')" ]; then
        echo -e "MongoDB container is not running" >&2
        return 1
    else
        echo -e "MongoDB container is running" >&2
        return 0
    fi
}

function run_new_mongodb_container() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    sudo docker pull mongo:latest
    echo -e "$SUCCESS $GREEN MongoDB container pulled$NORMAL" >&2
    sudo docker run -d --name mongodb -v $(pwd)/data/db:/data/db -p 27017:27017 mongo:latest
    echo -e "$SUCCESS $GREEN MongoDB container created$NORMAL" >&2
}

function import_file_and_update_collection() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    sudo docker exec mongodb mongoimport --jsonArray --db $MONGO_DB_NAME --collection $MONGO_DB_COLLECTION_NAME --drop --file /data/db/enriched-cves.json
    echo -e "$SUCCESS $GREEN File imported and collection updated $NORMAL" >&2
}

function remove_file_from_container() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    sudo docker exec mongodb rm -f /data/db/enriched-cves.json
    echo -e "$SUCCESS $GREEN File removed from container $NORMAL" >&2
}

function copy_latest_file_to_container() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    sudo docker cp $PROJECT_DB_DIR/enriched-cves-latest.json mongodb:/data/db/enriched-cves.json
    echo -e "$SUCCESS $GREEN File copied to container $NORMAL" >&2
}

function file_exists_in_container() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    if docker exec mongodb ls -l /data/db/enriched-cves.json; then
        echo -e "$SUCCESS $GREEN File exists in container $NORMAL" >&2
        return 0
    else
        echo -e "$ERROR $RED File does not exist in container $NORMAL" >&2
        return 1
    fi
}

# sudo docker cp ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json mongodb:/data/db/enriched-cves-example.json
function handle_mongodb_container() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    echo -e "$DEBUG Project DB Dir: $PROJECT_DB_DIR" >&2
    echo -e "$DEBUG VM DB Dir: $VM_DB_DIR" >&2
    echo -e "$DEBUG MongoDB Container Name: $MONGO_CONTAINER_NAME" >&2
    echo -e "$DEBUG MongoDB DB Dir: $MONGO_DB_DIR" >&2
    echo -e "$DEBUG MongoDB DB Name: $MONGO_DB_NAME" >&2
    echo -e "$DEBUG MongoDB DB Collection Name: $MONGO_DB_COLLECTION_NAME" >&2

    if check_docker_deamon; then
        if check_mongodb_container_exists; then
            if check_mongodb_container_running; then
                # copy_latest_file_to_container
                # import_file_and_update_collection
                if file_exists_in_container; then
                    remove_file_from_container
                    copy_latest_file_to_container
                    import_file_and_update_collection
                else
                    copy_latest_file_to_container
                    import_file_and_update_collection
                fi
            else
                sudo docker start mongodb
                echo -e "$SUCCESS $GREEN MongoDB container started$NORMAL"
            fi
        else
            run_new_mongodb_container
            copy_latest_file_to_container
            import_file_and_update_collection
        fi
    else
        sudo systemctl start docker
        echo -e "$SUCCESS $GREEN Docker deamon started$NORMAL"
    fi
}


function main() {
    echo -e "$DEBUG Function: $FUNCNAME()" >&2
    echo -e "$DEBUG Project DB Dir: $PROJECT_DB_DIR" >&2
    echo -e "$DEBUG VM DB Dir: $VM_DB_DIR" >&2
    echo -e "$DEBUG MongoDB Container Name: $MONGO_CONTAINER_NAME" >&2
    echo -e "$DEBUG MongoDB DB Dir: $MONGO_DB_DIR" >&2
    echo -e "$DEBUG MongoDB DB Name: $MONGO_DB_NAME" >&2
    echo -e "$DEBUG MongoDB DB Collection Name: $MONGO_DB_COLLECTION_NAME" >&2

    echo -e "$DEBUG Creating directories if they don't exist..." >&2
    sudo mkdir -p $PROJECT_DB_DIR
    sudo chown -R $USER:$USER $PROJECT_DB_DIR && sudo chmod -R 755 $PROJECT_DB_DIR
    sudo mkdir -p $VM_DB_DIR
    sudo chown -R $USER:$USER $VM_DB_DIR && sudo chmod -R 755 $VM_DB_DIR

    BUCKET_LATEST_FILE_RESULT=$(get_latest_file_from_bucket "$FILE_NAME_PREFIX" "$BUCKET_NAME")
    if [ -f "$BUCKET_LATEST_FILE_RESULT" ]; then
        VM_LATEST_FILE_RESULT=$(find_file_in_vm "$LATEST_FILE_NAME")
        if [ -f "$VM_LATEST_FILE_RESULT" ]; then
            handle_mongodb_container
        else
            echo -e "$ERROR $RED Latest file not found in the VM$NORMAL" >&2
            VM_LATEST_FILE_RESULT=$(find_file_in_vm "$EXAMPLE_FILE_NAME")
            if [ -f "$VM_LATEST_FILE_RESULT" ]; then
                handle_mongodb_container
            else
                echo -e "$ERROR $RED Example file not found in the VM$NORMAL" >&2
            fi
        fi
    else
        echo -e "$ERROR $RED Latest file not found in the bucket$NORMAL" >&2
        VM_LATEST_FILE_RESULT=$(find_file_in_vm "$EXAMPLE_FILE_NAME")
        if [ -f "$VM_LATEST_FILE_RESULT" ]; then
            handle_mongodb_container
        else
            echo -e "$ERROR $RED Example file not found in the VM$NORMAL" >&2
        fi
    fi
}

main








# # *!!!!!!!!!!!TESTING
# #? TESTING - Get Latest File from VM
# sudo mkdir -p ~/Code/CVE_DB/vuln-db-backend/data/db
# sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db && sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db
# sudo chown -R $USER:$USER ~/data/db && sudo chmod -R 755 ~/data/db

# echo -e "\n\n" >&2
# echo -e "$BLUE Checking if the latest file exists in the VM...$NORMAL" >&2
# echo -e "$BLUE $HARD_LINE_BREAK $NORMAL" >&2
# LATEST_FILE_RESULT=$(find_file_in_vm "$LATEST_FILE_NAME")
# if [ -f "$LATEST_FILE_RESULT" ]; then
#     echo -e "$SUCCESS LATEST FILE: $YELLOW $LATEST_FILE_RESULT $NORMAL" >&2
# else
#     echo -e "$ERROR LATEST FILE:$RED NOT FOUND!!!$NORMAL" >&2
# fi

# echo -e "\n\n" >&2
# echo -e "$BLUE Checking if the example file exists in the VM...$NORMAL" >&2
# echo -e "$BLUE $HARD_LINE_BREAK $NORMAL" >&2
# EXAMPLE_FILE_RESULT=$(find_file_in_vm "$EXAMPLE_FILE_NAME")
# if [ -f "$EXAMPLE_FILE_RESULT" ]; then
#     echo -e "$SUCCESS EXAMPLE FILE: $YELLOW $EXAMPLE_FILE_RESULT $NORMAL" >&2
# else
#     echo -e "$ERROR EXAMPLE FILE:$RED NOT FOUND!!!$NORMAL" >&2
# fi



# echo -e "\n\n" >&2
# echo -e "$BLUE Checking if the final file exists in the VM...$NORMAL" >&2
# echo -e "$BLUE $HARD_LINE_BREAK $NORMAL" >&2
# FINAL_FILE_RESULT=$(find_file_in_vm "$FINAL_FILE_NAME")
# if [ -f "$FINAL_FILE_RESULT" ]; then
#     echo -e "$SUCCESS FINAL FILE: $YELLOW $FINAL_FILE_RESULT $NORMAL" >&2
# else
#     echo -e "$ERROR FINAL FILE:$RED NOT FOUND!!!$NORMAL" >&2
# fi

# #? TESTING - Get Latest File from Bucket
# echo -e "\n\n" >&2
# echo -e "$BLUE Checking if the latest file exists in the bucket...$NORMAL" >&2
# echo -e "$BLUE $HARD_LINE_BREAK $NORMAL" >&2
# LATEST_FILE_RESULT=$(get_latest_file_from_bucket "$FILE_NAME_PREFIX" "$BUCKET_NAME")
# if [ -f "$LATEST_FILE_RESULT" ]; then
#     echo -e "$SUCCESS LATEST FILE: $YELLOW $LATEST_FILE_RESULT $NORMAL" >&2
# else
#     echo -e "$ERROR LATEST FILE:$RED NOT FOUND!!!$NORMAL" >&2
# fi





















#* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# function file_exists_in_vm() {
#     local found_file_path=0
#     local file_name=$1
#     echo "" >&2
#     echo -e "$BLUE 1. Checking if the file exists in the VM...$NORMAL" >&2
#     echo -e "$BLUE $HARD_LINE_BREAK $NORMAL" >&2
#     echo -e "File Name: $YELLOW $file_name $NORMAL" >&2
#     echo "" >&2

#     local project_file_path="~/Code/CVE_DB/vuln-db-backend/data/db"
#     echo -e "$BLUE \t 1.1 Checking if the file exists in project directory $NORMAL" >&2
#     echo -e "$BLUE $SOFT_LINE_BREAK $NORMAL" >&2
#     echo -e "$BLUE \t File Path: $YELLOW $project_file_path $NORMAL" >&2
    

#     echo -e "$YELLOW $HARD_LINE_BREAK $NORMAL" >&2
#     echo -e "$BLUE=== === === === === === Results: === === === === === ===$NORMAL" >&2
#     if [ -f $project_file_path/$file_name ]; then
#         found_file_path=$project_file_path/$file_name
#         return 0
        
#         echo -e "$BLUE\n=== === === 1.1 Result:$NORMAL $GREEN File Found in Project Directory === === ===\n$NORMAL" >&2
#         echo -e "$GREEN $HARD_LINE_BREAK $NORMAL" >&2
#         echo -e "$GREEN \t Full File Path: $YELLOW $project_file_path/$file_name $NORMAL" >&2
#         echo -e "$GREEN $HARD_LINE_BREAK $NORMAL" >&2
#         echo "" >&2
#         echo "" >&2
#         return 0
#     else
#         echo -e "$RED\n=== === === 1.1 Result:$NORMAL $RED File Not Found in Project Directory === === ===\n$NORMAL" >&2
#         echo -e "$RED $SOFT_LINE_BREAK $NORMAL" >&2
#         echo -e "$RED \t 1.1 Full File Path: $YELLOW $project_file_path/$file_name $NORMAL" >&2
#         echo -e "$RED $SOFT_LINE_BREAK $NORMAL" >&2
#         echo "" >&2
#         echo "" >&2
    

#         local vm_data_file_path="~/data/db"
#         echo -e "$BLUE \t 1.2 Checking if the file exists in VM data directory: $NORMAL" >&2
#         echo -e "$BLUE $SOFT_LINE_BREAK $NORMAL" >&2
#         echo -e "$BLUE \t File Path:$YELLOW $vm_data_file_path/$file_name $NORMAL" >&2
#         echo -e "$BLUE $SOFT_LINE_BREAK $NORMAL" >&2

#         if [ -f $vm_data_file_path/$file_name ]; then
#             echo -e "$BLUE\n=== === === 1.2 Result:$NORMAL $GREEN File Found === === ===\n$NORMAL" >&2
#             echo -e "$GREEN $HARD_LINE_BREAK $NORMAL" >&2
#             echo -e "$GREEN \t 1.2 File found in the VM data directory:$NORMAL" >&2
#             echo -e "$GREEN \t Full File Path:$YELLOW $vm_data_file_path/$file_name $NORMAL" >&2
#             echo -e "$GREEN $HARD_LINE_BREAK $NORMAL" >&2
#             echo "" >&2
#             echo "" >&2
#             return 0
#         else
#             echo -e "$RED \t 1.2 File: $YELLOW $file_name $NORMAL $RED Not found in the VM data directory$NORMAL" >&2
#             echo "" >&2
#         fi
#     echo "" >&2
#     echo "" >&2
#     echo -e "$RED\n=== === === 1. Result: File Not Found === === ===\n$NORMAL" >&2
#     echo -e "$RED $HARD_LINE_BREAK $NORMAL" >&2
#     echo -e "$RED File: $YELLOW $file_name $NORMAL $RED Not found in the VM (Both in project directory and VM data directory)$NORMAL" >&2
#     echo -e "$RED Project File Path:$YELLOW $project_file_path/$file_name $NORMAL" >&2
#     echo -e "$RED VM Data File Path:$YELLOW $vm_data_file_path/$file_name $NORMAL" >&2
#     echo -e "$RED $HARD_LINE_BREAK $NORMAL" >&2
#     echo "" >&2
#     return 1
#     fi
# }

# VM_LATEST_FILE=$(file_exists_in_vm "enriched-cves-latest.json")


# echo "function file_exists_in_vm() {
#     local file_name=\$1
#     echo -e \"$BLUE 1. Checking if the file:$NORMAL $YELLOW\$file_name$NORMAL $BLUEexists in the VM...$NORMAL\" >&2
    
#     local file_path=\"~/Code/CVE_DB/vuln-db-backend/data/db\"
#     echo -e \"$BLUE 1.1 Checking if the file exists in project directory:$NORMAL $YELLOW\$file_path/\$file_name$NORMAL\" >&2
#     if [ -f \$file_path/\$file_name ]; then
#         echo -e \"$GREEN  1.1 File found in the VM project directory:$NORMAL $YELLOW\$file_path/\$file_name$NORMAL\" >&2
#         return 0
#     else
#         echo -e \"$RED 1.1 File Not found in the VM project directory:$NORMAL $YELLOW\$file_path/\$file_name$NORMAL\" >&2
#         local file_path=\"~/data/db\"
#         echo -e \"$BLUE 1.2 Checking if the file exists in VM data directory:$NORMAL $YELLOW\$file_path/\$file_name$NORMAL\" >&2
#         if [ -f \$file_path/\$file_name ]; then
#             echo -e \"$GREEN  1.2 File found in the VM data directory:$NORMAL $YELLOW\$file_path/\$file_name$NORMAL\" >&2
#             return 0
#         else
#             echo -e \"$RED 1.2 File Not found in the VM data directory:$NORMAL $YELLOW\$file_path/\$file_name$NORMAL\" >&2
#         fi
#     echo -e \"$RED 1. File Not found in the VM (Both in project directory and VM data directory)$NORMAL\" >&2
#     return 1
#     fi
# }

# VM_LATEST_FILE=\$(file_exists_in_vm \"enriched-cves-latest.json\")" > 1.sh











# # Create directory structure if it doesn't exist and set permissions
# sudo mkdir -p ~/Code/CVE_DB/vuln-db-backend/data/db
# sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db
# sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db


# #* Handle the Get Latest File and Updating the enriched-cves.json file in the VM
# #? =================================================================================
# # If a file is not found in the VM, get it from the bucket and update the enriched-cves.json file in the VM
# # If a file is found in the VM, get it from the bucket and update the enriched-cves.json file in the VM
# # If a file is found in the VM, but not in the bucket, use the example file
# # If a file is not found in the bucket, use the example file

# #* Check if the file exists in the VM
# sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db && sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db
# printf "\n\n"
# echo -e "$BLUEChecking if the enriched-cves.json file exists in the VM....$NORMAL"


# #? If latest File Exist in the VM
# if [ ! -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json ]; then
#     #* WARNING: Latest file does not exist in the VM
#     echo -e "$YELLOWNO:$NORMAL $YELLOWWARNING: Latest file does not exist in the VM$NORMAL"
# fi

#     #* Get and copy the latest file Check if the file exists in the bucket If latest File Exist in the Bucket
    
#     printf "\n\n"
#     echo -e "$BLUEChecking if the file exists in the bucket...$NORMAL"
#     if [ -n "$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json)" ]; then
#         echo -e "$BLUEGetting the latest file from the bucket...$NORMAL"
#         echo -e "$GREEN Success: Latest file found in the bucket$NORMAL"
#         echo -e "$BLUECopying the latest file from the bucket to the VM...$NORMAL"
#         LATEST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1)
#         gsutil -q cp $LATEST_FILE ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json
#         echo -e "$GREEN Success: Latest file copied from the bucket to the VM$NORMAL"
#         #* Allow the file to be read by the container
#         sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json
#         #* Copy the latest file to the enriched-cves.json
#         cp -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json
#         #* Remove the latest file from the VM
#         rm -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json
#         printf "\n\n"
#     else
#         echo -e "$REDNO:$NORMAL $YELLOWWARNING: No latest file found in the bucket$NORMAL"
#         echo -e "$BLUECopying the example file to the enriched-cves.json$NORMAL"
#         #* Copy the example file to the enriched-cves.json
#         cp -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json
#         echo -e "$GREEN Success: Example file copied to the enriched-cves.json$NORMAL"
#         printf "\n\n"
#     fi
#     #* Allow the file to be read by the container
#     sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json
#     printf "\n\n"
# else
#     echo -e "$GREEN Success: File exists in the VM$NORMAL"
#     #* Copy the latest file to the enriched-cves.json
#     cp -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json
#     sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json
#     #* Remove the latest file from the VM
#     rm -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json
#     printf "\n\n"
# fi



# #* Handle MongoDB container Create, Start, or Do Nothing
# #? =================================================================================
# #* Check if docker deamon is running
# printf "\n\n"
# echo -e "$BLUEChecking if docker deamon is running...$NORMAL"
# if [ -n "$(sudo systemctl is-active docker)" ]; then
#     echo -e "$GREEN Success: Docker deamon is running$NORMAL"
# else
#     echo -e "$REDError: Docker deamon is not running$NORMAL"
#     sudo systemctl start docker
#     echo -e "$GREEN Success: Docker deamon started$NORMAL"
# fi

# #* Check if MongoDB container exists
# printf "\n\n"
# echo -e "$BLUEChecking if MongoDB container exists...$NORMAL"
# if [ -z "$(sudo docker ps -a --filter "name=mongodb" --format '{{.Names}}')" ]; then
#     echo -e "$YELLOWNO:$NORMAL $YELLOWWARNING: MongoDB container does not exist$NORMAL"
#     echo -e "$BLUECreating MongoDB container...$NORMAL"
#     sudo docker pull mongo:latest
#     sudo docker run -d --name mongodb -v $(pwd)/data/db:/data/db -p 27017:27017 mongo:latest
#     echo -e "$GREEN Success: MongoDB container created$NORMAL"
#     echo -e "$BLUEWaiting for MongoDB to start...$NORMAL"
#     sleep 10
#     echo -e "$GREEN Success: MongoDB container started$NORMAL"
#     #* Check if the enriched-cves.json file exists in the container




#     echo -e "$BLUEChecking if the enriched-cves.json file exists in the container...$NORMAL"
#     if [ -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json ]; then
#         echo -e "$GREEN Success: enriched-cves.json file exists in the container$NORMAL"
#     else
#         echo -e "$REDError: enriched-cves.json file does not exist in the container$NORMAL"
#         echo -e "$BLUECopying the example file to the enriched-cves.json$NORMAL"
#         sudo docker cp ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json mongodb:/data/db/enriched-cves-example.json
#         echo -e "$GREEN Success: Example file copied to the enriched-cves.json$NORMAL"
#     fi
#     #* Update MongoDB with the enriched-cves.json file
#     echo -e "$BLUEUpdating MongoDB with the enriched-cves.json file...$NORMAL"
#     sudo docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves.json
#     echo -e "$GREEN Success: MongoDB updated with the enriched-cves.json file$NORMAL"

# else
#     echo -e "$GREEN Success: MongoDB container exists$NORMAL"
# fi


#     #* Check if MongoDB container is running
#     echo -e "$BLUEChecking if MongoDB container is running...$NORMAL"
#     if [ -n "$(sudo docker ps --filter "name=mongodb" --filter "status=running" --format '{{.Names}}')" ]; then
#         echo -e "$GREEN Success: MongoDB container is running$NORMAL"
#     else
#         echo -e "$YELLOWWARNING: MongoDB container is not running$NORMAL"
#         echo -e "$BLUEStarting MongoDB container...$NORMAL"
#         sudo docker start mongodb
#         echo -e "$GREEN Success: MongoDB container started$NORMAL"
#     fi


# else
#     echo -e "$REDError: MongoDB container does not exist$NORMAL"
# fi

# else
#     echo -e "$REDError: Docker deamon is not running$NORMAL"
#     sudo systemctl start docker
#     echo -e "$GREEN Success: Docker deamon started$NORMAL"
# fi

# #* Check if MongoDB container exists
# echo -e "$BLUEChecking if MongoDB container exists...$NORMAL"
# if [ -n "$(sudo docker ps -a --filter "name=mongodb" --format '{{.Names}}')" ]; then
#     echo -e "$GREEN Success: MongoDB container exists$NORMAL"
    
#     #* Check if MongoDB container is running
#     echo -e "$BLUEChecking if MongoDB container is running...$NORMAL"
#     if [ -n "$(sudo docker ps --filter "name=mongodb" --filter "status=running" --format '{{.Names}}')" ]; then
#         echo -e "$GREEN Success: MongoDB container is already running$NORMAL"
        
#         #* Check if the enriched-cves.json file exists in the container


#         if [ -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json ]; then
#             echo -e "$BLUEChecking if the enriched-cves.json file exists in the container...$NORMAL"
#             echo -e "$GREEN Success: enriched-cves.json file exists in the container$NORMAL"
#         else
#             echo -e "$REDError: enriched-cves.json file does not exist in the container$NORMAL"
#             exit 1
#         fi









#     else
#         #* If MongoDB container is not running, start it
#         echo -e "$YELLOWWARNING: MongoDB container is not running$NORMAL"
#         echo -e "$BLUEStarting MongoDB container...$NORMAL"
#         #* Start MongoDB container and exit if it fails
#         if ! sudo docker start mongodb > /dev/null; then
#             echo -e "$REDError: Failed to start MongoDB container$NORMAL" >&2
#             exit 1
#         fi
#         echo -e "$GREEN Success: MongoDB container started$NORMAL"
#     fi
# else
#     echo -e "$REDError: MongoDB container does not exist$NORMAL"
#     echo -e "$BLUECreating MongoDB container...$NORMAL"
#     #* Pull MongoDB container and exit if it fails
#     if ! sudo docker pull mongo:latest; then
#         echo -e "$REDError: Failed to pull MongoDB container$NORMAL" >&2
#         exit 1
#     fi
#     echo -e "$GREEN Success: MongoDB container pulled$NORMAL"
#     #* Create MongoDB container
#     echo -e "$BLUECreating MongoDB container...$NORMAL"
#     sudo docker run -d --name mongodb \
#         -v $(pwd)/data/db:/data/db \
#         -p 27017:27017 \
#         mongo:latest    
#     echo -e "$BLUEWaiting for MongoDB to start...$NORMAL"
#     sleep 10
#     echo -e "$GREEN Success: MongoDB container created$NORMAL"    
# fi





















# #* Check if the file exists in the VM
# echo -e "$BLUEChecking if the file exists... in the VM$NORMAL"
# sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db && sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db
# if [ ! -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json ]; then
#     echo -e "$YELLOWWARNING: Latest file does not exist in the VM$NORMAL"
    
#     #* Get and copy the latest file
#     #* Check if the file exists in the bucket
    
#     if [ -n "$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json)" ]; then
#         echo -e "$BLUEGetting the latest file...$NORMAL"
#         echo -e "$GREEN Success: Latest file found$NORMAL"
#         echo -e "$BLUECopying the latest file to the VM...$NORMAL"
#         LATEST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1)
#         gsutil -q cp $LATEST_FILE ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json
#         echo -e "$GREEN Success: Latest file copied to the VM$NORMAL"
#     #* If latest File does not exist in the Bucket use the example file
#     else
#         echo -e "$REDError: No latest file found$NORMAL"
#         #* Check if the example file exists in the VM
#         if [ -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json ]; then
#             echo -e "$YELLOWUsing example file...$NORMAL"
#             sudo cp ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves.json
#             echo -e "$GREEN Success: Example file copied to the VM$NORMAL"
#         else
#             echo -e "$REDError: Example file and latest file does not exist$NORMAL"
#             exit 1
#         fi
#     fi






# else
#     echo -e "$REDError: No latest file found$NORMAL"
#     # checking if the example file exists
#     if [ -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json ]; then
#         echo -e "$BLUEUsing example file...$NORMAL"
#     else
#         echo -e "$REDError: Example file does not exist$NORMAL"
#         exit 1
#     fi
# fi




#     if [ -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json ]; then
#         echo -e "$BLUEUsing example file...$NORMAL"
#         echo -e "$BLUECopying example file to the container...$NORMAL"
#         sudo docker cp ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json mongodb:/data/db/enriched-cves-example.json
#         echo -e "$GREEN Success: Example file copied to the container$NORMAL"
#         #* Update MongoDB with the example file
#         echo -e "$BLUEUpdating MongoDB with the example file...$NORMAL"
#         sudo docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-example.json
#         echo -e "$GREEN Success: MongoDB updated with the example file$NORMAL"   
#     else
#         echo -e "$REDError: Example file does not exist$NORMAL"
#         exit 1
#     fi
# else
#     echo -e "$GREEN Success: File exists$NORMAL"
#     echo -e "$BLUECopying the file to the container...$NORMAL"
#     sudo docker cp ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json mongodb:/data/db/enriched-cves-latest.json
#     echo -e "$GREEN Success: File copied to the container$NORMAL"
#     #* Update MongoDB with the latest CVEs
#     echo -e "$BLUEUpdating MongoDB with the latest CVEs...$NORMAL"
#     sudo docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-latest.json
#     echo -e "$GREEN Success: MongoDB updated with the latest CVEs$NORMAL"
# fi