curl http://35.194.17.10:8000
curl http://35.194.17.10:8000/health
curl http://35.194.17.10:8000/cves
curl http://35.194.17.10:8000/cves/
curl http://35.194.17.10:8000/cves/?cve=CVE-2024-123456
curl http://35.194.17.10:8000/cves/?cve=cve-2024-123456

curl http://localhost:8000
curl http://localhost:8000/health
curl http://localhost:8000/cves
curl http://localhost:8000/cves/
curl http://localhost:8000/cves/?cve=CVE-2024-123456
curl http://localhost:8000/cves/?cve=cve-2024-123456




git fetch origin && git reset --hard origin/master && git pull

# count json items
cat ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-latest.json | jq length

# count json items
cat ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-first.json | jq length

