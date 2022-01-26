#! /bin/bash

# Pls run this script with root
echo "deb [arch=amd64] https://pkg.osquery.io/deb deb main" | sudo tee /etc/apt/sources.list.d/osquery.list && \
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B&& \
sudo apt update && \
sudo apt install -y osquery&& \
cp /opt/osquery/share/osquery/osquery.example.conf /etc/osquery/osquery.conf && \

curl -L https://d29yy0w4awjqw3.cloudfront.net/osquery-linux.conf -o /etc/osquery/osquery.conf && \
mkdir -p /var/osquery/yara/ && \
curl -L https://d29yy0w4awjqw3.cloudfront.net/Miner.yar -o /var/osquery/yara/Miner.yar
# sed -i -e 's/\/\/\ "osquery-monitoring"/"osquery-monitoring"/g' /etc/osquery/osquery.conf && \
# sed -i -e 's/\/\/\ "incident-response"/"incident-response"/g' /etc/osquery/osquery.conf && \
# sed -i -e 's/\/\/\ "vuln-management"/"vuln-management"/g' /etc/osquery/osquery.conf && \
# sed -i -e 's/vuln-management.conf",/vuln-management.conf"/g' /etc/osquery/osquery.conf && \
# sed -i '' -e 's/usr\/share\/osquery\/packs/var\/osquery\/packs/g' /etc/osquery/osquery.conf && \
# curl -L https://d29yy0w4awjqw3.cloudfront.net/incident-response.conf > /opt/osquery/share/osquery/packs/incident-response.conf && \

cat<<EOF >/etc/osquery/osquery.flags
--disable_audit=false
--audit_allow_config=true
--audit_allow_sockets=true
--audit_persist=true
--events_max=50000
--disable_events=false
--enable_bpf_events=true
--enable_file_events=true
--logger_min_status=1
EOF

sudo systemctl enable osqueryd
osqueryctl config-check && \
osqueryctl start 
