#!/bin/sh

# make sure things are initialized
./etc/update.sh

# make sure sonar is online
echo "Making sure sonar is online!"
if [ $(curl -I -s https://sonar-lightblue.rhcloud.com/ -s | head -n1 | grep "HTTP[/][^ ]* 200" | wc -l) == "0" ]; then
    echo "Restarting sonar... (will take about a minute)"
    rhc app restart sonar -n lightblue
    echo -n "Waiting for web app to respond.."
    until [ $(curl -I -s https://sonar-lightblue.rhcloud.com/ -s | head -n1 | grep "HTTP[/][^ ]* 200" | wc -l) != "0" ]; do
        sleep 5
        echo -n "."
    done
    echo "done"
fi


# kill any previous port forward and the previous mark file  about its status
pkill -9 -f "rhc port-forward sonar [-]n lightblue"
rm -f rhc-port-forward-status

# forward ports from openshift (assumes current server is openshift online and you're a member of the lightblue namespace). A new mark file will eb created if the return value of the rhc command is different than 0
rhc port-forward sonar -n lightblue || echo $? > rhc-port-forward-status  &

# wait a bit for port forwarding to fire up
sleep 10

# if the file exists, log the error and exit 1
if [ -f "rhc-port-forward-status" ]
then
    echo "Error on rhc port-forward. Error code:"
    cat rhc-port-forward-status 
    exit 1
fi

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
