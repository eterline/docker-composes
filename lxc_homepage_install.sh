#!/bin/bash
echo "Updating system"
apt update
apt upgrade -y
echo "Installing dependencies"
apt install nodejs
wget -qO- https://get.pnpm.io/install.sh | sh -
source /root/.bashrc
apt install git -y
git clone https://github.com/gethomepage/homepage.git
cd homepage/
pnpm install
pnpm build
echo "Making autostart file"
content=$(cat <<EOF
[Unit]
Description=HTTP Server on http://host-ip:3000
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/homepage
ExecStart=/root/.local/share/pnpm/pnpm start
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
)
echo "Setup autostart"
echo "$content" > "homepage.service"
cp homepage.service /etc/systemd/system/homepage.service
systemctl enable homepage.service
systemctl start homepage.service
systemctl status homepage.service
echo "homepage has been installed on LXC... and running in http://host-ip:3000"
exit