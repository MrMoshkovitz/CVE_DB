#? Repo Terminal 
# cd ~/Code/Private/CVE_DB/
cd ~/Code/CVE_DB/
git fetch origin && git reset --hard origin/master && git pull

#* Testing Backend
docker exec -it mongodb mongosh
use vuln_db
db.cves.count()


curl http://localhost:8000 # 200 - Result OK
curl http://localhost:8000/health # 200 - Result OK
curl http://localhost:8000/cves # 200 - Result Not good - Empty
curl http://localhost:8000/cves/ # 200 - Result Not good - Empty



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
