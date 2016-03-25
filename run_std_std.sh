#!/bin/bash
# $1 语音文件夹
# $2 语音标准文本
# $3 NLU标准文本

if [ "$#" -lt "3" ];then
    echo 'Usage: sh run.sh <audio_folder> <asr_standard_text> <nlu_standard_text>'
    exit 1
fi

history=history.log
asr_result=result_asr.txt
nlu_result=result_nlu.txt
asr_tmp=result_asr_tmp.txt
audio_list=audio_list.txt

echo "Testing ->$1<- ASR && NLU---------------" | tee -a $history
# 文件加x权限
chmod -R 700  ./

find $1 -name '*.pcm' -o -name '*.wav' -o -name '*.spx' -o -name '*.opus'| sort > $audio_list

# 开始解析
cur_time=`date '+%Y-%m-%d-%H:%M'`
echo 'go!'
python get_asr_nlu $audio_list

# 备份解析结果到res目录
cur_time=`date '+%Y-%m-%d-%H:%M'`
if [ ! -d bak ];then
  mkdir bak 
fi
cp result_yunzhisheng_eval.txt ./bak/result_$1_$cur_time.txt

# 去掉解析内容中的中文/英文标点符号
rm -f result_$1.txt
cat $asr_result |awk -F '\t' '{print $1,$2}'|sed -e 's/[，。？！：]//g'|sort>$asr_tmp
while read line
do
   f=`echo $line | awk '{print $1}'`
   r=`echo $line | awk '{for (i=2; i<=NF; i++) print $i}'| sed -e 's/[,.?;:!]//g'`
   echo $f $r >> result_$1.txt
done < $asr_tmp
rm -f $asr_tmp
# 去掉结果中的目录名
sed -i "s/$1\///1" result_$1.txt
sed -i "s/$1\///1" $asr_result
sed -i "s/$1\///1" $nlu_result

# Output wer result:
./wer -c -r $2 -h result_$1.txt | tee -a $history

# Output NLU Result(including recall and accurary):
python get_nlu_result $1 $3 | tee -a $history

# Ouput response_time and during_time:
resp_time=`cat result_asr.txt | awk '{sum+=$3} END {print "avg_last_resp_time : --> ", sum/(NR*1000)}'`
during_time=`cat result_asr.txt | awk '{sum+=$4} END {print "avg_during_time : -----> ", sum/(NR*1000)}'`
echo "-----------------------" | tee -a $history
echo $resp_time"s" | tee -a $history
echo $during_time"s" | tee -a $history
echo "last_resp_time: 一段语音按固定毫秒分多次传送, last_resp_time表示从最后一次传送语音数据到返回完整ASR+NLU结果的时间." | tee -a $history
echo "during_time: 从开始说话到返回完整的ASR+NLU的时间." | tee -a $history
echo -e "\n\n" >> $history
