#!/bin/sh

while true
do
  /var/tmp/msgqsnd
  sleep 2
  /var/tmp/msgqrcv
  sleep 5
done
