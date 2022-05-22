#!/bin/bash

CORE_PATH=$1
UPF_PATH=$2

if [ -z "$CORE_PATH" ] || [ -z "$UPF_PATH" ] ; then
  echo "Usage: $0 <CORE_PATH> <UPF_PATH>"
  exit 1
fi

if [ -z "$TMUX" ]; then
  if [ -n "`tmux ls | grep LLfree5gc`" ]; then
    tmux kill-session -t LLfree5gc
  fi
  tmux new-session -s LLfree5gc -n demo "./task.sh $1 $2"
fi
