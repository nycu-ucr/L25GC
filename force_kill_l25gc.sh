#!/bin/bash

NF_LIST="nrf amf smf udr pcf udm nssf ausf n3iwf upf_u_complete upf_c_complete onvm_mgr"

for NF in ${NF_LIST}; do
    sudo killall -9 ${NF}
done

tmux kill-session -t l25gc
