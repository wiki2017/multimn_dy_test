wget https://github.com/Streamies/Streamies/releases/download/v2.3/Streamies-2.3.0.0-x86_64-pc-linux-gnu.zip
  
  export fileid=1Lz5mWPetZ2lGCunEOMzVtvVb6u7878ln
  export filename=bootstrap.zip
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)
  unzip Streamies-2.3.0.0-x86_64-pc-linux-gnu.zip
  
  chmod +x streamiesd
  chmod +x streamies-cli
  sudo cp  streamiesd /usr/local/bin
  sudo cp  streamies-cli /usr/local/bin
  rm -rf Streamies-2.3.0.0-x86_64-pc-linux-gnu.zip
  rm -rf streamies-cli
  rm -rf streamiesd
  rm -rf streamies-tx
  rm -rf streamies-qt
  rm -rf streamiesd.1
  
  echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
read MNCOUNT
for i in `seq 1 1 mn$MNCOUNT`; do
  systemctl stop streamies_mn$MNCOUNT
  
  rm -rf ~/.streamies_mn$MNCOUNT/blocks
  rm -rf ~/.streamies_mn$MNCOUNT/chainstate
  rm -rf ~/.streamies_mn$MNCOUNT/sporks
  rm -rf ~/.streamies_mn$MNCOUNT/zerocoin
  rm -rf ~/.streamies_mn$MNCOUNT/.lock
  rm -rf ~/.streamies_mn$MNCOUNT/*.dat
  unzip  bootstrap.zip -d ~/.streamies_mn$MNCOUNT
  systemctl start streamies_mn$MNCOUNT
  
  done
  
  
