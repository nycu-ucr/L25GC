# !/bin/bash  
 
echo -n "Select the test type: TestRegistration | TestN2Handover | TestPaging: "
read test_type
node_name=$(hostname)

workdir=$(pwd)
echo "Working directory is $workdir"
cd $workdir

echo "Start to test $test_type on $node_name ..."
case $test_type in
    "TestRegistration")
    cd test-script3.0.5/
    echo "Copy test script to test directory"
    cp ./registration_test_experiment.go $workdir/kernel-free5gc3.0.5/test/registration_test.go
    echo "==== Start TestRegistration ===="
    cd $workdir/kernel-free5gc3.0.5/test/
    go test -v -vet=off -run TestRegistration -args noinit
    echo "===== End TestRegistration ====="
    ;;

    "TestN2Handover")
    cd test-script3.0.5/
    echo "Copy test script to test directory"
    cp ./registration_test_experiment.go $workdir/kernel-free5gc3.0.5/test/registration_test.go
    echo "===== Start TestN2Handover ====="
    cd $workdir/kernel-free5gc3.0.5/test/
    go test -v -vet=off -run TestN2Handover -args noinit
    echo "====== End TestN2Handover ======"
    ;;

    "TestPaging")
    cd test-script3.0.5/
    echo "Copy test script to test directory"
    cp ./registration_test_paging.go $workdir/kernel-free5gc3.0.5/test/registration_test.go
    echo "======= Start TestPaging ======="
    cd $workdir/kernel-free5gc3.0.5/test/
    go test -v -vet=off -run TestPaging -args noinit
    echo "======== End TestPaging ========"
    ;;

    *) echo 'Testing is terminated. Please select one of TestRegistration | TestN2Handover | TestPaging'
    ;;
esac
exit 0