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

```sh
source ./build_L25GC.sh 2>&1 | tee error_LL5GC.txt
```

### Kernel free5GC
This script will install and build the following environment:
- Go
- free5GCv3.0.5

```sh
git checkout kernel
source ./build_free5GC.sh 2>&1 | tee error_free5GC.txt
```

## Runing
### Kernal free5GC
1. **Change to directory of kernal-free5gc3.0.5**
    ```
    cd kernel-free5gc3.0.5
    ```
2.  **Run the core network**
    ```
    ./run.sh
    ```
### LL5GC
1. **First, we have to change the mac address of DN & AN**
    ```
    cd onvm-upf/5gc/upf_u_complete/
    vim upf_u.txt
    ```
    Change two MAC Address base on your own enviroment setup. 
    ```
    # DN MAC Address
    0a:c1:b2:37:42:a0
    # AN MAC Address
    5c:3d:1d:aa:b1:43
    ```
    
3. **Setting up DPDK manually**

    (Change back to directory of LL5gc)
    ```
    ./onvm-upf/dpdk/usertools/dpdk-setup.sh
    ```

    * Press [38] to compile x86_64-native-linuxapp-gcc version
    * Press [45] to install igb_uio driver for Intel NICs
    * Press [49] to setup 1024 2MB hugepages
    * Press [51] to register the Ethernet ports
    * Press [62] to quit the tool

    (After these steps, dpdk should be set up)

4. **Run openNetVM manager first**
    ```
    ./run_manager.sh [onvm-upf PATH]
    ```
5. **Run whole core network on the other terminal**

    (Make sure to run on root privilege)
    ```
    sudo ./run_LLfree5gc.sh [onvm-free5gc3.0.5 PATH] [onvm-upf PATH]
    ```

## Terminate onvm manager manualy (optional)
1. Find the PID of onvm manager
   ```
   ps -aux |  grep onvm
   ```
2. Kill the PID of onvm manager (may have more than one process)
   ```
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
