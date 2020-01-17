---
id: seleniumgridbrowsers
title: Setting up a Selenium Grid hub
---

# How to setup a Selenium Grid hub
The Selenium grid can be run manually or as a docker container.

<!-- vscode-markdown-toc -->
* 1. [Prerequisites](#Prerequisites)
* 2. [Setting up the Selenium Grid hub manually](#SettinguptheSeleniumGridhubmanually)
	* 2.1. [Mac/Linux**](#MacLinux)
	* 2.2. [Windows](#Windows)
* 3. [Settings up the Selenium Grid hub with Docker](#SettingsuptheSeleniumGridhubwithDocker)
	* 3.1. [Prerequisites](#Prerequisites-1)
	* 3.2. [Setup](#Setup)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='Prerequisites'></a>Prerequisites

- Have physical or virtual machine ready to act as a grid hub
  - Install Java on the machine

---

##  2. <a name='SettinguptheSeleniumGridhubmanually'></a>Setting up the Selenium Grid hub manually

###  2.1. <a name='MacLinux'></a>Mac/Linux**

- Create `~/selenium`
- Download the selenium standalone to `~/selenium` from [https://selenium.dev/downloads/](https://selenium.dev/downloads/)

Create `~/selenium/start-grid-hub.sh` with the following content:
```bash
#!/bin/bash

java -jar selenium-server-standalone-3.141.59.jar -role hub > /dev/null 2>&1 &
```
Update selenium version to match.

Make it executable by doing the following in a terminal: `chmod +x ~/selenium/start-grid-hub.sh`.


Add cronjob to make sure it registers every boot:
```shell
crontab -e
# press key i and paste the following
@reboot bash -l -c $HOME/selenium/start-grid-hub.sh
# press escape
# press :
# type wq
# press enter
```

###  2.2. <a name='Windows'></a>Windows

Create `C:\selenium`

Download the selenium standalone to `C:\selenium` from [https://selenium.dev/downloads/](https://selenium.dev/downloads/)

Create `C:\selenium\start-grid-hub.bat` with the following content:
```batch
java -jar "C:\selenium\selenium-server-standalone-3.141.59.jar" -role hub
```
Update selenium version to match.

Att to startup items to make sure it registers every boot:
Add new .bat-file to autostart by pressing `[Win]+r` and type `shell:startup`, then add shortcut to `C:\selenium\start-grid-hub.bat`.


---

##  3. <a name='SettingsuptheSeleniumGridhubwithDocker'></a>Settings up the Selenium Grid hub with Docker

###  3.1. <a name='Prerequisites-1'></a>Prerequisites

- Have Docker CE installed (no need for Java)
  - Mac: [https://download.docker.com/mac/stable/Docker.dmg](https://download.docker.com/mac/stable/Docker.dmg)
  - Windows: [https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe](https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe)
    - Install with Linux subsystem
  - Linux: [https://docs.docker.com/install/linux/docker-ce/centos/](https://docs.docker.com/install/linux/docker-ce/centos/

###  3.2. <a name='Setup'></a>Setup

Create `~/selenium/docker-compose.yaml` for Mac/Linux, or `C:\selenium\docker-compose.yaml` for Windows, with the following content:
```yaml
version: '3.7'
services:
  chrome:
    image: selenium/node-chrome:3.141.59-gold
    depends_on:
      - hub
    deploy:
      replicas: 1
      update_config:
        order: start-first
      restart_policy:
        condition: on-failure
    environment:
      HUB_HOST: hub
      SCREEN_WIDTH: 1600
      SCREEN_HEIGHT: 1024
      NODE_MAX_INSTANCES: 5
      http_proxy: http://proxy-se-uan.ddc.teliasonera.net:8080
      https_proxy: http://proxy-se-uan.ddc.teliasonera.net:8080
    entrypoint: bash -c 'SE_OPTS="-host $$HOSTNAME" /opt/bin/entry_point.sh'
    networks:
      - selenium

  firefox:
    image: selenium/node-firefox:3.141.59-gold
    depends_on:
      - hub
    deploy:
      replicas: 1
      update_config:
        order: start-first
      restart_policy:
        condition: on-failure
    environment:
      HUB_HOST: hub
      SCREEN_WIDTH: 1600
      SCREEN_HEIGHT: 1024
      GRID_BROWSER_TIMEOUT: 60
      NODE_MAX_INSTANCES: 5
      http_proxy: http://proxy-se-uan.ddc.teliasonera.net:8080
      https_proxy: http://proxy-se-uan.ddc.teliasonera.net:8080
    entrypoint: bash -c 'SE_OPTS="-host $$HOSTNAME" /opt/bin/entry_point.sh'
    networks:
      - selenium

  hub:
    image: selenium/hub:3.141.59-gold
    environment:
      GRID_MAX_SESSION: 16
      SE_OPTS: '-maxSession 16 -browserTimeout 45'
    ports:
      - 4444:4444
    networks:
      - selenium
    deploy:
      replicas: 1
      update_config:
        order: start-first
      restart_policy:
        condition: on-failure

networks:
  selenium:
```

Put Docker in swarm mode: `docker swarm init`

Enter selenium directory with a terminal window.

Start grid together with headless Chrome and Firefox: `docker stack deploy -c docker-compose.yaml selenium`

The grid and the browsers are run as Docker services and will start automatically on every reboot.
