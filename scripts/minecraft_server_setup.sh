#!/bin/bash
cd
mkdir app
cd app
wget https://papermc.io/api/v1/paper/1.16.3/231/download
mv download server.jar
java -Xms2G -Xmx2G -jar server.jar
sed -i -e "s/eula=false/eula=true/" eula.txt
sed -i -e "s/difficulty=easy/difficulty=normal/" server.properties
expect -c "
set timeout 60
spawn java -Xms2G -Xmx2G -jar ./server.jar nogui
expect -re \".*Timings Reset\"
send \"\x03\"
expect \".*Closing Server\"
"
cd ./plugins
wget https://ci.nukkitx.com/job/GeyserMC/job/Floodgate/job/development/lastSuccessfulBuild/artifact/bukkit/target/floodgate-bukkit.jar
wget https://ci.nukkitx.com/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar
cd ..
expect -c "
set timeout 60
spawn java -Xms2G -Xmx2G -jar ./server.jar nogui
expect -re \".*Timings Reset\"
send \"\x03\"
expect \".*Closing Server\"
"
cd ./plugins/Geyser-Spigot
sed -ie "s/auth-type: online/auth-type: Floodgate/" config.yml
sed -ie "s/command-suggestions: true/command-suggestions: false/" config.yml
sed -ie "s/passthrough-motd: false/passthrough-motd: true/" config.yml
sed -ie "s/passthrough-player-counts: false/passthrough-player-counts: true/" config.yml
sed -ie "s/max-players: 100/max-players: 20/" config.yml
cd ../floodgate-bukkit
sed -ir "s/username-prefix: \"*\"/username-prefix: \"_BE_\"/" config.yml
cd ../../../discord-minecraft-server-manager/scripts
cp ./minecraft_start.sh ~/app/
sudo cp ./resources/minecraft.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable minecraft
