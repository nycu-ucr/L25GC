# !/bin/bash  

workdir=$(pwd)
echo "Working directory is $workdir"
cd $workdir

echo "========= Install gnuplot ========="
sudo apt-get update
sudo apt-get install gnuplot

echo "======= Update pfcp package ======="
echo "Change kernal pfcp package"
cd $HOME'/go/pkg/mod/github.com/free5gc/pfcp@v1.0.0'
sudo cp $workdir/plot/transaction_kernal.go ./transaction.go
echo "Change kernal pfcp package"
cd $HOME'/go/pkg/mod/github.com/nycu-ucr/pfcp@v0.0.0-20220603133134-887add8b5f14'
sudo cp $workdir/plot/transaction_l25gc.go ./transaction.go

echo "======= Rebuild kernal-smf ========"
cd $workdir/kernel-free5gc3.0.5
rm bin/smf
make smf
echo "======= Rebuild l25gc-smf  ========"
cd $workdir/onvm-free5gc3.0.5
rm bin/smf
make smf
echo "============= DONE ================"
