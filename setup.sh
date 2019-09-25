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



fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile none swap sw 0 0" >> /etc/fstab

fi
  #wget https://github.com/wagerr/wagerr/releases/download/v3.0.1/wagerr-3.0.1-x86_64-linux-gnu.tar.gz
  
  #wget https://github.com/wagerr/Wagerr-Blockchain-Snapshots/releases/download/Block-826819/826819.zip -O bootstrap.zip
  export fileid=17u7ba0HSMJ40m1PIV3Fm63J_bdEHEWbS
  export filename=wagerr-3.0.1-x86_64-linux-gnu.tar.gz
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)

  export fileid=1nEEuZHE8NKeJlYwCXtnMBXq5sDkc4SGr
  export filename=bootstrap.zip
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)
  tar xvzf wagerr-3.0.1-x86_64-linux-gnu.tar.gz
  
  
  chmod +x wagerr-3.0.1/bin/*
  sudo mv  wagerr-3.0.1/bin/* /usr/local/bin
  rm -rf wagerr-3.0.1-x86_64-linux-gnu.tar.gz

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
  CONF_DIR=~/.wagerr_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/wagerr_$ALIAS.sh
  echo "wagerrd -daemon -conf=$CONF_DIR/wagerr.conf -datadir=$CONF_DIR "'$*' >> ~/bin/wagerrd_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/wagerr-cli_$ALIAS.sh
  echo "wagerr-cli -conf=$CONF_DIR/wagerr.conf -datadir=$CONF_DIR "'$*' >> ~/bin/wagerr-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/wagerr-tx_$ALIAS.sh
  echo "wagerr-tx -conf=$CONF_DIR/wagerr.conf -datadir=$CONF_DIR "'$*' >> ~/bin/wagerr-tx_$ALIAS.sh 
  chmod 755 ~/bin/wagerr*.sh

  mkdir -p $CONF_DIR
  unzip  bootstrap.zip -d $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> wagerr.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> wagerr.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> wagerr.conf_TEMP
  echo "rpcport=$RPCPORT" >> wagerr.conf_TEMP
  echo "listen=1" >> wagerr.conf_TEMP
  echo "server=1" >> wagerr.conf_TEMP
  echo "daemon=1" >> wagerr.conf_TEMP
  echo "logtimestamps=1" >> wagerr.conf_TEMP
  echo "maxconnections=256" >> wagerr.conf_TEMP
  echo "masternode=1" >> wagerr.conf_TEMP
  echo "" >> wagerr.conf_TEMP

  echo "" >> wagerr.conf_TEMP
  echo "port=$PORT" >> wagerr.conf_TEMP
  echo "masternodeaddr=$IP:55002" >> wagerr.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> wagerr.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv wagerr.conf_TEMP $CONF_DIR/wagerr.conf
  
  sh ~/bin/wagerrd_$ALIAS.sh
done
