const Discord = require('discord.io');
const logger  = require('winston');
const auth    = require('./auth.json');
const instance = require('./instance.json');
const Compute = require('@google-cloud/compute');
const compute = new Compute();
const targetChannel = '672677648996237323';

logger.level = 'debug';

// BOT 初期設定
const bot = new Discord.Client({
  token: auth.token,
  autorun: true
});

//起動時に実行するコード
bot.on('ready', function (evt) {
    logger.info('Discord に接続されました。');
    logger.info('アカウント : ' + bot.username + ' ( ID : ' + bot.id + ' )');
});

//メッセージ受信時の挙動
bot.on('message', function (user, userID, channelID, message, evt) {
    if (user.id == bot.id) return;
    if(channelID == targetChannel) {
      switch(message){
        case "/start":
          bot.sendMessage({
              to      : targetChannel,
              message : 'サーバーの起動を開始します。'
          });
          start();
          break;
        case "/stop":
          bot.sendMessage({
              to      : targetChannel,
              message : 'サーバーの停止を開始します。\n90秒ほどかかります。'
          });
          stop();
          break;
        case "/help":
          bot.sendMessage({
              to      : targetChannel,
              message : '【 使用可能なコマンド 】\nstart : サーバーを起動します。\nstop : サーバーを停止します。'
          });
          break;
        default:
          break;
      }
    }
});

const start = () => {
  const vm = compute.zone(instance.zone).vm(instance.instance);
  vm.start()
    .then(data => {
      // Operation pending.
      const operation = data[0];
      return operation.promise();
    })
    .then(() => {
      vm.getMetadata()
        .then(function(data){
          const metadata = data[0];
          const ip = metadata.networkInterfaces[0].accessConfigs[0].natIP;
          bot.sendMessage({
              to      : targetChannel,
              message : `サーバーが起動しました。\n IP : ${ip}\nIPは口外しないようお願いします。\nMinecraftServerの起動まで1分ほどお待ちください。`
          });

        });
      // Operation complete. Instance successfully started.
      const message = 'Successfully started instance ' + instance.instance;
      console.log(message);
    })
    .catch(err => {
      bot.sendMessage({
          to      : targetChannel,
          message : `サーバーの起動に失敗しました。`
      });
      console.log(err);
    });
};

const stop = () => {
  const vm = compute.zone(instance.zone).vm(instance.instance);
  vm.stop()
    .then(data => {
      // Operation pending.
      const operation = data[0];
      return operation.promise();
    })
    .then(() => {
      bot.sendMessage({
          to      : targetChannel,
          message : `サーバーが停止しました。`
      });
       
      // Operation complete. Instance successfully stopped.
      const message = 'Successfully stopped instance ' + instance.instance;
      console.log(message);
    })
    .catch(err => {
      bot.sendMessage({
          to      : targetChannel,
          message : `サーバーの停止に失敗しました。`
      });
      console.log(err);
    });
};
