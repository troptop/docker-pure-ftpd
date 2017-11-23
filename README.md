# Docker-pure-ftpd
Setup your pure-ftpd quickly
This docker allows you to customize your pure-ftpd with 2 different modes
  - FILEMODE=TRUE -> using files configuration
  - FILEMODE=FALSE -> using ENV configuration
  - FILEMODE=HYBRID -> using files overriding by ENV configuration

This docker container uses pure-ftpd-wrapper. you can find the parameters allowed here (http://www.linuxcertif.com/man/8/pure-ftpd-wrapper/)  

# FILEMODE = TRUE
in the filemode=true (by default), you have to setup the pure-ftpd directory configuration as :
```sh
# ls /etc/pure-ftpd/*
/etc/pure-ftpd/pureftpd-dir-aliases  /etc/pure-ftpd/pureftpd.pdb

/etc/pure-ftpd/auth:
50PureDB  65unix  70pam

/etc/pure-ftpd/conf:
AltLog	AnonymousOnly  FSCharset  ForcePassiveIP  MinUID  NoAnonymous  PAMAuthentication  PassivePortRange  PureDB  TLS  TLSCipherSuite  UnixAuthentication

/etc/pure-ftpd/db:

/etc/pure-ftpd/passwd:
pureftpd.passwd

/etc/pure-ftpd/ssl:
pure-ftpd.pem
```
Configuration Files Content Example :
```sh
#cat /etc/pure-ftpd/conf/*
clf:/var/log/pure-ftpd/transfer.log
no
UTF-8
192.168.1.10
1000
no
yes
40000 40006
/etc/pure-ftpd/pureftpd.pdb
2
ALL:!aNULL:!SSLv3
yes
```

Authenfication file :
the files in /etc/pure-ftpd/auth have to be symbolic links from /etc/pure-ftpd/conf 
```sh
#ls -l /etc/pure-ftpd/auth/
total 12
lrwxrwxrwx 1 root root 14 Nov  7 15:06 50PureDB -> ../conf/PureDB
lrwxrwxrwx 1 root root 26 Nov  7 15:04 65unix -> ../conf/UnixAuthentication
lrwxrwxrwx 1 root root 25 Nov  7 15:04 70pam -> ../conf/PAMAuthentication
```

Please refer to http://www.linuxcertif.com/man/8/pure-ftpd-wrapper/ to know the parameters and content.

Then execute docker :
  - ftp active mode 
```sh
docker run -d --name=ftpserver -p20-21:20-21 troptop/docker-pure-ftp
or
docker run -d --name=ftpserver -e FILEMODE=TRUE -p20-21:20-21 troptop/docker-pure-ftp
```
  - ftp passive mode 
  you have to setup the PassivePortRange (with the docker port that you open - 40000 to 40006 in the following example) and ForcePassiveIP files
```sh
docker run -d --name=ftpserver -p21:21 -p40000-40006:40000-40006 troptop/docker-pure-ftp
or
docker run -d --name=ftpserver -e FILEMODE=TRUE -p21:21 -p40000-40006:40000-40006 troptop/docker-pure-ftp
```

# FILEMODE = FALSE
In the filemode=false, you have to setup the pure-ftpd  using the ENV variable in the docker run docker command line :

run the docker container with ENV variable associated to the pure-ftpd conf in http://www.linuxcertif.com/man/8/pure-ftpd-wrapper/
Each variable will create a config file related to its parameters
example :
- CHROOTEVERYONE will create the file /etc/pure-ftpd/conf/ChrootEveryone with the value yes writing into it.
- VERBOSELOG will create the file /etc/pure-ftpd/conf/Verboselog with the value yes writing into it.
- PUREDB will create the file /etc/pure-ftpd/conf/PureDB with the value "/etc/pure-ftpd/pureftpd-pdb" (PureDB path for virtual user configuration) writing into it.
- ...
 
Example of using PAM configuration
```sh
docker run  -d --name=ftpserver -p20-21:20-21 -e CHROOTEVERYONE=yes -e CREATEHOMEDIR=yes -e NOANONYMOUS=yes -e NOCHMOD=yes -e PAMAUTHENTICATION=yes -e UNIXAUTHENTICATION=no -e VERBOSELOG=yes -e FILEMODE=false  troptop/docker-pure-ftp
 ```
 
 IF you want to use Virtual users, you have to configure PUREDB and PASSWDPATH ENVs
 Example :
 ```sh
docker run  -d --name=ftpserver -p20-21:20-21 -e CHROOTEVERYONE=yes -e CREATEHOMEDIR=yes -e NOANONYMOUS=yes -e NOCHMOD=yes -e PAMAUTHENTICATION=no -e UNIXAUTHENTICATION=no -e VERBOSELOG=yes -e FILEMODE=false -e PUREDB='/etc/pure-ftpd/pureftpd.pdb' -e PASSWDPATH='/etc/pure-ftpd/passwd' -v /my/path/passwd:/etc/pure-ftpd/passwd /troptop/docker-pure-ftp
 ```
 
 The passwd file looks like :
 <account>:<password>:<uid>:<gid>:<gecos>:<home directory>:<upload
bandwidth>:<download bandwidth>:<upload ratio>:<download ratio>:<max number
of connections>:<files quota>:<size quota>:<authorized local IPs>:<refused
local IPs>:<authorized client IPs>:<refused client IPs>:<time
restrictions>

More information in https://download.pureftpd.org/pure-ftpd/doc/README.Virtual-Users

# FILEMODE = HYBRID
in the filemode=hybrid , you can to setup the pure-ftpd directory configuration (as the FILEMODE=TRUE Section) and override this setup with the environment variable (as the FILEMODE=FALSE Section) :
```sh
# ls /etc/pure-ftpd/*
/etc/pure-ftpd/pureftpd-dir-aliases  /etc/pure-ftpd/pureftpd.pdb

/etc/pure-ftpd/auth:
50PureDB  65unix  70pam

/etc/pure-ftpd/conf:
AltLog	AnonymousOnly  FSCharset  ForcePassiveIP  MinUID  NoAnonymous  PAMAuthentication  PassivePortRange  PureDB  TLS  TLSCipherSuite  UnixAuthentication

/etc/pure-ftpd/db:

/etc/pure-ftpd/passwd:
pureftpd.passwd

/etc/pure-ftpd/ssl:
pure-ftpd.pem
```
Configuration Files Content Example :
```sh
#cat /etc/pure-ftpd/conf/*
clf:/var/log/pure-ftpd/transfer.log
no
UTF-8
192.168.1.10
1000
no
yes
40000 40006
/etc/pure-ftpd/pureftpd.pdb
2
ALL:!aNULL:!SSLv3
yes
```

Then execute docker :

  - ftp passive mode 
  you have to setup the PassivePortRange (with the docker port that you open - 40000 to 40006 in the following example) and ForcePassiveIP files
```sh
docker run -d --name=ftpserver -p21:21 -p40000-40006:40000-40006 -e CHROOTEVERYONE=yes -e CREATEHOMEDIR=yes -e NOANONYMOUS=yes -e NOCHMOD=yes -e PAMAUTHENTICATION=no -e UNIXAUTHENTICATION=no -e VERBOSELOG=yes -e FILEMODE=hybrid troptop/docker-pure-ftp
```

This command will take your configuration files as default setup, and change the content of these file with the Environment Variable.
The effective configuration will be setup with the Environment Variable, but the parameter that does not exist in the docker command line will be take with the configuration file.

ENVIRONMENT VARIABLE SETUP : 
- CHROOTEVERYONE=yes 
- CREATEHOMEDIR=yes 
- NOANONYMOUS=yes 
- NOCHMOD=yes 
- PAMAUTHENTICATION=no 
- UNIXAUTHENTICATION=no 
- VERBOSELOG=yes

FILE SETUP :
- AltLog=clf:/var/log/pure-ftpd/transfer.log
- AnonymousOnly=no
- FSCharset=UTF-8
- ForcePassiveIP=192.168.1.10
- MinUID=1000
- NoAnonymous=no
- PAMAuthentication=yes
- PassivePortRange=40000 40006
- PureDB=/etc/pure-ftpd/pureftpd.pdb
- TLS=2
- TLSCipherSuite=ALL:!aNULL:!SSLv3
- UnixAuthentication=yes

FINAL SETUP :
- CHROOTEVERYONE=yes 
- CREATEHOMEDIR=yes 
- NOANONYMOUS=yes (was NoAnonymous=No because of the file  ut the Environment Variable override the file value)
- NOCHMOD=yes 
- PAMAUTHENTICATION=no (was PAMAuthentication=yes because of the file but the Environment Variable override the file value)
- UNIXAUTHENTICATION=no (was UnixAuthentication=yes because of the file but the Environment Variable override the file value)
- VERBOSELOG=yes
- AltLog=clf:/var/log/pure-ftpd/transfer.log
- AnonymousOnly=no
- FSCharset=UTF-8
- ForcePassiveIP=192.168.1.10
- MinUID=1000
- PassivePortRange=40000 40006
- PureDB=/etc/pure-ftpd/pureftpd.pdb
- TLS=2
- TLSCipherSuite=ALL:!aNULL:!SSLv3


# TLS
To enable TLS, you have to specify the parameter TLS and add a pem file to /etc/ssl/private/pure-ftpd.pem

- TLS=0 (default) disables SSL/TLS security mechanisms.
- TLS=1 Accept both normal sessions and SSL/TLS ones.
- TLS=2 refuses connections that aren't using SSL/TLS security mechanisms, including anonymous ones.
- TLS=3 refuses connections that aren't using SSL/TLS security mechanisms, and refuse cleartext data channels as well.
```sh
#openssl req -x509 -nodes -newkey rsa:2048 -sha256 -keyout   /EFS/DOCKER/FTPS/ssl/pure-ftpd.pem -out /EFS/DOCKER/FTPS/ssl/pure-ftpd.pem
```
Then Execute Docker with :
- Active mode
```sh
docker run -d --name=ftpserver -p20-21:20-21 -e FILEMODE=false ... -v /my/path/pure-ftpd.pem:/etc/ssl/private/pure-ftpd.pem   -e TLS=2  troptop/docker-pure-ftpd
```
- Passive mode
```sh
docker run -d --name=ftpserver -p21:21 -p40000-40006:40000-40006 -e PASSIVEPORTRANGE="40000 40006" -e FORCEPASSIVEIP="yourIP" -e FILEMODE=false ... -v /my/path/pure-ftpd.pem:/etc/ssl/private/pure-ftpd.pem -e TLS=2  troptop/docker-pure-ftpd
```

# Volume:
- /mnt/ftpdir will be the host ftp directory
- passwd file will contain "ftpuser:passord:10001:10001::/home/ftpuser"
```sh
docker run  -d --name=ftpserver -p20-21:20-21 -e CREATEHOMEDIR=yes  -e FILEMODE=false -e TLS=2 -e PUREDB='/etc/pure-ftpd/pureftpd.pdb' -e PASSWDPATH='/etc/pure-ftpd/passwd' -v /my/path/passwd:/etc/pure-ftpd/passwd -v /mnt/ftpdir:/home/ftpuser /troptop/docker-pure-ftp
```
 
# Logs:
You can find the logs in /var/log/pure-ftpd/pure-ftpd.log


 
 
 
 
