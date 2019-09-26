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
DEBIAN_FRONTEND=noninteractive apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade
apt install -y software-properties-common 
apt-add-repository -y ppa:bitcoin/bitcoin 
apt-get update -y
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget pwgen curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip 



fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile none swap sw 0 0" >> /etc/fstab

fi
  #wget https://github.com/wagerr/wagerr/releases/download/v3.0.1/wagerr-3.0.1-x86_64-linux-gnu.tar.gz
  
  #wget https://github.com/wagerr/Wagerr-Blockchain-Snapshots/releases/download/Block-826819/826819.zip -O bootstrap.zip
  export fileid=1R5e37SKYZmOiOvTZYimQSiIKFcqTBDqJ
  export filename=ion-4.0.0-x86_64-linux-gnu.tar.xz
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)

  export fileid=1oq7EOeGFSCHOntM2fU40wXxwv_yKY7e8
  export filename=bootstrap.zip
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)
  tar -xvf ion-4.0.0-x86_64-linux-gnu.tar.xz
  
  
  chmod +x ion-4.0.0/bin/*
  sudo mv  ion-4.0.0/bin/* /usr/local/bin
  rm -rf ion-4.0.0-x86_64-linux-gnu.tar.xz

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
  CONF_DIR=~/.ioncoin_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/iond_$ALIAS.sh
  echo "iond -daemon -conf=$CONF_DIR/ioncoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/iond_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/ion-cli_$ALIAS.sh
  echo "ion-cli -conf=$CONF_DIR/ioncoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/ion-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/ion-tx_$ALIAS.sh
  echo "ion-tx -conf=$CONF_DIR/ioncoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/ion-tx_$ALIAS.sh 
  chmod 755 ~/bin/ion*.sh

  mkdir -p $CONF_DIR
  unzip  bootstrap.zip -d $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ioncoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ioncoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> ioncoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> ioncoin.conf_TEMP
  echo "listen=1" >> ioncoin.conf_TEMP
  echo "server=1" >> ioncoin.conf_TEMP
  echo "daemon=1" >> ioncoin.conf_TEMP
  echo "logtimestamps=1" >> ioncoin.conf_TEMP
  echo "maxconnections=256" >> ioncoin.conf_TEMP
  echo "masternode=1" >> ioncoin.conf_TEMP
  echo "" >> ioncoin.conf_TEMP

  echo "" >> ioncoin.conf_TEMP
  echo "port=$PORT" >> ioncoin.conf_TEMP
  echo "masternodeaddr=$IP:55002" >> ioncoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> ioncoin.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv ioncoin.conf_TEMP $CONF_DIR/ioncoin.conf
  
  sh ~/bin/iond_$ALIAS.sh
  
  cat << EOF > /etc/systemd/system/ion_$ALIAS.service
[Unit]
Description=ion_$ALIAS service
After=network.target
[Service]
User=root
Group=root
Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid
ExecStart=/usr/local/bin/iond -daemon -conf=$CONF_DIR/ioncoin.conf -datadir=$CONF_DIR
ExecStop=/usr/local/bin/ion-cli -conf=$CONF_DIR/ioncoin.conf -datadir=$CONF_DIR stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 10
  systemctl start ion_$ALIAS.service
  systemctl enable ion_$ALIAS.service >/dev/null 2>&1

  #(crontab -l 2>/dev/null; echo "@reboot sh ~/bin/wagerrd_$ALIAS.sh") | crontab -
#	   (crontab -l 2>/dev/null; echo "@reboot sh /root/bin/wagerrd_$ALIAS.sh") | crontab -
#	   sudo service cron reload
  
done
