#!/bin/bash

store_dir='adpcm2pcm'
adpcm_dir='adpcm_store'

rm -fr $store_dir
mkdir $store_dir

rm -fr $adpcm_dir
mkdir $adpcm_dir

for x in `ls *.adpcm`;do
    ./adpcm 2 $x ./$store_dir/$x".pcm" 1>/dev/null 2>&1 
    mv $x ./$adpcm_dir/$x
done

# 检查是否有削波 
python check_clipping.py $store_dir
