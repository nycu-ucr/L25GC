# !/bin/bash  
# Automatically setup the l25gc experiment

echo -n "Select the node tpye: UERAN | 5GC | DN: "
read node_type
node_name=$(hostname)

workdir=$(pwd)
echo "Working directory is $workdir"
cd $workdir

echo "Start to configure $node_type on $node_name ..."
case $node_type in
    "UERAN") # echo 'UERAN'
    echo "Download test-packet repository for MoonGen"
    git clone https://github.com/nctu-ucr/test-packet.git
    # run utlity script to modify gtp_packet.py
    echo "Modify pcap file path"
    sed -i 's#\/home\/chu52016#'$workdir'#g' $workdir/test-packet/gtp_packet.py
    echo "ATTENTION: the mac needs to be configured manually"

    # Generate GTP with test environment
    sudo apt install -y python3
    sudo apt install -y python3-pip
    sudo pip3 install scapy

    echo "Download MoonGen"
    git clone https://github.com/emmericp/MoonGen.git
    sudo apt-get install -y libtbb2 libnuma-dev python gcc make
    sudo apt-get install -y build-essential cmake linux-headers-`uname -r` pciutils libnuma-dev
    
    echo "Build MoonGen..."
    cd $workdir/MoonGen
    ./build.sh
    
    # Set up hugepages
    sudo ./setup-hugetlbfs.sh

    echo "ATTENTION: Interfaces need to shut down before bound to DPDK"
    echo "Please run `sudo ifconfig IF_NAME down`, then run `sudo ./bind-interfaces.sh`"
    ;;


    "5GC") # echo '5GC'
    echo "========= Download nctu-ucr/onvm-upf ========="
    git clone https://github.com/nctu-ucr/onvm-upf.git

    echo "========= Download nctu-ucr/logger_util ========="
    git clone https://github.com/nctu-ucr/logger_util.git

    echo "========= Download nctu-ucr/test-script3.0.5 ========="
    git clone https://github.com/nctu-ucr/test-script3.0.5.git

    echo "========= Download nctu-ucr/onvm-pfcp3.0.5 ========="
    git clone https://github.com/nctu-ucr/onvm-pfcp3.0.5.git

    echo "========= Download nctu-ucr/onvm-free5gc3.0.5 ========="
    git clone https://github.com/nctu-ucr/onvm-free5gc3.0.5.git

    echo "========= Check whether GO is installed ========="
    if command -v go >/dev/null 2>&1; then 
        echo 'exists go, remove the existing version and install Go 1.15.8:'
        # this assumes your current version of Go is in the default location
        sudo rm -rf /usr/local/go
        wget https://dl.google.com/go/go1.15.8.linux-amd64.tar.gz
        sudo tar -C /usr/local -zxvf go1.15.8.linux-amd64.tar.gz
    else 
        echo 'no exists go'
        wget https://dl.google.com/go/go1.15.8.linux-amd64.tar.gz
        sudo tar -C /usr/local -zxvf go1.15.8.linux-amd64.tar.gz
        mkdir -p ~/go/{bin,pkg,src}
        # The following assume that your shell is bash
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
        echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc
        echo 'export GO111MODULE=auto' >> ~/.bashrc
        source ~/.bashrc
    fi

    echo "========= Install control-plane supporting packages ========="
    sudo apt -y update
    sudo apt -y install mongodb wget git
    sudo systemctl start mongodb

    echo "========= Install user-plane supporting packages ========="
    sudo apt -y update
    sudo apt -y install git gcc g++ cmake autoconf libtool pkg-config libmnl-dev libyaml-dev
    go get -u github.com/sirupsen/logrus

    echo "========= Build onvm-upf ========="
    sudo apt-get install -y build-essential linux-headers-$(uname -r) git bc
    sudo apt-get install -y python3
    sudo apt-get install -y libnuma-dev
    
    cd $workdir/onvm-upf
    # git checkout chu-upf
    git submodule sync
    git submodule update --init
    echo export ONVM_HOME=$(pwd) >> ~/.bashrc
    cd dpdk && echo export RTE_SDK=$(pwd) >> ~/.bashrc
    echo export RTE_TARGET=x86_64-native-linuxapp-gcc  >> ~/.bashrc
    echo export ONVM_NUM_HUGEPAGES=1024 >> ~/.bashrc
    source ~/.bashrc
    sudo sh -c "echo 0 > /proc/sys/kernel/randomize_va_space"
    cd ../scripts
    ./install.sh
    cd ../onvm
    make
    cd ../5gc/upf_c_complete
    make
    cd ../upf_u_complete
    make
    
    echo "========= Build onvm-free5GC3.0.5 ========="
    cd $workdir/onvm-free5gc3.0.5
    git submodule sync
    git submodule update --init
    echo "modify go.mod in each NFs"
    declare -a NFs=("amf" "ausf" "pcf" "udm" "udr" "smf" "nrf" "nssf")
    for nf in ${NFs[@]}
    do
        sed -i '$a\replace github.com/free5gc/pfcp => '$workdir'/onvm-pfcp3.0.5/' $workdir/onvm-free5gc3.0.5/NFs/$nf/go.mod
        sed -i '$a\replace github.com/free5gc/logger_util => '$workdir'/logger_util/' $workdir/onvm-free5gc3.0.5/NFs/$nf/go.mod
    done

    echo "Download go module in onvm-pfcp3.0.5"
    cd $workdir/onvm-pfcp3.0.5
    go mod download
    echo "Go to onvmNet repository"
    cd $HOME'/go/pkg/mod/github.com/nctu-ucr/onvm!net@v0.0.0-20210117143316-cd80cac36575/'
    sudo chmod +w ./*
    cp ./ipid.yaml $workdir/onvm-free5gc3.0.5
    cp ./onvmConfig.json $workdir/
    echo "Modify conn.go"
    sudo sed -i 's#\/root#'$workdir'#g' conn.go
    echo "Modify ipid.yaml"
    sed -i 's#ID:\ 2#ID:\ 4#g' $workdir/onvm-free5gc3.0.5/ipid.yaml
    sed -i 's#ID:\ 1#ID:\ 2#g' $workdir/onvm-free5gc3.0.5/ipid.yaml
    sed -i 's#ID:\ 4#ID:\ 1#g' $workdir/onvm-free5gc3.0.5/ipid.yaml
    echo "Modify conn.c"
    sudo sed -i 's#\/root\/onvmNet#'$workdir'#g' conn.c

    echo "Go to $workdir/onvm-free5gc3.0.5 and build NFs"
    cd $workdir/onvm-free5gc3.0.5
    go env -w GOPRIVATE=github.com/nctu-ucr/*
    echo "Build smf"
    make smf
    echo "Build amf"
    make amf
    echo "Build nssf"
    make nssf
    echo "Build pcf"
    make pcf
    echo "Build nrf"
    make nrf
    echo "Build ausf"
    make ausf
    echo "Build udm"
    make udm
    echo "Build udr"
    make udr
    
    cp $workdir/onvm-free5gc3.0.5/ipid.yaml $workdir/onvm-free5gc3.0.5/bin/ipid.yaml
    ;;


    "DN") # echo 'DN'
    echo "Download ONVM-UPF for DN usage"
    sudo apt-get install -y build-essential linux-headers-$(uname -r) git bc
    sudo apt-get install -y python3
    sudo apt-get install -y libnuma-dev
    sudo apt-get update
    git clone https://github.com/nctu-ucr/onvm-upf.git
    cd onvm-upf
    git submodule sync
    git submodule update --init
    echo export ONVM_HOME=$(pwd) >> ~/.bashrc
    cd dpdk && echo export RTE_SDK=$(pwd) >> ~/.bashrc
    echo export RTE_TARGET=x86_64-native-linuxapp-gcc  >> ~/.bashrc
    echo export ONVM_NUM_HUGEPAGES=1024 >> ~/.bashrc
    source ~/.bashrc
    sudo sh -c "echo 0 > /proc/sys/kernel/randomize_va_space"

    echo "Install DPDK libraries"
    cd ../scripts
    ./install.sh

    echo "Build ONVM Manager"
    cd ../onvm
    make

    echo "Build basic monitor"
    cd ../examples/basic_monitor/
    make

    echo "ATTENTION: Interfaces need to shut down before bound to DPDK"
    echo "Please run `sudo ifconfig IF_NAME down`, then bind the interfaces manually"
    ;;


    *) echo 'Configuration is terminated. Please select one of UERAN | 5GC | DN'
    ;;
esac
exit 0
