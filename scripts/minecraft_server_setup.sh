#!/bin/bash
cd
mkdir app
cd app
wget https://papermc.io/api/v1/paper/1.16.3/231/download
mv download server.jar
java -Xms2G -Xmx2G -jar server.jar
sed -i -e "s/eula=false/eula=true/" eula.txt
sed -i -e "s/difficulty=easy/difficulty=normal/" server.properties
java -Xms2G -Xmx2G -jar server.jar nogui
expect -c "
set timeout 60
spawn java -Xms2G -Xmx2G -jar ./server.jar nogui
expect -re \".*Timings Reset\"
send \"\003\"
"
cd ./plugins
wget https://ci.nukkitx.com/job/GeyserMC/job/Floodgate/job/development/lastSuccessfulBuild/artifact/bukkit/target/floodgate-bukkit.jar
wget https://ci.nukkitx.com/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar
cd ..
expect -c "
set timeout 60
spawn java -Xms2G -Xmx2G -jar ./server.jar nogui
expect -re \".*Timings Reset\"
send \"\003\"
"
cd ./plugins/Geyser-Spigot
sed -ie "s/auth-type: online/auth-type: Floodgate/" config.yml
sed -ie "s/command-suggestions: true/command-suggestions: false/" config.yml
sed -ie "s/passthrough-motd: false/passthrough-motd: true/" config.yml
sed -ie "s/passthrough-player-counts: false/passthrough-player-counts: true/" config.yml
sed -ie "s/max-players: 100/max-players: 20/" config.yml
cd ../Floodgate-bukkit
sed -ir "s/username-prefix: \"*\"/username-prefix: \"_BE_\"/" config.yml
cd ../../../script
cp ./minecraft_start.sh ~/app/
sudo cp ./resources/minecraft.service /etc/systemd/
sudo systemctl daemon-reload
sudo systemctl enable minecraft
