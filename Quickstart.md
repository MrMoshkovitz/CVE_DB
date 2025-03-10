# Backend App Quickstart

## Install Dependencies

## CVEs Data
```bash
LOCAL_DATA_DIR=/Users/galmoshkovitz/Code/Private/CVE-DB/vuln-db-backend/data/db
cp enriched-cves-example.json $LOCAL_DATA_DIR
```

## Create necessary directory structure
```bash
mkdir -p ~/code/CVE_DB/vuln-db-backend/data/db
```

## Set proper permissions
```bash
sudo chown -R $USER:$USER ~/code/CVE_DB/vuln-db-backend/data/db
```

## Create .gitkeep to preserve directory structure
```bash
touch ~/code/CVE_DB/vuln-db-backend/data/db/.gitkeep
echo "Directory structure created successfully"
```

## Update .gitignore to exclude data files but keep directory structure

```bash
echo "vuln-db-backend/env/
vuln-db-frontend/node_modules/
node_modules/
/node_modules/
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
.env
vuln-db-backend/app/cmds.sh
vuln-db-backend/data/db/
!vuln-db-backend/data/db/.gitkeep" >> .gitignore
```



## MongoDB Backend Container:
```bash
docker pull mongo
docker run -d \
  --name mongodb \
  -v $LOCAL_DATA_DIR:/data \
  -p 27017:27017 \
  mongo:latest
```

### MongoDB Import Command:
```bash
docker exec -it mongodb -- /bin/bash
mongoimport --jsonArray --db vuln_db --collection cves --file data/enriched-cves-example.json
```

### MongoDB Connection String:
```bash
MONGO_DETAILS=mongodb://localhost:27017
```

```.env
MONGO_DETAILS=mongodb://localhost:27017
MONGO_DB_NAME=vuln_db
MONGO_COLLECTION_NAME=cves
```

### Python Backend:
```bash
pip install -r requirements.txt
```

## Run the App

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

# Frontend App Quickstart

```bash
cd vuln-db-frontend
npm install
npm start
```






<!-- 

**Container ID:** 2768b7e8b9c0
**Container Name:** mongodb
**Container Image:** mongo:latest
**Container Status:** Up 9 minutes
**Container Ports:** 0.0.0.0:27017->27017/tcp
**MongoDB Connection String:** mongodb://localhost:27017
**MongoDB Database Name:** vuln_db
**MongoDB Collection Name:** cves
**MongoDB JSON File Path:** /Users/galmoshkovitz/Code/Private/CVE-DB/vuln-db-backend/data/enriched-cves-example.json
**MongoDB Import Command:** mongoimport --jsonArray --db vuln_db --collection cves --file /Users/galmoshkovitz/Code/Private/CVE-DB/vuln-db-backend/data/enriched-cves-example.json
**MongoDB Import Command:** docker exec -it 5815f92dc8df -- /bin/bash


docker run -d \
  --name mongodb \
  -v /Users/galmoshkovitz/Code/Private/CVE-DB/vuln-db-backend/data:/data \
  -p 27017:27017 \
  mongo:latest

docker exec -it mongodb -- /bin/bash

mongoimport --jsonArray --db vuln_db --collection cves --file data/enriched-cves-example.json

docker cp /Users/galmoshkovitz/Code/Private/CVE-DB/vuln-db-backend/data/enriched-cves-example.json mongodb:/data/enriched-cves-example.json


 -->