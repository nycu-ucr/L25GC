#!/bin/bash

CORE_PATH="./onvm-free5gc3.0.5/"
UPF_PATH="./onvm-upf/"

if [ -z "$CORE_PATH" ] || [ -z "$UPF_PATH" ] ; then
  echo "Usage: $0 <CORE_PATH> <UPF_PATH>"
  exit 1
fi

if [ -z "$TMUX" ]; then
  if [ -n "`tmux ls | grep l25gc`" ]; then
    tmux kill-session -t l25gc
  fi
  tmux new-session -s l25gc -n demo "./task.sh $CORE_PATH $UPF_PATH"
fi
