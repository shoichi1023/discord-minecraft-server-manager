#!/bin/sh
cd ../discord-bot
sudo apt update
sudo apt install -y nodejs npm
npm install
cd ../scripts
sudo cp ./resources/discord_bot.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable discord_bot
