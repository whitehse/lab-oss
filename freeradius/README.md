````
ip dns server-address 192.168.1.235
radius-server host teslyn.example.net auth-port 1812 acct-port 1813 default key passw0rd
````

````
aaa authentication web-server default local radius 
aaa authentication enable default local radius 
aaa authentication login default local radius 
aaa authentication login privilege-mode
aaa accounting exec default start-stop radius 
aaa accounting system default start-stop radius 
````

