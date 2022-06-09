# L25GC: A Low Latency 5G Core Network based on High-Performance NFV Platforms
## [About]
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

## [Section1] Expirement Environment Setup
<font color="ff0000">**(Warning: the expirement requires 3 physical hosts equiped with DPDK-supported NICs)**</font>
* We use following environment as the experiment example. 
* When you run the experiment flow, appropriately adjusting parameters, such as the interface name and the MAC address, may be necessary depending on your system.

![](https://i.imgur.com/ErwJJzB.png)

### <font color="blue">Host1 (UE & RAN)</font>
#### 1. Clone the l25gc into host1
```shell
$ cd $HOME
$ git clone https://github.com/nycu-ucr/l25gc.git
```

#### 2. Build environment
```shell=
$ cd $HOME
$ source ./l25gc/build_L25GC.sh 2>&1 | tee error_l25gc.txt
# You will see
Select the node tpye: UERAN | 5GC | DN:
# Then enter
UERAN
```

#### 3. Modify the `$HOME/test-packet/gtp_packet.py`

Set following global variables.
```bash=
# These are based on your environment
SRC_MAC = "3c:fd:fe:73:82:a0" # MAC address of Host 1
DST_MAC = "3c:fd:fe:73:86:50" # MAC address of Host 2

# These are required
SRC_OUTER_IP = "10.100.200.1" # RAN IP address
DST_OUTER_IP = "10.100.200.3" # UPF IP address
SRC_INNER_IP = "60.60.0.1"    # UE IP address
DST_INNER_IP = "192.168.0.1"  # DN IP address
```


### <font color="blue">Host2 (Core Network)</font>
#### 1. Clone the l25gc into host2
```shell
$ cd $HOME
$ git clone https://github.com/nycu-ucr/l25gc.git
```
#### 2. Install L25GC
This script will install and build the following environment:
- Go
- openNetVM
- onvm-free5GC

```shell
$ cd $HOME/l25gc
l25gc$ source ./build_L25GC.sh 2>&1 | tee error_l25gc.txt
```

#### 3. Install free5GC
This script will install and build the following environment:
- Go
- free5GCv3.0.5

```shell
$ cd $HOME/l25gc
l25gc$ source ./build_free5GC.sh 2>&1 | tee error_free5GC.txt
```

#### 4. Install expirement requirements
This script will install and build the following environment:
- Gnuplot
- Expirement version smf
```shell
$ cd $HOME/l25gc
l25gc$ source ./build_expirement.sh 2>&1 | tee error_expirement.txt
```

#### 5. Manual setup some requirements
*  Run the following command
```shell=
sudo ifconfig enp1s0f0 up
sudo ifconfig enp1s0f1 up
sudo ip a add 10.100.200.3/24 dev enp1s0f0
sudo ip a add 192.168.0.2/24 dev enp1s0f1
sudo arp -s 192.168.0.1 90:e2:ba:c2:f0:42       /* MAC address of host 3 */
sudo arp -s 10.100.200.1 90:e2:ba:c2:ec:da      /* MAC address of host 1 */
sudo sysctl -w net.ipv4.ip_forward=1
sudo systemctl stop ufw
```

* Set the MAC address of DN & AN for onvm-upf
```shell=
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
l25gc/onvm-upf/5gc/upf_u_complete$ vim upf_u.txt
``` 
```shell=
# DN MAC Address
0a:c1:b2:37:42:a0                      /* MAC address of host 3 */
# AN MAC Address
5c:3d:1d:aa:b1:43                      /* MAC address of host 1 */
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

HOST = '10.10.2.45'  # The server's hostname or IP address (IP address of host 3)
PORT = 65432         # The port used by the server
```



### <font color="blue">Host3 (Data Network)</font>
1. Clone remote-executer
```
$ cd $HOME
git clone https://github.com/nctu-ucr/remote-executor.git
```
2. Run the following command
```
sudo ip address add 192.168.0.1 dev enp6s0f1
sudo ip route add 60.60.0.0/24 dev enp6s0f1
sudo arp -s 60.60.0.1 2c:f0:5d:91:45:91          /* MAC address of enp1s0f1 on host 2 */
```
3. Set the DN IP address in python_server.py
``` shell
$ cd $HOME/remote-executor
remote-executor$ vim python_server.py
```
```python=
#!/usr/bin/env python3

import socket, os

HOST = '10.10.2.45'  # Standard loopback interface address (IP address of host 3)
PORT = 65432         # Port to listen on (non-privileged ports are > 1023)
```

4. Build environment
```shell=
$ cd $HOME
$ git clone https://github.com/nycu-ucr/l25gc.git
$ source ./l25gc/build_L25GC.sh 2>&1 | tee error_l25gc.txt
# You will see
Select the node tpye: UERAN | 5GC | DN:
# Then enter
DN
```


## [Section2] Core Network Operation
### <font color="blue">A. L25GC</font>
#### (1) How to run
1. **Bind NICs to DPDK-compatible driver**
    <font color="ff0000">If you want to run L25GC, make sure two NICs are bind to DPDK</font> 
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./onvm-upf/dpdk/usertools/dpdk-setup.sh
    ```

    * Press [38] to compile x86_64-native-linuxapp-gcc version
    * Press [45] to install igb_uio driver for Intel NICs
    * Press [49] to setup 1024 2MB hugepages
    * Press [51] to bind NIC to DPDK driver
    * Press [62] to quit the tool

    (After these steps, NICs should be bind to DPDK driver)

2. **Run openNetVM manager first**
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
    
3. **Run whole core network on the other terminal**

    (Make sure to run on root privilege)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```

#### (2) How to terminate
1. **Shut down command**
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./force_kill_l25gc.sh
    ```
2. **Clear MongoDB**
    ```shell
    mongo --eval "db.dropDatabase()" free5gc
    ```

### <font color="blue">B. free5GC</font>
#### (1) How to run
1. **Unbind NICs from DPDK**
    <font color="ff0000">If you want to run free5GC, make sure two NICs are unbind from DPDK driver</font>
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./onvm-upf/dpdk/usertools/dpdk-setup.sh
    ```

    * Press [57] to bind NIC back to kernal driver
    * Press [62] to quit the tool

    (After these steps, NICs should be bind back to kernal driver)
    
2. **Change to directory of kernal-free5gc3.0.5**
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
1. **Shut down command**
    ```shell
    $ cd $HOME/l25gc/kernel-free5gc3.0.5
    l25gc/kernel-free5gc3.0.5$ sudo ./force_kill.sh
    ```
2. **Clear MongoDB**
    ```shell
    mongo --eval "db.dropDatabase()" free5gc
    ```



## [Section3] Expirement

### <font color="ff0000">Test total control plane latency for different UE events</font>
![](https://i.imgur.com/fc33cBa.png)
#### <font color="blue">free5GC</font>
##### UE-Registration & Establishment
![](https://i.imgur.com/CPRsjYz.png)
1. Run free5GC on host2 refer to section2 B-1 step1~3 (terminal 1)
2. Run test script on host2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestRegistration
    ```
3. You will see the latency of UE-Registration & Establishment (terminal 2)
4. Terminate free5GC refer to section2 B-2 step1~2 (terminal 1)
##### N2 handover
![](https://i.imgur.com/pOVdjXG.png)

1. Run free5GC on host2 refer to section2 B-1 step1~3 (terminal 1)
2. Run test script on host2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestN2Handover
    ```
3. You will see the latency of N2-handover (terminal 2)
4. Terminate free5GC refer to section2 B-2 step1~2 (terminal 1)
##### Paging
![](https://i.imgur.com/8wDcHDA.png)

1. Run free5GC on host2 refer to section2 B-1 step1~3 (terminal 1)
2. Run python_server.py on host3
    ```shell
    $ cd $HOME/l25gc/remote-executor
    remote-executor$ python3 python_server.py
    ```
3. Run test script on host2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of Paging (terminal 2)
5. Terminate free5GC refer to section2 B-2 step1~2 (terminal 1)

#### <font color="blue">L25GC</font>
##### UE-Registration & Establishment
![](https://i.imgur.com/sw4kEpq.png)
1. Run onvm-manager on host2 refer to section2 A-1 step1~3 (terminal 1)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
2. Run L25GC on host2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
3. Run test script on host2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestRegistration
    ```
4. You will see the latency of UE-Registration & Establishment (terminal 3)
5. Terminate L25GC refer to section2 A-2 step1~2 (terminal 2)
##### N2 handover
![](https://i.imgur.com/qPRg3Ws.png)

1. Run onvm-manager on host2 refer to section2 A-1 step1~3 (terminal 1)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
2. Run L25GC on host2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
3. Run test script on host2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestN2Handover
    ```
4. You will see the latency of N2-handover (terminal 3)
5. Terminate L25GC refer to section2 A-2 step1~2 (terminal 2)
##### Paging
![](https://i.imgur.com/sY4oqfy.png)
1. Run onvm-manager on host2 refer to section2 A-1 step1~3 (terminal 1)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
2. Run L25GC on host2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
3. Run test script on host2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of Paging (terminal 3)
5. Terminate L25GC refer to section2 A-2 step1~2 (terminal 2)

#### <font color="blue">Plot the result</font>
1. Type the result in the following format
    ```shell
    $ cd $HOME/l25gc
    l25gc/plot$ vim figure8.txt
    ```
    ```shell
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
3. The figure will be gernerate into "l25gc/plot" directory

### <font color="ff0000">Test latency of single control plane message between UPF/SMF</font>
![](https://i.imgur.com/njGcCiH.png)
#### <font color="blue">free5GC</font>
![](https://i.imgur.com/CjyGKzm.png)
1. Run free5GC on host2 refer to section2 B-1 step1~3 (terminal 1)
2. Run python_server.py on host3
    ```shell
    $ cd $HOME/l25gc/remote-executor
    remote-executor$ python3 python_server.py
    ```
3. Run test script on host2 (terminal 2)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of control plane message (terminal 1)
5. Terminate free5GC refer to section2 B-2 step1~2 (terminal 1)

#### <font color="blue">L25GC</font>
![](https://i.imgur.com/MAzU8yi.png)
1. Run onvm-manager on host2 refer to section2 A-1 step1~3 (terminal 1)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ ./run_manager.sh
    ```
3. Run L25GC on host2 (terminal 2)
    ```shell
    $ cd $HOME/l25gc
    l25gc$ sudo ./run_l25gc.sh
    ```
5. Run python_server.py on host3
    ```shell
    $ cd $HOME/l25gc/remote-executor
    remote-executor$ python3 python_server.py
    ```
3. Run test script on host2 (terminal 3)
    ```shell=
    $ cd $HOME/l25gc
    l25gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    #Enter TestPaging
    ```
4. You will see the latency of control plane message (terminal 2)
5. Terminate L25GC refer to section2 A-2 step1~2 (terminal 2)



### <font color="ff0000">Test UL & DL throughput</font>
![](https://i.imgur.com/csyeTVH.png)


#### Host 1 operations
Before executing the following commands, make sure you already bind the NIC to DPDK.

```shell=
$ cd $HOME/MoonGen/sendpacket
# Syntax: bash sendpacket.sh <packet size>
$ bash sendpacket.sh 68
$ bash sendpacket.sh 128
$ bash sendpacket.sh 256
$ bash sendpacket.sh 512
$ bash sendpacket.sh 1024
```

#### Host 3 operations
Before executing the following commands, make sure you already bind the NIC to DPDK.

```shell=
# Terminal 1
$ cd $HOME/onvm-upf/onvm/
$ ./go.sh -k 1 -n 0xF8 -s stdout

# Terminal 2
$ cd $HOME/onvm-upf/5gc/dn_app
$ ./go.sh 1
```

#### Host 2 operations
1. L25GC

Before executing the following commands, make sure you already bind the NICs to DPDK.

```shell=
$ cd $HOME/l25gc
# Terminal 1
$ ./run_manager.sh

# Terminal 2
$ sudo ./run_LLfree5gc.sh

# Terminal 3
$ ./test.sh
# You will see
Select the test type: TestRegistration | TestN2Handover | TestPaging:
# Then enter
TestRegistration
```

After executing the above commands, you should see the following picture on the terminal of openNetVM manager.

![](https://i.imgur.com/HKydvZy.png)
- UL throughput: (tx pps of port 1) X (packet size) X 8 / (1024^3) Gbps
- DL throughput: (tx pps of port 0) X (packet size) X 8 / (1024^3) Gbps


2. Kernel free5GC

Before executing the following commands, make sure you already bind the NICs to kernel dirver.

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

After executing the above commands, you should see the following picture on the terminal 3.

![](https://i.imgur.com/wQJ3R0V.png)
- UL throughput: (Tx bps of enp1s0f1)
- DL throughput: (Tx bps of enp1s0f0)

### <font color="ff0000">PDR lookup comparison</font>
![](https://i.imgur.com/ua1KVaJ.png)


![](https://i.imgur.com/c0bkLha.png)

#### Host 1 operations
Before executing the following commands, make sure you already bind the NIC to DPDK.

```shell=
$ cd $HOME/MoonGen/sendpacket
$ bash sendpacket.sh 68
```

#### Host 3 operations
Before executing the following commands, make sure you already bind the NIC to DPDK.

```shell=
# Terminal 1
$ cd $HOME/onvm-upf/onvm/
$ ./go.sh -k 1 -n 0xF8 -s stdout

# Terminal 2
$ cd $HOME/onvm-upf/5gc/dn_app
$ ./go.sh 1
```

#### Host 2 operations
Checkout the UPF-U to **partitionsort** branch
```shell=
$ cd $HOME/l25gc/onvm-upf/
$ git checkout partitionsort
```

Compile the PDR engine.

```shell=
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/pdr/
$ make libmycls.so
```

Recompile the UPF-U

```shell=
$ cd $HOME/l25gc/onvm-upf/5gc/upf_u_complete/
$ make clean
$ make
```


Before executing the following commands, make sure you already bind the NICs to DPDK.

```shell=
# Terminal 1
$ cd $HOME/l25gc
$ ./run_manager.sh ./onvm-upf

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


If you want to test PDR-PS with different amount of PDR rules.
Make sure the line 151 of `upf_u.c` is 
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

Activate the UPF-U.

```shell=
# Terminal 2
$ ./go.sh 1 ./pdr/fw_2.rules  ps
$ ./go.sh 1 ./pdr/fw_10.rules ps
$ ./go.sh 1 ./pdr/fw_20.rules ps
$ ./go.sh 1 ./pdr/fw_30.rules ps
$ ./go.sh 1 ./pdr/fw_40.rules ps
$ ./go.sh 1 ./pdr/fw_50.rules ps
```

If you want to test PDR-TSS with different amount of PDR rules.
Make sure the line 151 of `upf_u.c` is 
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

Activate the UPF-U.

```shell=
# Terminal 2
$ ./go.sh 1 ./pdr/fw_2.rules  ptss
$ ./go.sh 1 ./pdr/fw_10.rules ptss
$ ./go.sh 1 ./pdr/fw_20.rules ptss
$ ./go.sh 1 ./pdr/fw_30.rules ptss
$ ./go.sh 1 ./pdr/fw_40.rules ptss
$ ./go.sh 1 ./pdr/fw_50.rules ptss
```

If you want to test PDR-LL with different amount of PDR rules.
Make sure the line 151 of `upf_u.c` is 
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

Activate the UPF-U.

```shell=
# Terminal 2
## Ctrl + C to terminate ongoing process
$ ./go.sh 1 ./pdr/fw_2.rules  ll
$ ./go.sh 1 ./pdr/fw_10.rules ll
$ ./go.sh 1 ./pdr/fw_20.rules ll
$ ./go.sh 1 ./pdr/fw_30.rules ll
$ ./go.sh 1 ./pdr/fw_40.rules ll
$ ./go.sh 1 ./pdr/fw_50.rules ll
```

TODO: Screenshot

## [Section4] FAQ
### How to terminate onvm manager manualy
1. Find the PID of onvm manager
   ```console
   ps -aux |  grep onvm
   ```
2. Kill the PID of onvm manager (may have more than one process)
   ```console
   sudo kill -9 <pid>
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
