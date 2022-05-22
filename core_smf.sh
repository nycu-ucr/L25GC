#!/bin/bash

CORE_PATH=$1
CORE_PANE=$2
SMF_PANE=$3

tmux split-window -h

tmux send-keys -t $CORE_PANE "clear" Enter
tmux send-keys -t $SMF_PANE "clear" Enter
sleep 1.0

tmux send-keys -t $CORE_PANE "cd $CORE_PATH" Enter
sleep 1.0
tmux send-keys -t $SMF_PANE "cd $CORE_PATH/bin" Enter
sleep 1.0

tmux send-keys -t $CORE_PANE "./run_nosmfupf.sh" Enter
sleep 5.0
tmux send-keys -t $SMF_PANE "./smf" Enter