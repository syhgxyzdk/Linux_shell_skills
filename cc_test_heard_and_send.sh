#!/bin/bash
# 本脚本送每个pcm*心跳次,并等待结束.

cc=$1      # 启动的并发数 
pcm_dir=$2 # send pcm 的目录
log=heart_send.log

ip=10.30.2.233
port=8113

heartdev=test_dev_stab_
ownerdev=owner_dev_stab_
recv="recv from server result is"

# start send cc for every pcm
for pcm in `ls $pcm_dir`; do
    echo "$pcm_dir/$pcm" >> $log
    for x in `seq $cc`; do
      {   
        ./sendExe 0 $ip $port $heartdev$x $ownerdev$x $pcm_dir/$pcm | grep "$recv" >> $log 
      }&  
    done
    wait
    echo "sent $pcm"
    # judge the download is over by checking the log timestamp ... 
    python wait_download_done.py
    # in case of too much adpcm...
    rm -f *.adpcm
done
echo -e "\n\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n" >> $log
