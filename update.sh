#/bin/bash
  echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
  read MNCOUNT
  
  for i in `seq 1 1 $MNCOUNT`; do
  systemctl stop streamies_mn$MNCOUNT.service
  rm -rf ~/.streamies_mn$MNCOUNT/blocks
  rm -rf ~/.streamies_mn$MNCOUNT/chainstate
  rm -rf ~/.streamies_mn$MNCOUNT/sporks
  rm -rf ~/.streamies_mn$MNCOUNT/zerocoin
  rm -rf ~/.streamies_mn$MNCOUNT/.lock
  rm -rf ~/.streamies_mn$MNCOUNT/*.dat
  unzip  bootstrap.zip -d ~/.streamies_mn$MNCOUNT
  systemctl start streamies_mn$MNCOUNT.service
  
  done
  rm -rf update.sh
  
  
  
  
