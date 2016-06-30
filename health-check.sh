#!/bin/bash
while true; do
sleep 10
curl -sI --connect-timeout 3 -m 3 http://localhost:3000/ping | head -n1 | egrep -i "(20[0-9]|30[0-9])" > /dev/null
if [ "$?" != "0" ]; then
 pidof node | xargs kill 
fi
done
