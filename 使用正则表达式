#!/bin/bash
vPattern="[vV]\d+\.?\d+\.?\d"
commit_log='./results/regression.commit.log'

if [[ $1 =~ $vPattern ]]; then 
  rm -f $commit.log
  cp ./results/regression.log $commit_log
  git add $commit_log
  # insert commit.log to version_history_log(include newly and miss)
  python insert_history.py
  git add ./results/history/history.log
  git commit -m "push commit.log and add tag for nlu $1"
  git push origin master
  git tag $1
  git push origin $1
  echo "push regression.commit.log for nlu $1 done!"
  # for next testing, output nlu version 
  echo $1 > ./results/version.info
fi
