---
id: seleniumgridbrowsers
title: Adding Browsers to Selenium grid
---

# How to pupulate Selenium Grid with webbrowsers

<!-- vscode-markdown-toc -->
* 1. [Prerequisites](#Prerequisites)
* 2. [Chrome and Firefox](#ChromeandFirefox)
	* 2.1. [Preparation](#Preparation)
* 3. [Safari](#Safari)
	* 3.1. [Preparation](#Preparation-1)
	* 3.2. [Enable webdriver support in Safari](#EnablewebdriversupportinSafari)
		* 3.2.1. [High Sierra and later:](#HighSierraandlater:)
		* 3.2.2. [Sierra and Earlier](#SierraandEarlier)
	* 3.3. [Setup Safari](#SetupSafari)
* 4. [Microsoft browsers on Windows 10](#MicrosoftbrowsersonWindows10)
	* 4.1. [Preparation](#Preparation-1)
	* 4.2. [Heads up!](#Headsup)
		* 4.2.1. [W3C Capabilities](#W3CCapabilities)
		* 4.2.2. [The `browserName` capability cant be changed](#ThebrowserNamecapabilitycantbechanged)
		* 4.2.3. [The 32bit Internet explorer webdriver is much faster than the 64bit webdriver](#The32bitInternetexplorerwebdriverismuchfasterthanthe64bitwebdriver)
	* 4.3. [Running Microsoft Edge Legacy & Chromium on the same machine](#RunningMicrosoftEdgeLegacyChromiumonthesamemachine)
		* 4.3.1. [Preparing the Side by side experience policy](#PreparingtheSidebysideexperiencepolicy)
	* 4.4. [Microsoft Edge Legacy browser](#MicrosoftEdgeLegacybrowser)
	* 4.5. [Microsoft Edge Chromium browser](#MicrosoftEdgeChromiumbrowser)
	* 4.6. [Microsoft Internet Explorer 11](#MicrosoftInternetExplorer11)
		* 4.6.1. [Fixes to make IE11 play nice with automated tests](#FixestomakeIE11playnicewithautomatedtests)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


##  1. <a name='Prerequisites'></a>Prerequisites

- Have existing Selenium Grid hub in place
- Have physical or virtual machines ready to act as grid nodes
  - Install Java on the machines

---

##  2. <a name='ChromeandFirefox'></a>Chrome and Firefox
Chrome and Firefox can easily be run as docker containers, but here is how to join them to a Selenium grid manually.

###  2.1. <a name='Preparation'></a>Preparation

**Mac/Linux**
- Create `~/selenium`
- Download the selenium standalone to `~/selenium` from [https://selenium.dev/downloads/](https://selenium.dev/downloads/)

**Windows**
- Create `C:\selenium`
- Download the selenium standalone to `C:\selenium` from [https://selenium.dev/downloads/](https://selenium.dev/downloads/)

**Both**
Downloaded Chrome selenium webdriver from: [https://chromedriver.storage.googleapis.com/index.html](https://chromedriver.storage.googleapis.com/index.html)
Unzip and place `chromedriver` in `~/selenium` for Mac/Linux, and `chromedriver.exe` in `C:\selenium` for Windows.

Downloaded Firefox selenium webdriver from: [https://github.com/mozilla/geckodriver/releases](https://github.com/mozilla/geckodriver/releases)
Unzip and place `geckodriver` in `~/selenium` for Mac/Linux, and `geckodriver.exe` in `C:\selenium` for Windows.

Create `~/selenium/chrome.json` for Mac/Linux, or `C:\selenium\chrome.json` for Windows, with the following content:
```json
{
  "capabilities":
  [
    {
      "browserName": "chrome",
      "platform": "macOS",
      "maxInstances": 5,
      "version": "79.0.3945.117",
      "seleniumProtocol": "WebDriver"
    }
  ],
  "port": 5556,
  "hub": "http://your-grid-url-here.com:4444",
  "maxSession": 5,
  "register": true,
  "registerCycle": 5000,
  "nodeStatusCheckTimeout": 5000,
  "nodePolling": 5000,
  "role": "node",
  "unregisterIfStillDownAfter": 10000,
  "downPollingLimit": 2,
  "debug": false,
  "servlets" : [],
  "withoutServlets": [],
  "custom": {}
}
```
Make sure to update `platform`, `version`, and `hubHost`.

Create `~/selenium/firefox.json` for Mac/Linux, or `c:\selenium\firefox.json` for Windows, with the following content:
```json
{
  "capabilities":
  [
    {
      "browserName": "firefox",
      "platform": "macOS",
      "maxInstances": 5,
      "version": "72.0.1",
      "seleniumProtocol": "WebDriver"
    }
  ],
  "port": 5557,
  "hub": "http://your-grid-url-here.com:4444",
  "maxSession": 5,
  "register": true,
  "registerCycle": 5000,
  "nodeStatusCheckTimeout": 5000,
  "nodePolling": 5000,
  "role": "node",
  "unregisterIfStillDownAfter": 10000,
  "downPollingLimit": 2,
  "debug": false,
  "servlets" : [],
  "withoutServlets": [],
  "custom": {}
}
```
Make sure to update `platform`, `version`, and `hubHost`.


**Mac/Linux**
Create `~/selenium/add-chrome-firefox-to-grid.sh` with the following content:
```bash
#!/bin/bash

java -Dwebdriver.gecko.driver=chromedriver -jar selenium-server-standalone-3.141.59.jar -role node -nodeConfig ~/selenium/chrome.json > /dev/null 2>&1 &
java -Dwebdriver.gecko.driver=geckodriver -jar selenium-server-standalone-3.141.59.jar -role node -nodeConfig ~/selenium/firefox.json > /dev/null 2>&1 &
```
Update selenium version to match.

Make it executable by doing the following in a terminal: `chmod +x ~/selenium/add-chrome-firefox-to-grid.sh`.

Add cronjob to make sure it registers every boot:
```shell
crontab -e
# press key i and paste the following
@reboot bash -l -c $HOME/selenium/add-chrome-firefox-to-grid.sh
# press escape
# press :
# type wq
# press enter
```

**Windows**
Create `C:\selenium\add-chrome-and-firefox-to-grid.bat` with the following content:
```batch
start "" java -Dwebdriver.gecko.driver="C:\selenium\chromedriver.exe" -jar "C:\selenium\selenium-server-standalone-3.141.59.jar" -role node -nodeConfig C:\selenium\chrome.json
start "" java -Dwebdriver.gecko.driver="C:\selenium\geckodriver.exe" -jar "C:\selenium\selenium-server-standalone-3.141.59.jar" -role node -nodeConfig C:\selenium\firefox.json
```
Update selenium version to match.

Att to startup items to make sure it registers every boot:
Add new .bat-file to autostart by pressing `[Win]+r` and type `shell:startup`, then add shortcut to `C:\selenium\add-chrome-and-firefox-to-grid.bat`.

---

##  3. <a name='Safari'></a>Safari

The Safari selenium webdriver is installed by default and is located at `/usr/bin/safaridriver`

###  3.1. <a name='Preparation-1'></a>Preparation

- Create `~/selenium`
- Download the selenium standalone to `~/selenium` from [https://selenium.dev/downloads/](https://selenium.dev/downloads/)

###  3.2. <a name='EnablewebdriversupportinSafari'></a>Enable webdriver support in Safari

####  3.2.1. <a name='HighSierraandlater:'></a>High Sierra and later:
Run `sudo safaridriver --enable` in a terminal once

####  3.2.2. <a name='SierraandEarlier'></a>Sierra and Earlier
- Go to `Safari - Preferences - Advanced`
- Enable `Show Develop menu in menubar`
- Open `Develop menu` in menu bar and click `Allow Remote Automation`
- Run safaridriver manually and Authorize it to launch by running `/usr/bin/safaridriver` in a terminal once and then follow the prompt

###  3.3. <a name='SetupSafari'></a>Setup Safari
Create `~/selenium/safari.json` with the following content:
```json
{
  "capabilities":
  [
    {
      "browserName": "safari",
      "platform": "macOS",
      "maxInstances": 5,
      "version": "13.0.4",
      "seleniumProtocol": "WebDriver"
    }
  ],
  "port": 5555,
  "hub": "http://your-grid-url-here.com:4444",
  "maxSession": 5,
  "register": true,
  "registerCycle": 5000,
  "nodeStatusCheckTimeout": 5000,
  "nodePolling": 5000,
  "role": "node",
  "unregisterIfStillDownAfter": 10000,
  "downPollingLimit": 2,
  "debug": false,
  "servlets" : [],
  "withoutServlets": [],
  "custom": {}
}
```

Create `~/selenium/add-safari-to-grid.sh` with the following content:
```bash
#!/bin/bash

java -jar selenium-server-standalone-3.141.59.jar -role node -nodeConfig ~/selenium/safari.json > /dev/null 2>&1 &
```
Update selenium version to match.


Make it executable by doing the following in a terminal: `chmod +x ~/selenium/add-safari-to-grid.sh`.


Add cronjob to make sure it registers every boot:
```shell
crontab -e
# press key i and paste the following
@reboot bash -l -c $HOME/selenium/add-safari-to-grid.sh
# press escape
# press :
# type wq
# press enter
```

---

##  4. <a name='MicrosoftbrowsersonWindows10'></a>Microsoft browsers on Windows 10

A single machine with good enough specs can host IE11, Edge Legacy & Edge Chromium at the same time.
We have 5 instances of each on a single machine (not Windows 10 home).

###  4.1. <a name='Preparation-1'></a>Preparation

- Create directory `C:\selenium`.
- Download the selenium standalone to to `C:\selenium` from [https://selenium.dev/downloads/](https://selenium.dev/downloads/)
  (Make sure its the same version as the grid)

---

###  4.2. <a name='Headsup'></a>Heads up!

####  4.2.1. <a name='W3CCapabilities'></a>W3C Capabilities
The selenium drivers for Microsoft browsers have strict W3C implementation. So only these capabilites are valid to differentiate between browsers:
https://www.w3.org/TR/webdriver/#capabilities
That means we cant use capabilites like `BrowserType` and the like to separate MS Edge browsers.

####  4.2.2. <a name='ThebrowserNamecapabilitycantbechanged'></a>The `browserName` capability cant be changed
The drivers are picky with the `browserName`, if they are changed from the values below, the browsers wont run the tests.
It is possible to change Edge Chromium to `browserName: MicrosoftEdge` together with a change from `chrome` to `edge` in the bat-file, but then it will be really hard for Selenium to differentiate between the Legacy and then Chromium version. Which means that sometimes, Chromium will snatch sessions from Legacy, since the Microsoft WebDriver (as of 2020-01-17) hits a java argument error on any attempt to use the capability `browserVersion`, no matter if using the actual browser version or anything else.

####  4.2.3. <a name='The32bitInternetexplorerwebdriverismuchfasterthanthe64bitwebdriver'></a>The 32bit Internet explorer webdriver is much faster than the 64bit webdriver
The `64bit` version of `IEDriverServer.exe` makes all tests run really slow. So use the `32bit` version even if the host OS is `64bit`.

---

###  4.3. <a name='RunningMicrosoftEdgeLegacyChromiumonthesamemachine'></a>Running Microsoft Edge Legacy & Chromium on the same machine

Microsoft started rolling out its new Edge client, that is based on Chromium, early 2020.
Although it might seem like Legacy chrome disappears, it does not. It does however require a policy change,
which is only possible on a Pro or Enterprise license.

If installing Chromium before the official update reaches the machine, make sure to do the policy update before the browser installation.
Otherwise uninstall it, fix policys, restart, and then install Microsoft Edge Chromium again.

####  4.3.1. <a name='PreparingtheSidebysideexperiencepolicy'></a>Preparing the Side by side experience policy

- Download Policy files from here [https://www.microsoft.com/en-us/edge/business/download](https://www.microsoft.com/en-us/edge/business/download)
- Extract the zip file from `MicrosoftEdgePolicyTemplates.cab`
- Extract files from `MicrosoftEdgePolicyTemplates.zip`
- Copy files from `MicrosoftEdgePolicyTemplates\Windows\admx` to `C:\Windows\PolicyDefinitions`
- Open `Edit group policy` (which is also called `Local Group Policy Editor`)
- Go to `Local Computer Policy - Computer Configuration - Administrative Templates - Microsoft Edge Update - Applications`
- Right click on `Allow Microsoft Edge Side by Side browser experience` and select `Edit`
- Select `Enabled` in the top left corner and Press `OK`
- Restart the machine
- Search for `edge` and start `Microsoft Edge Legacy` and verify that it starts

----

###  4.4. <a name='MicrosoftEdgeLegacybrowser'></a>Microsoft Edge Legacy browser

The Microsoft Edge Legacy browser selenium webdriver is a Windows optional feature.
Install it by going to `Settings - Apps - Optional Features - Add a feature` and select `Microsoft WebDriver`.

Create `C:\selenium\edge-legacy.json` with the following content:
```json
{
  "capabilities":
  [
    {
      "browserName": "MicrosoftEdge",
      "maxInstances": 5,
      "version": "Legacy",
      "platformName": "Windows",
      "seleniumProtocol": "WebDriver"
    }
  ],
  "port": 9510,
  "hub": "http://your-grid-url-here.com:4444",
  "cleanUpCycle": 2000,
  "timeout": 30000,
  "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
  "maxSession": 5,
  "register": true,
  "registerCycle": 5000,
  "unregisterIfStillDownAfter": 10000,
  "debug": false,
  "role": "node"
}
```
Make sure to update `hubHost` with correct url.


Create `C:\selenium\add-edge-legacy-to-grid.bat`
```
java -jar "C:\selenium\selenium-server-standalone-3.141.59.jar" -role node -nodeConfig "C:\selenium\edge-legacy.json"
```
Update selenium version to match.

Att to startup items to make sure it registers every boot:
Add new .bat-file to autostart by pressing `[Win]+r` and type `shell:startup`, then add shortcut to `C:\selenium\add-edge-legacy-to-grid.bat`.

---

###  4.5. <a name='MicrosoftEdgeChromiumbrowser'></a>Microsoft Edge Chromium browser

The Microsoft Edge Chromium selenium webdriver can be downloaded from [https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/).
Make sure to download the correct version that corresponds to the installed browser version.

Place `msedgedriver.exe` in `C:\selenium`.

Create `C:\selenium\edge-chromium.json` with the following content:
```json
{
  "capabilities":
  [
    {
      "browserName": "chrome",
      "maxInstances": 5,
      "version": "Microsoft Edge",
      "platformName": "Windows",
      "seleniumProtocol": "WebDriver"
    }
  ],
  "port": 9515,
  "hub": "http://your-grid-url-here.com:4444",
  "cleanUpCycle": 2000,
  "timeout": 30000,
  "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
  "maxSession": 5,
  "register": true,
  "registerCycle": 5000,
  "unregisterIfStillDownAfter": 10000,
  "debug": false,
  "role": "node"
}
```
Make sure to update `hubHost` with correct url.


Create `C:\selenium\add-edge-chromium-to-grid.bat`
```batch
java -Dwebdriver.chrome.driver="C:\selenium\msedgedriver.exe" -jar "C:\selenium\selenium-server-standalone-3.141.59.jar" -role node -nodeConfig "C:\selenium\edge-chromium.json"
```
Update selenium version to match.

Att to startup items to make sure it registers every boot:
Add new .bat-file to autostart by pressing `[Win]+r` and type `shell:startup`, then add shortcut to `C:\selenium\add-edge-chromium-to-grid.bat`.

---

###  4.6. <a name='MicrosoftInternetExplorer11'></a>Microsoft Internet Explorer 11

The Microsoft Internet Explorer 11 Selenium webdriver can be downloaded from [https://selenium-release.storage.googleapis.com/index.html](https://selenium-release.storage.googleapis.com/index.html).
Make sure to download the correct `IEDriverServer_win32` version by drilling down in the folders. Make sure to download the 32bit version rather than the 64bit since it is much faster and works just as well, even if the host OS is 64bit.

Place `IEDriverServer.exe` in `C:\selenium`.

Create `C:\selenium\ie11.json` with the following content:
```json
{
  "capabilities":
  [
    {
      "browserName": "internet explorer",
      "maxInstances": 5,
      "version": "11.592.18362.0",
      "platformName": "Windows",
      "seleniumProtocol": "WebDriver"
    }
  ],
  "port": 5555,
  "hub": "http://your-grid-url-here.com:4444",
  "cleanUpCycle": 2000,
  "timeout": 30000,
  "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
  "maxSession": 5,
  "register": true,
  "registerCycle": 5000,
  "unregisterIfStillDownAfter": 10000,
  "debug": false,
  "role": "node"
}
```
Make sure to update `hubHost` with correct url.


Create `C:\selenium\add-ie11-to-grid.bat`
```batch
java -Dwebdriver.internetexplorer.driver="C:\selenium\IEDriverServer.exe" -jar "C:\selenium\selenium-server-standalone-3.141.59.jar" -role node -nodeConfig "C:\selenium\ie11.json"
```
Update selenium version to match

Att to startup items to make sure it registers every boot:
Add new .bat-file to autostart by pressing `[Win]+r` and type `shell:startup`, then add shortcut to `C:\selenium\add-edge-chromium-to-grid.bat`.


####  4.6.1. <a name='FixestomakeIE11playnicewithautomatedtests'></a>Fixes to make IE11 play nice with automated tests

**Avoid "Several add-ons are ready for use" prompt**
- Open `Edit group policy` (which is also called `Local Group Policy Editor`)
- Go to `Local Computer Policy - Computer Configuration - Administrative Templates - Windows Components - Internet Explorer`
- Right click on `Automatically enable newly installed add-ons` and select `Edit`
- Select `Enabled` in the top left corner and Press `OK`
- Restart the machine

**IE11 settings for less trouble when running tests**
- Open IE11 as Administrator
- Dont use Recommended Settings (if the popup shows up)
- Goto `Settings - Internet Options - Security`
  - For each of the zones `Internet`, `Local internet` and `Trusted sites`
  - Uncheck `Enable Protected Mode` so that it is disabled
  - Click `Custom level...` scroll down slightly further than half way and find and enable `Display mixed content`
- Goto `Settings - Manage Add-ons - Toolbars and Extentions`
  - Right click both `Java(tm) Plugin SSV Helper` and click `Disable`
- Close IE11

**Make sure the webdriver can maintain connection to IE11**
- Open regedit by pressing `[Win]+r` and typing `regedit`
- If OS is 32bit: goto `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE`
- If OS is 64bit: goto `HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE`
- Right click on the right area, select new and DWORD (32-bit) Value
- Name it `iexplore.exe` and leave value at 0
- Restart the machine

For more information, checkout [https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver#required-configuration](https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver#required-configuration)

---

# How to run tests with these configurations

Here are example `capabilites` to run tests on the browsers above.
The `goog:chromeOptions` handles annoying popups and notifications.

Add the following in `wdio.conf.js` under `capabilities`
```javascript
...
  capabilities: [

    {
      maxInstances: 1,
      browserName: 'chrome',
      "goog:chromeOptions": {
        prefs: {
          'profile.managed_default_content_settings.popups' : 2,
          'profile.managed_default_content_settings.notifications' : 2,
        }
      },
    },

    {
      maxInstances: 1,
      browserName: 'firefox',
    },

    {
      maxInstances: 1,
      browserName: 'safari',
    },

    {
      maxInstances: 1,
      browserName: 'chrome',
      browserVersion: 'Microsoft Edge',
      "goog:chromeOptions": {
        prefs: {
          'profile.managed_default_content_settings.popups' : 2,
          'profile.managed_default_content_settings.notifications' : 2,
        }
      },
    },

    {
      maxInstances: 1,
      browserName: 'MicrosoftEdge',
    },

    {
      maxInstances: 1,
      browserName: 'internet explorer',
    },
  ],
...
```
