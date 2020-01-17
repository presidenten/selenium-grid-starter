#!/bin/bash

java -Dwebdriver.gecko.driver=chromedriver -jar selenium-server-standalone-3.141.59.jar -role node -nodeConfig ~/selenium/chrome.json > /dev/null 2>&1 &
java -Dwebdriver.gecko.driver=geckodriver -jar selenium-server-standalone-3.141.59.jar -role node -nodeConfig ~/selenium/firefox.json > /dev/null 2>&1 &
