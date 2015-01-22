#!/bin/sh

# make sure things are initialized
./update.sh

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
