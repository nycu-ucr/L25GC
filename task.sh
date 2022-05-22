#!/bin/bash

CORE_PATH=$1
UPF_PATH=$2

if [ -z "$CORE_PATH" ] || [ -z "$UPF_PATH" ] ; then
  echo "Usage: $0 <CORE_PATH> <UPF_PATH>"
  exit 1
fi

tmux set remain-on-exit on

tmux split-window -v -p 90
tmux split-window -v -p 80

tmux select-pane -t 1
./upf.sh $UPF_PATH 1 2
sleep 10.0

tmux select-pane -t 3
./core_smf.sh $CORE_PATH 3 4
sleep 10.0

tmux kill-pane -t 0
