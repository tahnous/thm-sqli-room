# Blind SQLi
 Solve task 7 of TryHackMe SQL injection room

### Getting started

Install dependencies:
```bash
sudo apt install libnamespace-clean-perl
$ cpan  Selenium::Remote::Driver
```
Download Selenium Server:
```bash
$ wget https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.30.0/selenium-server-4.30.0.jar
```
Install Chrome Webdriver:
```bash
$ wget https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip
$ unzip chromedriver_linux64.zip
sudo chown root:root chromedriver
sudo chmod 755 chromedriver
sudo mv chromedriver /usr/bin/
```

### Usage

Start Selenium server:
```bash
java -Dwebdriver.chrome.driver=/usr/bin/chromedriver -jar selenium-server-4.30.0.jar standalone:
```

```bash
./thm-sqli.pl --url Your-lab-url  --task 7
```
EX:
```bash 
./thm-sqli.pl --url https://10-10-179-201.p.thmlabs.com/level3  --task 7
```