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
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip 



fallocate -l 16G /iswapfile
chmod 600 /iswapfile
mkswap /iswapfile
swapon /iswapfile
swapon -s
echo "/iswapfile none swap sw 0 0" >> /etc/fstab

fi
  #wget https://github.com/wagerr/wagerr/releases/download/v3.0.1/wagerr-3.0.1-x86_64-linux-gnu.tar.gz
  
  #wget https://github.com/wagerr/Wagerr-Blockchain-Snapshots/releases/download/Block-826819/826819.zip -O bootstrap.zip
  export fileid=1R5e37SKYZmOiOvTZYimQSiIKFcqTBDqJ
  export filename=ion-4.0.0-x86_64-linux-gnu.tar.xz
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)

  export fileid=15djgIKqxoKVoRbj5cSRdOSExD1GQFwc1
  export filename=ibootstrap.zip
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
  unzip  ibootstrap.zip -d $CONF_DIR
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
  echo "masternodeaddr=$IP:12700" >> ioncoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> ioncoin.conf_TEMP
  echo "addnode=103.226.107.11" >> ioncoin.conf_TEMP
  echo "addnode=104.248.92.29" >> ioncoin.conf_TEMP
  echo "addnode=108.61.148.112" >> ioncoin.conf_TEMP
  echo "addnode=108.61.212.143" >> ioncoin.conf_TEMP
  echo "addnode=110.141.212.32" >> ioncoin.conf_TEMP
  echo "addnode=138.68.89.48" >> ioncoin.conf_TEMP
  echo "addnode=144.202.100.225" >> ioncoin.conf_TEMP
  echo "addnode=149.22.7.166" >> ioncoin.conf_TEMP
  echo "addnode=149.28.132.210" >> ioncoin.conf_TEMP
  echo "addnode=149.28.252.99" >> ioncoin.conf_TEMP
  echo "addnode=149.28.36.250" >> ioncoin.conf_TEMP
  echo "addnode=157.245.66.94" >> ioncoin.conf_TEMP
  echo "addnode=159.138.29.220" >> ioncoin.conf_TEMP
  echo "addnode=163.172.78.175" >> ioncoin.conf_TEMP
  echo "addnode=164.68.112.218" >> ioncoin.conf_TEMP
  echo "addnode=164.68.120.4" >> ioncoin.conf_TEMP
  echo "addnode=167.179.108.201" >> ioncoin.conf_TEMP
  echo "addnode=167.86.67.2" >> ioncoin.conf_TEMP
  echo "addnode=167.86.87.55" >> ioncoin.conf_TEMP
  echo "addnode=167.86.88.160" >> ioncoin.conf_TEMP
  echo "addnode=167.86.91.99" >> ioncoin.conf_TEMP
  echo "addnode=167.86.97.18" >> ioncoin.conf_TEMP
  echo "addnode=167.86.97.8" >> ioncoin.conf_TEMP
  echo "addnode=174.138.9.235" >> ioncoin.conf_TEMP
  echo "addnode=176.251.209.155" >> ioncoin.conf_TEMP
  echo "addnode=178.62.2.183" >> ioncoin.conf_TEMP
  echo "addnode=198.13.44.77" >> ioncoin.conf_TEMP
  echo "addnode=202.182.114.108" >> ioncoin.conf_TEMP
  echo "addnode=207.148.84.210" >> ioncoin.conf_TEMP
  echo "addnode=207.180.193.28" >> ioncoin.conf_TEMP
  echo "addnode=209.250.248.176" >> ioncoin.conf_TEMP
  echo "addnode=213.127.23.75" >> ioncoin.conf_TEMP
  echo "addnode=213.239.197.222" >> ioncoin.conf_TEMP
  echo "addnode=217.64.127.139" >> ioncoin.conf_TEMP
  echo "addnode=220.136.219.226" >> ioncoin.conf_TEMP
  echo "addnode=221.148.159.143" >> ioncoin.conf_TEMP
  echo "addnode=45.32.246.72" >> ioncoin.conf_TEMP
  echo "addnode=45.32.80.95" >> ioncoin.conf_TEMP
  echo "addnode=45.77.133.59" >> ioncoin.conf_TEMP
  echo "addnode=45.77.164.170" >> ioncoin.conf_TEMP
  echo "addnode=45.77.218.184" >> ioncoin.conf_TEMP
  echo "addnode=46.125.250.4" >> ioncoin.conf_TEMP
  echo "addnode=46.4.167.129" >> ioncoin.conf_TEMP
  echo "addnode=47.14.73.150" >> ioncoin.conf_TEMP
  echo "addnode=5.189.162.67" >> ioncoin.conf_TEMP
  echo "addnode=51.15.97.116" >> ioncoin.conf_TEMP
  echo "addnode=58.160.40.10" >> ioncoin.conf_TEMP
  echo "addnode=62.2.214.44" >> ioncoin.conf_TEMP
  echo "addnode=65.60.234.155" >> ioncoin.conf_TEMP
  echo "addnode=66.42.34.107" >> ioncoin.conf_TEMP
  echo "addnode=66.42.36.100" >> ioncoin.conf_TEMP
  echo "addnode=69.141.61.81" >> ioncoin.conf_TEMP
  echo "addnode=75.118.29.232" >> ioncoin.conf_TEMP
  echo "addnode=76.4.108.44" >> ioncoin.conf_TEMP
  echo "addnode=77.234.43.148" >> ioncoin.conf_TEMP
  echo "addnode=78.132.30.102" >> ioncoin.conf_TEMP
  echo "addnode=80.211.182.217" >> ioncoin.conf_TEMP
  echo "addnode=80.241.213.83" >> ioncoin.conf_TEMP
  echo "addnode=81.149.127.41" >> ioncoin.conf_TEMP
  echo "addnode=84.47.129.117" >> ioncoin.conf_TEMP
  echo "addnode=94.130.186.40" >> ioncoin.conf_TEMP
  echo "addnode=95.216.154.133" >> ioncoin.conf_TEMP
  echo "addnode=95.216.29.103" >> ioncoin.conf_TEMP
  echo "addnode=95.216.41.254" >> ioncoin.conf_TEMP
  echo "addnode=95.216.41.35" >> ioncoin.conf_TEMP
  echo "addnode=98.146.169.40" >> ioncoin.conf_TEMP
  echo "addnode=98.192.28.72" >> ioncoin.conf_TEMP
  echo "addnode=99.76.20.33" >> ioncoin.conf_TEMP
  
  sudo ufw allow $PORT/tcp

  mv ioncoin.conf_TEMP $CONF_DIR/ioncoin.conf
  
  #sh ~/bin/iond_$ALIAS.sh
  
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
