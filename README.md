# LL5gc

[TODO]


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

## Installing
### LL5GC
This script will install and build the following environment:
- Go
- openNetVM
- onvm-free5GC

```shell
LL5gc$ source ./build_L25GC.sh 2>&1 | tee error_LL5GC.txt
```

### Kernel free5GC
This script will install and build the following environment:
- Go
- free5GCv3.0.5

```shell
LL5gc$ source ./build_free5GC.sh 2>&1 | tee error_free5GC.txt
```

## Runing
### Kernal free5GC
1. **Change to directory of kernal-free5gc3.0.5**
    ```shell
    LL5gc$ cd kernel-free5gc3.0.5
    ```
2.  **Run the core network**
    ```shell
    LL5gc$ sudo ./run.sh
    ```
### LL5GC

1. **Setting up DPDK manually**
    ```shell
    LL5gc$ ./onvm-upf/dpdk/usertools/dpdk-setup.sh
    ```

    * Press [38] to compile x86_64-native-linuxapp-gcc version
    * Press [45] to install igb_uio driver for Intel NICs
    * Press [49] to setup 1024 2MB hugepages
    * Press [51] to register the Ethernet ports
    * Press [62] to quit the tool

    (After these steps, dpdk should be set up)

2. **Run openNetVM manager first**
    ```shell
    LL5gc$ ./run_manager.sh [onvm-upf PATH]
    ```
3. **Run whole core network on the other terminal**

    (Make sure to run on root privilege)
    ```shell
    LL5gc$ sudo ./run_LLfree5gc.sh [onvm-free5gc3.0.5 PATH] [onvm-upf PATH]
    ```

## Test enviroment setup
* **<font color="ff0000">If you want to TestPaging, additional environment setting have to be done</font>**
* **<font color="ff0000">TestRegistration & TestN2Handover can skip this test enviroment setup</font>**

![](https://i.imgur.com/ErwJJzB.png)


(Below setup tutorial our enviroment for example)
#### **On Host 2**
1. Run the following command
```shell=
sudo ifconfig enp1s0f0 up
sudo ifconfig enp1s0f1 up
sudo ip a add 10.100.200.3/24 dev enp1s0f0
sudo ip a add 192.168.0.2/24 dev enp1s0f1
sudo arp -s 192.168.0.1 90:e2:ba:c2:f0:42       /* MAC address of enp1s0f0 */
sudo arp -s 10.100.200.1 90:e2:ba:c2:ec:da      /* MAC address of enp1s0f1 */
sudo sysctl -w net.ipv4.ip_forward=1
sudo systemctl stop ufw
```

2. Change the mac address of DN & AN for onvm-upf
```shell=
LL5gc$ cd onvm-upf/5gc/upf_u_complete/
LL5gc/onvm-upf/5gc/upf_u_complete$ vim upf_u.txt
``` 
```shell=
# DN MAC Address
0a:c1:b2:37:42:a0                               /* MAC address of enp6s0f1 */
# AN MAC Address
5c:3d:1d:aa:b1:43
```

3. Chang the kernal-upf config
```shell=
LL5gc$ cd kernal-free5gc3.0.5/NFs/upf/build/config/
LL5gc/kernal-free5gc3.0.5/NFs/upf/build/config$ vim upfcfg.yaml
``` 
```c
  # The IP list of the N3/N9 interfaces on this UPF
  # If there are multiple connection, set addr to 0.0.0.0 or list all the addresses
  gtpu:
    - addr: 10.100.200.3                   /* Here IP of enp1s0f0 */
    # [optional] gtpu.name
    # - name: upf.5gc.nctu.me
    # [optional] gtpu.ifname
    # - ifname: gtpif

  # The DNN list supported by UPF
  dnn_list:
    - dnn: internet # Data Network Name
      cidr: 60.60.0.0/16 # Classless Inter-Domain Routing for assigned IPv4 pool of UE
      # [optional] dnn_list[*].natifname
      # natifname: eth0
```

4. Change the DN IP address in python_client.py
``` shell
LL5gc$ vim ./test-script3.0.5/python_client.py
```
```python=
#!/usr/bin/env python3

import socket

HOST = '10.10.2.45'  # The server's hostname or IP address    /* IP of Host3 */
PORT = 65432        # The port used by the server
```



#### **On Host 3**
(Is free to choose the directory you want to put this repo)
1. Clone remote-executer
```
git clone https://github.com/nctu-ucr/remote-executor.git
```
2. Run the following command
```
ip address add 192.168.0.1 dev enp6s0f1
sudo ip route add 60.60.0.0/24 dev enp6s0f1
sudo arp -s 60.60.0.1 2c:f0:5d:91:45:91          /* MAC address of enp6s0f0 */
```
3. Change the DN IP address in python_client.py
``` shell
LL5gc$ vim ./test-script3.0.5/python_client.py
```
```python=
#!/usr/bin/env python3

import socket, os

HOST = '10.10.2.45'  # Standard loopback interface address     /* IP of Host3 */
PORT = 65432        # Port to listen on (non-privileged ports are > 1023)
```
    
## Testing
### Kernal free5GC
1. **Run up kernal free5GC**

2.  **Run the test script, then enter one of the test case**
    ```shell=
    LL5gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    ```
    
### LL5GC
1. **Run up LL5GC**

2.  **Run the test script, then enter one of the test case**
    ```shell=
    LL5gc$ ./test.sh
    Select the test type: TestRegistration | TestN2Handover | TestPaging:
    ```



## Troublesome
### Terminate onvm manager manualy (optional)
1. Find the PID of onvm manager
   ```console
   ps -aux |  grep onvm
   ```
2. Kill the PID of onvm manager (may have more than one process)
   ```console
   sudo kill -9 <pid>
   ```
### Clear core network process and database
1. Some time test procedue may fail, clear out mogoDB then try it again.
   ```console
    mongo --eval "db.dropDatabase()" free5gc
   ```
2. Make sure to terminate all NFs
   ```console
   sudo ./force_kill.sh
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
