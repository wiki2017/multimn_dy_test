#/bin/bash
COINNAME='dynamic'
COIN_DAEMON='dynamicd'
COIN_CLI='dynamic-cli'
COIN_QT='dynamic-qt'
COIN_TX='dynamic-tx'
CONFIG_FILE='dynamic.conf'
COIN_TGZ='https://github.com/duality-solutions/Dynamic/releases/download/v2.5.0.0/Dynamic-2.5.0.0-Linux-x64.tar.gz'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')

COIN_PORT=33300


#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Transcendence  masternodes.  *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [ $DOSETUP = "y" ]  
then
 
apt-get update -y
#DEBIAN_FRONTEND=noninteractive apt-get update 
#DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade
apt install -y software-properties-common 
apt-add-repository -y ppa:bitcoin/bitcoin 
apt-get update -y
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget pwgen curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip lib32stdc++6 lib32z1 libzmq5
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

sudo apt -y install gcc-6
sudo apt -y install g++-6

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6 
sudo apt -y update
sudo apt -y upgrade



fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile none swap sw 0 0" >> /etc/fstab




fi

  wget -d $COIN_TGZ
  export fileid=0B-FjWl5F1zczaEQ4VURMZV9EWWM
  export filename=bootstrap.zip
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  
  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)
  unzip $COIN_ZIP
  chmod +x $COIN_DAEMON
  chmod +x $COIN_CLI
  sudo cp  $COIN_DAEMON /usr/local/bin
  sudo cp  $COIN_CLI /usr/local/bin
  rm -rf $COIN_ZIP
  rm -rf $COIN_CLI
  rm -rf $COIN_DAEMON
  rm -rf $COIN_TX
  rm -rf $COIN_QT
  #rm -rf $COIN_CLI.1
  #rm -rf $COIN_DAEMON.1
  #rm -rf $COIN_TX.1
  #rm -rf $COIN_QT.1


  sudo apt install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc


 ## Setup conf
 IP=$(curl -s4 api.ipify.org)
 mkdir -p ~/bin
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"

 echo ""
 echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
 read MNCOUNT
  
  

for i in `seq 1 1 $MNCOUNT`; do
  echo ""
  echo "Enter alias for new node"
  read ALIAS  
  echo ""
  echo "Enter port for node $ALIAS"
  read PORT
  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY
  RPCPORT=$(($PORT*10))
  echo "The RPC port is $RPCPORT"
  ALIAS=${ALIAS}
  CONF_DIR=~/.$COINNAME$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/$COIN_DAEMON$ALIAS.sh
  echo "$COIN_DAEMON -daemon -conf=$CONF_DIR/$CONFIG_FILE -datadir=$CONF_DIR "'$*' >> ~/bin/$COIN_DAEMON$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/$COIN_CLI$ALIAS.sh
  echo "$COIN_CLI -conf=$CONF_DIR/$CONFIG_FILE -datadir=$CONF_DIR "'$*' >> ~/bin/$COIN_CLI$ALIAS.sh
  chmod 755 ~/bin/$COIN_DAEMON$ALIAS.sh
  chmod 755 ~/bin/$COIN_CLI$ALIAS.sh
  mkdir -p $CONF_DIR
  unzip  bootstrap.zip -d $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> $CONFIG_FILE
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> $CONFIG_FILE
  echo "rpcallowip=127.0.0.1" >> $CONFIG_FILE
  echo "rpcport=$RPCPORT" >> $CONFIG_FILE
  echo "listen=1" >> $CONFIG_FILE
  echo "server=1" >> $CONFIG_FILE
  echo "daemon=1" >> $CONFIG_FILE
  echo "logtimestamps=1" >> $CONFIG_FILE
  echo "maxconnections=256" >> $CONFIG_FILE
  echo "masternode=1" >> $CONFIG_FILE
  echo "" >> $CONFIG_FILE

  echo "" >> $CONFIG_FILE
  echo "port=$PORT" >> $CONFIG_FILE
  echo "masternodeaddr=$IP:$COIN_PORT" >> $CONFIG_FILE
  echo "masternodeprivkey=$PRIVKEY" >> $CONFIG_FILE
  echo "addnode=[2001:41d0:700:47e::]:33300" >> $CONFIG_FILE
  echo "addnode=[2a01:e0a:ee:fb30:9a90:96ff:fed6:b450]:33300" >> $CONFIG_FILE
  echo "addnode=116.203.56.43:33300" >> $CONFIG_FILE
  echo "addnode=135.181.52.135:33300" >> $CONFIG_FILE
  echo "addnode=136.243.29.195:33300" >> $CONFIG_FILE
  echo "addnode=159.69.83.47:33300" >> $CONFIG_FILE
  echo "addnode=161.97.141.76:33300" >> $CONFIG_FILE
  echo "addnode=168.119.80.4:33300" >> $CONFIG_FILE
  echo "addnode=168.119.87.193:33300" >> $CONFIG_FILE
  echo "addnode=168.119.87.195:33300" >> $CONFIG_FILE
  echo "addnode=176.9.210.2:33300" >> $CONFIG_FILE
  echo "addnode=178.62.5.100:33300" >> $CONFIG_FILE
  echo "addnode=178.63.121.129:33300" >> $CONFIG_FILE
  echo "addnode=178.63.235.193:33300" >> $CONFIG_FILE
  echo "addnode=188.40.163.3:33300" >> $CONFIG_FILE
  echo "addnode=188.40.184.65:33300" >> $CONFIG_FILE
  echo "addnode=192.210.228.215:33300" >> $CONFIG_FILE
  echo "addnode=195.201.207.24:33300" >> $CONFIG_FILE
  echo "addnode=51.15.129.216:33300" >> $CONFIG_FILE
  echo "addnode=51.15.46.203:33300" >> $CONFIG_FILE
  echo "addnode=51.15.51.189:33300" >> $CONFIG_FILE
  echo "addnode=51.15.60.147:33300" >> $CONFIG_FILE
  echo "addnode=51.15.61.31:33300" >> $CONFIG_FILE
  echo "addnode=8.9.6.89:33300" >> $CONFIG_FILE
  echo "addnode=88.99.11.0:33300" >> $CONFIG_FILE
  echo "addnode=88.99.11.2:33300" >> $CONFIG_FILE
  echo "addnode=88.99.11.3:33300" >> $CONFIG_FILE
  echo "addnode=94.130.184.73:33300" >> $CONFIG_FILE
  echo "addnode=95.216.109.132:33300" >> $CONFIG_FILE
  echo "addnode=95.216.79.232:33300" >> $CONFIG_FILE
  echo "addnode=95.217.48.101:33300" >> $CONFIG_FILE
  echo "addnode=95.217.48.102:33300" >> $CONFIG_FILE
  echo "addnode=164.68.125.170" >> $CONFIG_FILE
  echo "addnode=155.138.218.41" >> $CONFIG_FILE
  echo "addnode=116.202.47.198" >> $CONFIG_FILE
  echo "addnode=108.61.144.241" >> $CONFIG_FILE
  echo "addnode=217.67.229.223" >> $CONFIG_FILE
  echo "addnode=190.96.1.19" >> $CONFIG_FILE
  echo "addnode=86.122.44.179" >> $CONFIG_FILE
  echo "addnode=216.128.140.18" >> $CONFIG_FILE
  echo "addnode=190.96.1.19" >> $CONFIG_FILE
  echo "addnode=51.15.120.57" >> $CONFIG_FILE
  echo "addnode=172.112.30.148" >> $CONFIG_FILE
  echo "addnode=46.123.236.190" >> $CONFIG_FILE
  echo "addnode=174.4.72.251" >> $CONFIG_FILE
  echo "addnode=172.111.162.167" >> $CONFIG_FILE
  echo "addnode=69.14.75.223" >> $CONFIG_FILE
  echo "addnode=188.27.146.159" >> $CONFIG_FILE
 
  sudo ufw allow $PORT/tcp
  mv $CONFIG_FILE $CONF_DIR/$CONFIG_FILE
  
  
  
  cat << EOF > /etc/systemd/system/$COINNAME$ALIAS.service
[Unit]
Description=$COINNAME$ALIAS service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/$COIN_DAEMON -daemon -conf=$CONF_DIR/$CONFIG_FILE -datadir=$CONF_DIR
ExecStop=/usr/local/bin/$COIN_CLI -conf=$CONF_DIR/$CONFIG_FILE -datadir=$CONF_DIR stop
Restart=always
PrivateTmp=true
TimeoutStartSec=10m
StartLimitInterval=0
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 10
  
  systemctl start $COINNAME$ALIAS.service
  systemctl enable $COINNAME$ALIAS.service >/dev/null 2>&1


  rm -rf newsetup.sh

  #(crontab -l 2>/dev/null; echo "@reboot sh ~/bin/wagerrd_$ALIAS.sh") | crontab -
#	   (crontab -l 2>/dev/null; echo "@reboot sh /root/bin/wagerrd_$ALIAS.sh") | crontab -
#	   sudo service cron reload
  
done
