# Cyborg-Threat-Hunting-Lab
Elastic docker with Cyborg TH Workshop dataset

# Install docker
```
wget https://raw.githubusercontent.com/miko550/mikoscript/main/getdockerV2.sh -O getdocker.sh && bash getdocker.sh
```
## Clone repo
```
git clone https://github.com/miko550/Cyborg-Threat-Hunting-Lab.git
cd Cyborg-Threat-Hunting-Lab
```
## deploy elastic
```
cd elastic-docker
bash setup.sh
```
## Set python virtual enviroment
```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```
## create template
```
python create_simple_templates.py
```
## Ingest data dateset
```
unzip dataset/workshop.zip
python ingest_logs.py dataset/workshop.ndjson
```
