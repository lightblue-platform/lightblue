#!/bin/sh

# make sure things are initialized
git submodule update --init --recursive

# make sure latest source is pulled
git submodule foreach git pull origin master

# kill any previous port forward
pkill -9 -f "rhc port-forward sonar [-]n lightblue"

# forward ports from openshift (assumes current server is openshift online and you're a member of the lightblue namespace)
rhc port-forward sonar -n lightblue &

# wait a bit for port forwarding to fire up
sleep 10

# build and publish.. can take a long time
for repo in `ls -1d lightblue-*`;
do
    pushd $repo
    mvn clean install -Dmaven.test.failure.ignore=true  
    mvn -e -B sonar:sonar
    popd
done;

# cleanup port forwarding
pkill -9 -f "rhc port-forward sonar [-]n lightblue"
