#!/bin/bash

UPF_PATH=$1
UPF_U_PANE=$2
UPF_C_PANE=$3

tmux split-window -h

tmux send-keys -t $UPF_U_PANE "clear" Enter
tmux send-keys -t $UPF_C_PANE "clear" Enter
sleep 1.0

tmux send-keys -t $UPF_U_PANE "cd $UPF_PATH/5gc/upf_u_complete" Enter
sleep 1.0
tmux send-keys -t $UPF_C_PANE "cd $UPF_PATH/5gc/upf_c_complete" Enter
sleep 1.0

tmux send-keys -t $UPF_U_PANE "./go.sh 1" Enter
sleep 5.0
tmux send-keys -t $UPF_C_PANE "./go.sh 2" Enter