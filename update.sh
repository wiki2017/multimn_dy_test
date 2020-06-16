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
  
  
  systemctl stop streamies_mn1.service
  
  rm -rf ~/.streamies_mn1/blocks
  rm -rf ~/.streamies_mn1/chainstate
  rm -rf ~/.streamies_mn1/sporks
  rm -rf ~/.streamies_mn1/zerocoin
  rm -rf ~/.streamies_mn1/.lock
  rm -rf ~/.streamies_mn1/*.dat
  unzip  bootstrap.zip -d ~/.streamies_mn1
  systemctl start streamies_mn1.serive
  
  
  
  
