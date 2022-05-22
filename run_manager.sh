#!/bin/bash

UPF_PATH=$1

if [ -z "$UPF_PATH" ] ; then
  echo "Usage: $0 <UPF_PATH>"
  exit 1
fi

cd $UPF_PATH
sleep 1.0
./onvm/go.sh -k 3 -n 0xF8 -s stdout
