# L25GC: A Low Latency 5G Core Network based on High-Performance NFV Platforms
## About
### openNetVM
openNetVM is a high performance NFV platform based on [DPDK][dpdk] and [Docker][docker] containers.  openNetVM provides a flexible framework for deploying network functions and interconnecting them to build service chains.

openNetVM is an open source version of the NetVM platform described in our [NSDI 2014][nsdi14] and [HotMiddlebox 2016][hotmiddlebox16] papers, released under the [BSD][license] license.  

The [develop][dev] branch tracks experimental builds (active development) whereas the [master][mast] branch tracks verified stable releases.  Please read our [releases][rels] document for more information about our releases and release cycle.

You can find information about research projects building on [OpenNetVM][onvm] at the [UCR/GW SDNFV project site][sdnfv]. OpenNetVM is supported in part by NSF grants CNS-1422362 and CNS-1522546.

### free5GC
<p align="center">
<a href="https://free5gc.org"><img width="40%" src="https://forum.free5gc.org/uploads/default/original/1X/324695bfc6481bd556c11018f2834086cf5ec645.png" alt="free5GC"/></a>
</p>

<p align="center">
<a href="https://github.com/free5gc/free5gc/releases"><img src="https://img.shields.io/github/v/release/free5gc/free5gc?color=orange" alt="Release"/></a>
<a href="https://github.com/free5gc/free5gc/blob/master/LICENSE.txt"><img src="https://img.shields.io/github/license/free5gc/free5gc?color=blue" alt="License"/></a>
<a href="https://forum.free5gc.org"><img src="https://img.shields.io/discourse/topics?server=https%3A%2F%2Fforum.free5gc.org&color=lightblue" alt="Forum"/></a>
<a href="https://www.codefactor.io/repository/github/free5gc/free5gc"><img src="https://www.codefactor.io/repository/github/free5gc/free5gc/badge" alt="CodeFactor" /></a>
<a href="https://goreportcard.com/report/github.com/free5gc/free5gc"><img src="https://goreportcard.com/badge/github.com/free5gc/free5gc" alt="Go Report Card" /></a>
<a href="https://github.com/free5gc/free5gc/pulls"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen" alt="PRs Welcome"/></a>
</p>

The free5GC is an open-source project for 5th generation (5G) mobile core networks. The ultimate goal of this project is to implement the 5G core network (5GC) defined in 3GPP Release 15 (R15) and beyond.

For more information, please refer to [free5GC official site](https://free5gc.org/).

# L25GC: A Low Latency 5G Core Network based on High-Performance NFV Platforms

In this document, we introduce the steps of our experiments in detail. The content of this document falls into 5 sections. In Section 1, we depict the hardware requirements and system architecture. In Section 2, we elaborate on how to set up the experimental environment. In Section 3 and Section 4, we introduce how to run/stop the core networks and go through the procedures of our experiments. Finally, we summarize the frequently asked questions and the corresponding answers in Section 5.

## [Section 1] Hardware Requirements and System Architecture
* The experiments require 3 physical hosts equipped with DPDK-supported NICs.
* When you run the experiments, you may need to appropriately adjust parameters, such as the interface name and the MAC address, depending on your system.
* All of the experiments introduced in this document are based on the following architecture, which comprises three hosts: 
    1. Host 1 (RAN & UE): 
    To test our system performance, we built a traffic generator to simulate the requests sent from the User Equipment (UE) and Radio Access Network (RAN) to the core network.
    3. Host 2 (Core Network):
    We installed the L25GC and free5GC on host 2 to compare their performance.
    5. Host 3 (Data Network, DN):
    Host 3 represents a data network, forming a round trip route for our testing environment.


![](https://i.imgur.com/x9T6wIt.png)

**Minimum hardware requirements:**
* Host 1 and host 3: 4-core CPU, 16 GB RAM, one 10G-DPDK NIC 
* Host 2: 8-core CPU, 32 GB RAM, two 10G-DPDK NICs

## [Section 2] Experimental Environment Setup
In this section, we show the procedures for how to set up each hosts. Since we integrate the testing environment of three hosts into the l25gc.git, please clone the l25gc.git into three hosts and select their corresponding type to install. For the details about how to set up each host, please follow the steps we list below:
### <font color="blue">Host 1 (RAN & UE)</font>
#### 1. Clone the l25gc into host 1
```shell
$ cd $HOME
$ git clone https://github.com/nycu-ucr/l25gc.git
```

#### 2. Build environment
```shell=
$ cd $HOME
$ source ./l25gc/build_L25GC.sh 2>&1 | tee error_l25gc.txt
# You will see
Select the node type: UERAN | 5GC | DN:
# Then enter
UERAN
```

#### 3. Modify the `$HOME/test-packet/gtp_packet.py`

Set the global variables. Please be careful! Both SRC_MAC and DST_MAC are based on owners' hardware. Please check it by typing "ifconfig" and modify it. The rest of the variables are required. Please type them as we list below.
```bash=
# These are based on your environment
SRC_MAC = "90:e2:ba:c2:ec:d8" # MAC address of enp1s0f0 on host 1
DST_MAC = "2c:f0:5d:91:45:90" # MAC address of enp1s0f0 on host 2

# These are required
SRC_OUTER_IP = "10.100.200.1" # RAN IP address (IP address of enp1s0f0 on host 1)
DST_OUTER_IP = "10.100.200.3" # UPF IP address (IP address of enp1s0f0 on host 2)
SRC_INNER_IP = "60.60.0.1"    # UE IP address
DST_INNER_IP = "192.168.0.1"  # DN IP address  (IP address of enp6s0f1 on host 3)
```


### <font color="blue">Host 2 (Core Network)</font>

#### 1. Network related setting
Before cloning our l25gc.git, please setup the network as below: 
```shell=
$ sudo ifconfig enp1s0f0 up
$ sudo ifconfig enp1s0f1 up
$ sudo ip a add 10.100.200.3/24 dev enp1s0f0
$ sudo ip a add 192.168.0.2/24 dev enp1s0f1
$ sudo arp -s 192.168.0.1 90:e2:ba:c2:f0:42       /* MAC address of enp6s0f1 on host 3 */
$ sudo arp -s 10.100.200.1 90:e2:ba:c2:ec:d8      /* MAC address of enp1s0f0 on host 1 */
$ sudo sysctl -w net.ipv4.ip_forward=1
$ sudo systemctl stop ufw
```

#### 2. Clone the l25gc into host 2
In host 2, you need to install both L25GC and free5GC. We list the commands in Step 3 and Step 4 for installing L25GC and free5GC, respectively.
```shell
$ cd $HOME
$ git clone https://github.com/nycu-ucr/l25gc.git
```
#### 3. Install L25GC
This script will install and build the following environment:
- Go
- openNetVM
- onvm-free5GC

```shell
$ cd $HOME/l25gc
l25gc$ source ./build_L25GC.sh 2>&1 | tee error_l25gc.txt
# You will see
Select the node tpye: UERAN | 5GC | DN:
# Then enter
5GC
```
<font color="ff0000">(If you fail to clone DPDK when installing L25GC, please use this command  and then rebuild L25GC again.)</font>
```shell
$ git config --global http.sslVerify false
```

#### 4. Install free5GC
This script will install and build the following environment:
- Go
- free5GC v3.0.5

```shell
$ cd $HOME/l25gc
l25gc$ source ./build_free5GC.sh 2>&1 | tee error_free5GC.txt
```

#### 5. Install required tools for experiments
This script will install and build the following environment:
- Gnuplot
- Expirement version smf
```shell
$ cd $HOME/l25gc
l25gc$ source ./build_expirement.sh 2>&1 | tee error_expirement.txt
```

#### 6. Manual set up some parameters


* Set the MAC address of DN & RAN for onvm-upf
```shell=
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
l25gc/onvm-upf/5gc/upf_u_complete$ vim upf_u.txt
``` 
```shell=
# DN MAC Address
90:e2:ba:c2:f0:42    /* MAC address of enp6s0f1 on host 3 */
# RAN MAC Address
90:e2:ba:c2:ec:d8    /* MAC address of enp1s0f0 on host 1 */
```

* Set the kernel-upf config
```shell=
$ cd $HOME/l25gc/kernel-free5gc3.0.5/NFs/upf/build/config/
l25gc/kernel-free5gc3.0.5/NFs/upf/build/config$ vim upfcfg.yaml
``` 
```c
  # The IP list of the N3/N9 interfaces on this UPF
  # If there are multiple connection, set addr to 0.0.0.0 or list all the addresses
  gtpu:
    - addr: 10.100.200.3                   /* IP address of enp1s0f0 on host 2 */
    # [optional] gtpu.name
    # - name: upf.5gc.nctu.me
    # [optional] gtpu.ifname
    # - ifname: gtpif

  # The DNN list supported by UPF
  dnn_list:
    - dnn: internet # Data Network Name
      cidr: 60.60.0.0/16                   /* IPv4 pool of UE (Must be this value)*/
      # [optional] dnn_list[*].natifname
      # natifname: eth0
```

* Change the DN IP address in python_client.py
``` shell
$ cd $HOME/l25gc
l25gc$ vim ./test-script3.0.5/python_client.py
```
```python=
#!/usr/bin/env python3

import socket

HOST = '10.10.2.45'  # The server's hostname or IP address (IP address of enp3s0 on host 3)
PORT = 65432         # The port used by the server
```



### <font color="blue">Host 3 (Data Network)</font>
1. Clone remote-executer before cloning l25gc.git
```
$ cd $HOME
$ git clone https://github.com/nctu-ucr/remote-executor.git
```
2. Run the following commands to setup the IP addresses
```
$ sudo ifconfig enp6s0f1 up
$ sudo ip address add 192.168.0.1 dev enp6s0f1
$ sudo ip route add 60.60.0.0/24 dev enp6s0f1
$ sudo arp -s 60.60.0.1 2c:f0:5d:91:45:91          /* MAC address of enp1s0f1 on Host 2 */
```
* You must make sure after typing "arp" command, the arp-rule looks like below figure
    ![](https://i.imgur.com/5BhiY68.png)

3. Set the DN IP address in python_server.py (install python3 if you don't have it yet.)
``` shell
$ cd $HOME/remote-executor
remote-executor$ vim python_server.py
```
```python=
#!/usr/bin/env python3

import socket, os

HOST = '10.10.2.45'  # Standard loopback interface address (IP address of enp3s0 on host3)
PORT = 65432         # Port to listen on (non-privileged ports are > 1023)
```

4. Build environment for host 3 by selecting the type of DN:

```shell=
$ cd $HOME
$ git clone https://github.com/nycu-ucr/l25gc.git
$ source ./l25gc/build_L25GC.sh 2>&1 | tee error_l25gc.txt
# You will see
Select the node tpye: UERAN | 5GC | DN:
# Then enter
DN
```


## [Section 3] Core Network Operation
Since the experiments we show in Section 4 will reuse a set of commands to turn on/off the L25GC and the free5GC, in this section, we list the steps to run/stop L25GC and free5GC. <font color="red"> **Please go to Section 4 to start the experiment and return to Section 3 when you need to run/stop L25GC and free5GC.** </font>  
### <font color="blue">A. L25GC (on Host 2)</font>
#### (1) How to run
1. **Bind NICs to DPDK-compatible driver**
    <font color="ff0000">If you want to run L25GC, make sure two NICs are bound to DPDK.</font> 
    
    ```shell
    # Target NICs should be deactivated
    $ sudo ifconfig enp1s0f0 down
    $ sudo ifconfig enp1s0f1 down
    
    $ cd $HOME/l25gc
    l25gc$ ./onvm-upf/dpdk/usertools/dpdk-setup.sh
    ```

    * Press [38] to compile x86_64-native-linuxapp-gcc version
    * Press [45] to install igb_uio driver for Intel NICs
    * Press [49], and type '1024' to setup 1024 2MB hugepages
    * Press [51] to bind NIC to DPDK driver
      In this example, address '0000:01:00.0' and '0000:01:00.1' are typed (in two distinct [51] operations) to bind enp1s0f0 and enp1s0f1 respectively on Host 2.
    * Press [62] to quit the tool

    (After these steps, NICs should be bound to DPDK driver)

2. **Run openNetVM manager first**
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
    
3. **Run the whole core network on the other terminal of the screen.**

    (<font color="ff0000">Make sure to run on root privilege</font>)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```

#### (2) How to terminate
1. **The command for shuting down**
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./force_kill_l25gc.sh
    ```
2. **Clear MongoDB**
    ```shell
    mongo --eval "db.dropDatabase()" free5gc
    ```

### <font color="blue">B. free5GC (on Host 2)</font>
#### (1) How to run
1. **Unbind NICs from DPDK**
    <font color="ff0000">If you want to run free5GC, make sure two NICs are NOT bound by the DPDK driver.</font>
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./onvm-upf/dpdk/usertools/dpdk-setup.sh
    ```

    * Press [57] to bind NIC back to kernal driver
      1. In this example, addresses ‘0000:01:00.0’ and ‘0000:01:00.1’ are typed (in two distinct [57] operations) to bind back enp1s0f0 and enp1s0f1 respectively on Host 2.
      2.  In the second step of operation [57], a name of kernel driver, "i40e" (in this case), should be typed then.
    * Press [62] to quit the tool

    (After these steps, NICs should be bound back to kernel driver.)
    
2. **Change to the directory of kernel-free5gc3.0.5**
    ```shell
    $ cd $HOME/l25gc
    l25gc$ cd kernel-free5gc3.0.5
    ```
    
3.  **Run the core network**
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run.sh
    ```
    
#### (2) How to terminate
1. **The command for shuting down**
    ```shell
    $ cd $HOME/l25gc/kernel-free5gc3.0.5
    l25gc/kernel-free5gc3.0.5$ sudo ./force_kill.sh
    ```
2. **Clear MongoDB**
    ```shell
    mongo --eval "db.dropDatabase()" free5gc
    ```



## [Section 4] Expirement
In this section, we demonstrate how to reproduce three major experiments in our paper.
* Experiment 1: Test control plane latency for different UE events 
* Experiment 2: Test latency of single control plane message between UPF/SMF
* Experiment 3: Test uplink (UL) and downlink (DL) throughput
* Experiment 4: PDR lookup comparison



### <font color="ff0000"> Experiment 1: Test control plane latency for different UE events</font>
In this experiment, we compare the L25GC and the free5GC in terms of latency. Specifically, we have tested the L25GC and the free5GC for UE registration, establishment, N2 handover, and paging. The steps that we will show follow the order below:
- free5GC
    * UE-Registration & Establishment
    * N2 handover
    * Paging
- L25GC
    * UE-Registration & Establishment
    * N2 handover
    * Paging
- Plot the results
![](https://i.imgur.com/fc33cBa.png)
#### <font color="blue">free5GC</font>
##### UE-Registration & Establishment
![](https://i.imgur.com/4EwXT13.png)

![](https://i.imgur.com/CPRsjYz.png)
1. Run free5GC on host 2 by referring to Section 2, B-1, Steps 1-3 (terminal 1)
2. Run the test script on host 2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestRegistration
    ```
3. You will see the latency of UE-Registration & Establishment (terminal 2)
4. Terminate free5GC by referring to Section 2, B-2, Steps 1-2 (terminal 1)
##### N2 handover
![](https://i.imgur.com/4EwXT13.png)

![](https://i.imgur.com/pOVdjXG.png)

1. Run free5GC on host 2 by referring to Section 2, B-1, Steps 1-3 (terminal 1)
2. Run the test script on host 2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestN2Handover
    ```
3. You will see the latency of N2-handover (terminal 2)
4. Terminate free5GC by referring to Section 2, B-2, Steps 1-2 (terminal 1)
##### Paging
![](https://i.imgur.com/4EwXT13.png)

![](https://i.imgur.com/8wDcHDA.png)

1. Run free5GC on host 2 by referring to Section 2, B-1, Steps 1-3 (terminal 1)
2. Run python_server.py on host 3
    ```shell
    $ cd $HOME/remote-executor
    remote-executor$ python3 python_server.py
    ```
3. Run the test script on host 2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of Paging (terminal 2)
5. Terminate free5GC by referring to Section 2, B-2, Steps 1-2 (terminal 1)

#### <font color="blue">L25GC</font>
##### UE-Registration & Establishment
![](https://i.imgur.com/h4mPmCs.png)

![](https://i.imgur.com/jGaRf5X.png)

![](https://i.imgur.com/sw4kEpq.png)
1. Run onvm-manager on host 2 by referring to Section 2, A-1, Steps 1-3 (terminal 1)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
2. Run L25GC on host 2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
3. Run the test script on host 2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestRegistration
    ```
4. You will see the latency of UE-Registration & Establishment (terminal 3)
5. Terminate L25GC by referring to Section 2, A-2, Steps 1-2 (terminal 2)
##### N2 handover
![](https://i.imgur.com/h4mPmCs.png)

![](https://i.imgur.com/jGaRf5X.png)

![](https://i.imgur.com/qPRg3Ws.png)

1. Run onvm-manager on host 2 by referring to Section 2, A-1, Steps 1-3 (terminal 1)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
2. Run L25GC on host 2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
3. Run the test script on host 2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestN2Handover
    ```
4. You will see the latency of N2-handover (terminal 3)
5. Terminate L25GC by referring to Section 2, A-2, steps 1-2 (terminal 2)
##### Paging
![](https://i.imgur.com/h4mPmCs.png)

![](https://i.imgur.com/jGaRf5X.png)

![](https://i.imgur.com/sY4oqfy.png)
1. Run onvm-manager on host 2 by referring to Section 2, A-1, steps 1-3 (terminal 1) 
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
2. Run L25GC on host 2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
3. Run the test script on host 2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of Paging (terminal 3)
5. Terminate L25GC by refering to Section 2, A-2, Steps 1-2 (terminal 2)

#### <font color="blue">Plot the figure</font>
1. Type the result in the following format:
    ```shell
    $ cd $HOME/l25gc
    l25gc/plot$ vim figure8.txt
    ```
    ```shell
    # This is the content of figure8.txt:
    UE-Registration [L25GC result] [free5GC result]
    Establishment [L25GC result] [free5GC result]
    N2-handover [L25GC result] [free5GC result]
    Paing [L25GC result] [free5GC result]
    ```
2. Generate the figure
    ```shell
    $ cd $HOME/l25gc
    l25gc/plot$ gnuplot plot_figure8.gp
    ```
3. The figure will be gernerated into "l25gc/plot" directory

### <font color="ff0000">Experiment 2: Test latency of single control plane message between UPF/SMF</font>
The major purpose of this experiment is to compare the latency between L25GC and free5GC within the N4 interface (UPF - SMF). We measure the latency by testing establishment and modification. The following procedures will reproduce the figure shown in our paper. 
![](https://i.imgur.com/njGcCiH.png)
#### <font color="blue">free5GC</font>
![](https://i.imgur.com/oX8cnK2.png)
1. Run free5GC on host 2 by referring to Section 2, B-1, Steps 1-3 (terminal 1)
2. Run python_server.py on host 3
    ```shell
    $ cd $HOME/l25gc/remote-executor
    remote-executor$ python3 python_server.py
    ```
3. Run the test script on host 2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of control plane message (terminal 1)
5. Terminate free5GC by refering to Section 2, B-2, Steps 1-2 (terminal 1)

#### <font color="blue">L25GC</font>
![](https://i.imgur.com/h4mPmCs.png)

![](https://i.imgur.com/JdMzlzi.jpg)
1. Run onvm-manager on host 2 by refering to Section 2, A-1, Steps 1-3 (terminal 1)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
3. Run L25GC on host 2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
5. Run python_server.py on host 3
    ```shell
    $ cd $HOME/l25gc/remote-executor
    remote-executor$ python3 python_server.py
    ```
3. Run the test script on host 2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of control plane message (terminal 2)
5. Terminate L25GC by referring to Section 2, A-2, Steps 1-2 (terminal 2)



### <font color="ff0000">Experiment 3: Test UL & DL throughput</font>
With the change in the packet size, this experiment shows the comparison between the L25GC and the free5GC in terms of the throughput. In the following procedures, we will set up Host 1 and Host 3 first, and we will then test the throughput on Uplink/Downlink for both the L25GC and the free5GC in Host 2.

![](https://i.imgur.com/csyeTVH.png)


#### Host 1 operations
Before executing the following commands, make sure you have already bound the NIC to DPDK.

```shell=
$ cd $HOME/MoonGen/sendpacket
# Syntax: bash sendpacket.sh <packet size>
$ bash sendpacket.sh 68
$ bash sendpacket.sh 128
$ bash sendpacket.sh 256
$ bash sendpacket.sh 512
$ bash sendpacket.sh 1024
```

![](https://i.imgur.com/tyaHLaD.png)


#### Host 3 operations
Before executing the following commands, make sure you have already bound the NIC to DPDK.

```shell=
# Terminal 1
$ cd $HOME/onvm-upf/onvm/
$ ./go.sh -k 1 -n 0xF8 -s stdout

# Terminal 2
$ cd $HOME/onvm-upf/5gc/dn_app
$ ./go.sh 1
```

![](https://i.imgur.com/OUmso55.png)

![](https://i.imgur.com/i3gKwWg.png)


#### Host 2 operations
1. L25GC

Before executing the following commands, make sure you have already bound the NICs to DPDK.

```shell=
$ cd $HOME/l25gc
# Terminal 1
$ ./run_manager.sh

# Terminal 2
$ sudo ./run_l25gc.sh

# Terminal 3
$ ./test.sh
# You will see
Select the test type: TestRegistration | TestN2Handover | TestPaging:
# Then enter
TestRegistration
```

After executing the above commands, you will see the following picture on the terminal of openNetVM manager.

![](https://i.imgur.com/dacPmCO.png)

- UL throughput: (tx pps of port 1) X (packet size) X 8 / (1024^3) Gbps
- DL throughput: (tx pps of port 0) X (packet size) X 8 / (1024^3) Gbps

![](https://i.imgur.com/BJk6wBv.jpg)

![](https://i.imgur.com/f8uPjeB.png)


2. free5GC

Before executing the following commands, make sure you have already bound the NICs to kernel dirver.

```shell=
# Terminal 1
$ cd $HOME/l25gc/kernel-free5gc3.0.5
$ sudo ./run.sh

# Terminal 2
$ ./test.sh
# You will see
Select the test type: TestRegistration | TestN2Handover | TestPaging:
# Then enter
TestRegistration

# Terminal 3
$ bmon -p enp1s0f0,enp1s0f1 -b
```

After executing the above commands, you will see the following picture on terminal 3.

![](https://i.imgur.com/bS1eJUe.png)
- UL throughput: (Tx bps of enp1s0f1)
 
- DL throughput: (Tx bps of enp1s0f0)

![](https://i.imgur.com/2rq34Oe.jpg)

![](https://i.imgur.com/ispbIom.png)



### <font color="ff0000">Experiment 4: PDR lookup comparison</font>
With the change in the number of the PDRs, this experiment which was conducted on L25GC compares the searching algorithms in both latency and throughput. We set up Host 1 and Host 3 first, and we then executed the experiment on Host 2 to compare each algorithm based on linear search results.

![](https://i.imgur.com/ua1KVaJ.png)

![](https://i.imgur.com/c0bkLha.png)

#### Host 1 operations
Before executing the following commands, make sure you have already bound the NIC to DPDK.

```shell=
$ cd $HOME/MoonGen/sendpacket
$ bash sendpacket.sh 68
```

![](https://i.imgur.com/2i7J7kt.png)


<!-- 
#### Host 3 operations
Before executing the following commands, make sure you already bind the NIC to DPDK.

```shell=
# Terminal 1
$ cd $HOME/onvm-upf/onvm/
$ ./go.sh -k 1 -n 0xF8 -s stdout
```
 -->

#### Host 2 operations
Checkout the UPF-U to **pdr-expt** branch:
```shell=
$ cd $HOME/l25gc/onvm-upf/
$ git checkout pdr-expt

# If checkout fails, do "git pull" and then "git checkout pdr-expt" again
```

Compile the PDR engine:

```shell=
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/pdr/
$ make libmycls.so
```

Recompile the UPF-U:

```shell=
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
$ make clean
$ make
```


Before executing the following commands, make sure you have already bound the NICs to DPDK.

```shell=
# Terminal 1
$ cd $HOME/l25gc
$ ./run_manager.sh

# Terminal 2
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
## Syntx: ./go.sh 1 <path-to-pdr-file> <pdr-classifier-name>
$ ./go.sh 1 ./pdr/fw_20.rules ps

# Terminal 3
$ cd $HOME/l25gc/onvm-upf/5gc/upf_c_complete/
$ ./go.sh 2

# Terminal 4
$ cd $HOME/l25gc/onvm-free5gc3.0.5/
$ ./run_nosmfupf.sh

# Terminal 5
$ cd $HOME/l25gc/onvm-free5gc3.0.5/bin
$ sudo ./smf

# Terminal 6
$ cd $HOME/l25gc
$ ./test.sh
# You will see
Select the test type: TestRegistration | TestN2Handover | TestPaging:
# Then enter
TestRegistration
```


To test **PDR-PS** with different numbers of PDR rules:
<!-- Make sure the line 151 of `upf_u.c` is 
```c=
interface("ps");
```
Otherwise, change it to
```c=
interface("ps");
```

After editing the `upf_u.c`, recompile it.
```shell=
# Terminal 2
## Ctrl + C to terminate ongoing process
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
$ make
```

Activate the UPF-U. -->
```shell=
# Terminal 2
$ ./go.sh 1 ./pdr/fw_2.rules  ps
$ ./go.sh 1 ./pdr/fw_10.rules ps
$ ./go.sh 1 ./pdr/fw_20.rules ps
$ ./go.sh 1 ./pdr/fw_30.rules ps
$ ./go.sh 1 ./pdr/fw_40.rules ps
$ ./go.sh 1 ./pdr/fw_50.rules ps
...
$ ./go.sh 1 ./pdr/fw_100.rules ps
```

To test **PDR-TSS_Best** with different numbers of PDR rules:
<!-- Make sure the line 151 of `upf_u.c` is 
```c=
interface("ptss");
```
Otherwise, change it to
```c=
interface("ptss");
```

After editing the `upf_u.c`, recompile it.
```shell=
# Terminal 2
## Ctrl + C to terminate ongoing process
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
$ make
```

Activate the UPF-U. -->
```shell=
# Terminal 2
$ ./go.sh 1 ./pdr/fw_2_tss_best.rules  tss
$ ./go.sh 1 ./pdr/fw_10_tss_best.rules tss
$ ./go.sh 1 ./pdr/fw_20_tss_best.rules tss
$ ./go.sh 1 ./pdr/fw_30_tss_best.rules tss
$ ./go.sh 1 ./pdr/fw_40_tss_best.rules tss
$ ./go.sh 1 ./pdr/fw_50_tss_best.rules tss
...
$ ./go.sh 1 ./pdr/fw_100_tss_best.rules tss
```

To test **PDR-TSS_Worst** with different numbers of PDR rules:
<!-- Make sure the line 151 of `upf_u.c` is 
```c=
interface("ptss");
```
Otherwise, change it to
```c=
interface("ptss");
```

After editing the `upf_u.c`, recompile it.
```shell=
# Terminal 2
## Ctrl + C to terminate ongoing process
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
$ make
```

Activate the UPF-U. -->
```shell=
# Terminal 2
$ ./go.sh 1 ./pdr/fw_2_tss_worst.rules  tss
$ ./go.sh 1 ./pdr/fw_10_tss_worst.rules tss
$ ./go.sh 1 ./pdr/fw_20_tss_worst.rules tss
$ ./go.sh 1 ./pdr/fw_30_tss_worst.rules tss
$ ./go.sh 1 ./pdr/fw_40_tss_worst.rules tss
$ ./go.sh 1 ./pdr/fw_50_tss_worst.rules tss
...
$ ./go.sh 1 ./pdr/fw_100_tss_worst.rules tss
```

To test **PDR-LL** with different numbers of PDR rules:
<!-- Make sure the line 151 of `upf_u.c` is 
```c=
interface("ll");
```
Otherwise, change it to
```c=
interface("ll");
```

After editing the `upf_u.c`, recompile it.
```shell=
# Terminal 2
## Ctrl + C to terminate ongoing process
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
$ make
```

Activate the UPF-U. -->
```shell=
# Terminal 2
## Ctrl + C to terminate ongoing process
$ ./go.sh 1 ./pdr/fw_2.rules  ll
$ ./go.sh 1 ./pdr/fw_10.rules ll
$ ./go.sh 1 ./pdr/fw_20.rules ll
$ ./go.sh 1 ./pdr/fw_30.rules ll
$ ./go.sh 1 ./pdr/fw_40.rules ll
$ ./go.sh 1 ./pdr/fw_50.rules ll
...
$ ./go.sh 1 ./pdr/fw_100.rules ll
```

<!-- host 2 termail 1 -->
![](https://i.imgur.com/54rVqdn.png)

<!-- host 2 termail 2 -->
![](https://i.imgur.com/YRODrS4.jpg)

<!-- host 2 termail 3 -->
![](https://i.imgur.com/BAMZhKh.png)

<!-- host 2 termail 4 -->
![](https://i.imgur.com/e2YKDVK.jpg)

<!-- host 2 termail 5 -->
![](https://i.imgur.com/h1rBRyz.jpg)

<!-- host 2 termail 6 -->
![](https://i.imgur.com/tBn9fq7.png)


## [Section 5] FAQ
### How to terminate onvm manager manualy?
1. Find the PID of onvm manager
   ```console
   ps -aux |  grep onvm
   ```
2. Kill the PID of onvm manager (may have more than one process)
   ```console
   sudo kill -9 <pid>
   ```

### If you encounter the following error messages when building the environment on host 1:

```
modprobe: ERROR: could not insert 'uio': Operation not permitted
insmod: ERROR: could not insert module ./x86_64-native-linuxapp-gcc/kmod/igb_uio.ko: Operation not permitted
```

Solution
```bash=
sudo modprobe uio
cd $HOME/MoonGen/libmoon/deps/dpdk
sudo insmod ./x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
cd $HOME/MoonGen
sudo ./bind-interfaces.sh
```

### If you encounter the following error messages when building the environment on host 2:

```
fatal: unable to access 'https://dpdk.org/git/dpdk/': server certificate verification failed. CAfile: none CRLfile: none
fatal: unable to access 'https://dpdk.org/git/dpdk/': server certificate verification failed. CAfile: none CRLfile: none
```

You can disable the HTTPS verification:

```bash=
git config --global http.sslVerify false
```

[onvm]: http://sdnfv.github.io/onvm/
[sdnfv]: http://sdnfv.github.io/
[license]: LICENSE
[dpdk]: http://dpdk.org
[docker]: https://www.docker.com/
[nsdi14]: http://faculty.cs.gwu.edu/timwood/papers/14-NSDI-netvm.pdf
[hotmiddlebox16]: http://faculty.cs.gwu.edu/timwood/papers/16-HotMiddlebox-onvm.pdf
[install]: docs/Install.md
[examples]: docs/Examples.md
[nfs]: docs/NF_Dev.md
[docker-nf]: docs/Docker.md
[dev]: https://github.com/sdnfv/openNetVM/tree/develop
[mast]: https://github.com/sdnfv/openNetVM/tree/master
[rels]: docs/Releases.md
[mtcp]: https://github.com/eunyoung14/mtcp
