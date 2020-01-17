#!/bin/bash

java -jar selenium-server-standalone-3.141.59.jar -role node -nodeConfig ~/selenium/safari.json > /dev/null 2>&1 &
