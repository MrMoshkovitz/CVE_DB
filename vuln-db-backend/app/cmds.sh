#? Repo Terminal 

# TODO 1: Dockerize the backend
# TODO 2: Dockerize the frontend
# TODO 3: Deploy in the VM
# TODO 4: Automate the Dockerization in the cron job
# TODO 5: Store in the GCP Container Registry
# TODO 6: Deploy from the GCP Container Registry
# TODO 7: Automate the deployment in the cron job
# TODO 8: Consider using Kubernetes or Cloud Run and MongoDB Cloud Version
# TODO 9: Add Serverless Function to get CVE Data from NVD
# TODO 10: Add Serverless Function to enrich CVE Data (ChatGPT)
# TODO 11: Add Script Function to get the cve fix commits from the GitHub API
# TODO 12: Compare the the file diffs between the commits and the cve fix
# TODO 13: Enrhic CVE Data with the commit diffs and the cve fix data from ChatGPT
# TODO 14: Add the enriched cve data to the bucket and check for automation process of getting the enriched cve data to the backend and to the container and to the frontend

# cd ~/Code/Private/CVE_DB/
cd ~/Code/CVE_DB/vuln-db-backend
git fetch origin && git reset --hard origin/master && git pull
chmod +x ./app/test_update_cves.sh
chmod +x ./app/update_cves.sh
#* Testing Backend
docker exec -it mongodb mongosh
use vuln_db
db.cves.count()

curl http://localhost:8000 #* SUCCESS 200 - Result OK
curl http://localhost:8000/health #* SUCCESS 200 - Result OK
curl http://localhost:8000/cves #* SUCCESS 200 - Result OK
curl http://localhost:8000/cves/ #* SUCCESS 200 - Result OK
curl http://localhost:8000/cves/?cve=CVE-2024-123456 #* SUCCESS 200 - Result OK
curl http://localhost:8000/cves/?cve=cve-2024-123456 #* SUCCESS 200 - Result OK



#! Testing Frontend
curl http://35.194.17.10:8000/
curl http://35.194.17.10:8000/health
curl http://35.194.17.10:8000/cves
curl http://35.194.17.10:8000/cves/
curl http://35.194.17.10:8000/cves/?cve=CVE-2024-123456
curl http://35.194.17.10:8000/cves/?cve=cve-2024-123456


curl http://localhost:8000/cves/?cve=CVE-2024-123456
curl http://localhost:8000/cves/?cve=cve-2024-123456

#* Backend Terminal
cd ~/Code/CVE_DB/vuln-db-backend
tmux new-session -d -s backend
tmux attach -t backend
source .venv/bin/activate
pip install -r requirements.txt
python -m app.main
tmux detach

#* Frontend Terminal
cd ~/Code/CVE_DB/vuln-db-frontend
tmux new-session -d -s frontend
tmux attach -t frontend
npm install
npm run dev
tmux detach



# https://michaelcurrin.github.io/code-cookbook/recipes/artificial-intelligence/llm.html

# Remove existing known hosts and SSH keys
rm ~/.ssh/google_compute_known_hosts
rm ~/.ssh/google_compute_engine*

# Try SSH again with new keys
gcloud compute ssh cve-vm --zone=us-central1-a --force-key-file-overwrite

gcloud compute scp /Users/galmoshkovitz/.keys/cve-db-sa.json cve-vm:~/cve-db-sa.json --zone=us-central1-a
gcloud compute ssh cve-vm --zone=us-central1-a
gcloud compute firewall-rules create allow-fastapi \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:8000 \
    --source-ranges=0.0.0.0/0

gcloud compute instances add-tags cve-db-backend \
    --tags=allow-fastapi \
    --zone=us-central1-a

gcloud compute instances add-tags cve-vm \
    --tags=allow-fastapi \
    --zone=us-central1-a


git fetch origin && git reset --hard origin/master && git pull



tmux kill-session -t backend
cd ~/code/CVE_DB/vuln-db-backend
tmux new-session -d -s backend
tmux attach -t backend
source .venv/bin/activate
source .env
python -m app.main
tmux detach

curl http://localhost:8000
curl http://localhost:8000/health
curl http://localhost:8000/cves
curl http://localhost:8000/cves/
curl http://localhost:8000/cves/?cve=CVE-2024-123456
curl http://localhost:8000/cves/?cve=cve-2024-123456


tmux kill-session -t frontend
cd ~/code/CVE_DB/vuln-db-frontend
tmux new-session -d -s frontend
tmux attach -t frontend

Ctrl+b, then d to detach from the session

curl http://localhost:8000/cves
curl http://35.194.17.10:8000/cves


docker exec -it mongodb mongosh
use vuln_db
db.cves.count()






# Enable OS Login
gcloud compute instances add-metadata cve-vm --zone=us-central1-a \
    --metadata enable-oslogin=TRUE

# Try SSH again
gcloud compute ssh cve-vm --zone=us-central1-a

(crontab -l 2>/dev/null; echo "0 0 * * * LATEST_FILE=\$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1) && gsutil cp \$LATEST_FILE ~/data/enriched-cves-latest.json") | crontab -


# Authenticate with service account
export GOOGLE_APPLICATION_CREDENTIALS=~/cve-db-sa.json

sudo chown -R $USER:$USER ~/code/CVE_DB/vuln-db-backend/data
# Get the latest file
LATEST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1)
# Copy the latest file to the data directory
gsutil cp $LATEST_FILE ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-latest.json

# Get the first file
FIRST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | tail -n1)
# Copy the first file to the data directory
gsutil cp $FIRST_FILE ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-first.json






# Ask questions in the terminal. On macOS, COMMAND+K.
# CMD + Shift + G in finder to search for files.
# Select code and press COMMAND+L or COMMAND+SHIFT+L to add multiple pieces of code
# CMD + SHIFT + O to search for files in the project
# CMD + SHIFT + F to search for text in the project
# CMD + SHIFT + E to search for text in the project and replace it
# CMD + SHIFT + R to replace text in the project
# CMD + SHIFT + P to search for text in the project and replace it
# CMD + SHIFT + A to search for text in the project and replace it
# CMD + SHIFT + I to search for text in the project and replace it
# > Add New Custom Docs
#  @Code - for code snippets
#  @Docs - for documentation





2
3
4
5
## source it from ~/.bashrc or ~/.bash_profile ##
echo "source /etc/profile.d/bash_completion.sh" >> ~/.bashrc
 
## Another example Check and load it from ~/.bashrc or ~/.bash_profile ##
grep -wq '^source /etc/profile.d/bash_completion.sh' ~/.bashrc || echo 'source /etc/profile.d/bash_completion.sh'>>~/.bashrc





# # docker exec mongodb ls -l /data/db/enriched-cves-latest.json
# # To find enriched-cves-example.json file in all the container


gcloud compute scp --zone=us-central1-a ~/Code/Private/CVE-DB/vuln-db-IaC/enriched-cves-example.json cve-vm:data/db/
docker cp ~/data/db/enriched-cves-example.json mongodb:/data/db/
docker exec -it mongodb ls -l /data/db/enriched-cves-example.json
docker exec -it mongodb find ./ -name enriched-cves-example.json




# find specific file name in all ./
# find ./ -name enriched-cves-latest.json