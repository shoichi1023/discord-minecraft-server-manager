#!/bin/sh
cd ../discord-bot
sudo apt update
sudo apt install -y nodejs npm
npm install
cd ../scripts
sudo cp ./resources/discord_bot.conf /etc/init
sudo initctl reload-configuration
sudo initctl start discord_bot
