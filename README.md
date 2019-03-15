# Install and configure salt-master
## ==============================================

## Check first
```
https://repo.saltstack.com/#bootstrap
```

# Installation

## BOOTSTRAP - MULTI-PALTFORM

### Install using wget

#### Using wget to install your distribution's stable packages
```
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh
```

#### Installing a specific version from git using wget
```
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -P git v2016.11.5
```

### Install using curl

### On the Salt master

#### Run these commands on the system that you want to use as the central management point
```
curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P -M
```

Your Salt master can manage itself, so a Salt minion is installed along with the Salt master. If you do not want to install the minion, also pass the -N option.

### On each Salt minion

#### Run these commands on each system that you want to manage using Salt.
```
curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P
```

## Fedora
#### Packages are available in the standard Fedora repositories. Install the salt-minion, salt-master, or other Salt components:
```
sudo dnf install -y salt-master \
salt-minion \
salt-ssh \
salt-syndic \
salt-cloud \
salt-api
```

## Redhat / CentOS 7 

#### Installs the latest release. Updating installs the latest release even if it is a new major version.

#### Run the following commands to install the SaltStack repository and key
```
sudo yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm 
sudo yum clean expire-cache
```

#### Install the salt-minion, salt-master, or other Salt components:
```
sudo yum install -y salt-master \
salt-minion \
salt-ssh \
salt-syndic \
salt-cloud \
salt-api
```

#### (Upgrade only) Restart all upgraded services, for example
```
sudo systemctl restart salt-minion
```

## Ubuntu
#### Ubuntu 18 (bionic)

#### Installs the latest release. Updating installs the latest release even if it is a new major version.

#### Run the following command to import the SaltStack repository key:
```
wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
```
#### Save the following line to /etc/apt/sources.list.d/saltstack.list:
```
sudo echo "deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest bionic main" >> /etc/apt/sources.list.d/saltstack.list
```
#### Run 
```
sudo apt-get update
```
#### Install the salt-minion, salt-master, or other Salt components:
```
sudo apt-get install -y salt-master \
salt-minion \
salt-ssh \
salt-syndic \
salt-cloud \
salt-api
```

#### (Upgrade only) Restart all upgraded services, for example:
```
sudo systemctl restart salt-minion
```

## Other distros
https://docs.saltstack.com/en/latest/topics/installation/index.html#platform-specific-installation-instructions



# Configuring Salt
## ==============================================

Salt configuration is very simple. The default configuration for the master will work for most installations and the only requirement for setting up a minion is to set the location of the master in the minion configuration file.

The configuration files will be installed to /etc/salt and are named after the respective components, /etc/salt/master, and /etc/salt/minion.

### Master Configuration

By default the Salt master listens on ports 4505 and 4506 on all interfaces (0.0.0.0). To bind Salt to a specific IP, redefine the "interface" directive in the master configuration file, typically /etc/salt/master, as follows:
```
- #interface: 0.0.0.0
+ interface: 172.16.2.101
```
After updating the configuration file, restart the Salt master. See the master configuration reference for more details about other configurable options.
```
sudo systemctl restart salt-master
```
### Minion Configuration

Although there are many Salt Minion configuration options, configuring a Salt Minion is very simple. By default a Salt Minion will try to connect to the DNS name "salt"; if the Minion is able to resolve that name correctly, no configuration is needed.

If the DNS name "salt" does not resolve to point to the correct location of the Master, redefine the "master" directive in the minion configuration file, typically /etc/salt/minion, as follows:

```
- #master: salt
+ master: 172.16.2.101
or 
+ master: salt-master
```

**NOTE:** Please check your **salt-master** ip address with some of tools that are available on your distribtution, probably it will be different than one I am using in this example. 
I got question in some of previuus version of course, where students have issues during configuration/comunication between salt-master and salt-minion because they actualy used copy/paste of ip from
this tutorial. 

After updating the configuration file, restart the Salt minion. See the minion configuration reference for more details about other configurable options.
```
sudo systemctl restart salt-minion
```

### Having trouble?

The simplest way to troubleshoot Salt is to run the master and minion in the foreground with log level set to debug:
```
salt-master --log-level=debug
```
For information on salt's logging system please see the logging document.

### Run as an unprivileged (non-root) user

To run Salt as another user, set the user parameter in the master config file.

Additionally, ownership, and permissions need to be set such that the desired user can read from and write to the following directories (and their subdirectories, where applicable):
```
    /etc/salt
    /var/cache/salt
    /var/log/salt
    /var/run/salt
```
More information about running salt as a non-privileged user can be found here.
https://docs.saltstack.com/en/latest/ref/configuration/nonroot.html#configuration-non-root-user

There is also a full troubleshooting guide available.
https://docs.saltstack.com/en/latest/topics/troubleshooting/index.html#troubleshooting

### Key Identity

Salt provides commands to validate the identity of your Salt master and Salt minions before the initial key exchange. Validating key identity helps avoid inadvertently connecting to the wrong Salt master, and helps prevent a potential MiTM attack when establishing the initial connection.
Master Key Fingerprint

Print the master key fingerprint by running the following command on the Salt master:
```
salt-key -F master
```
Copy the master.pub fingerprint from the Local Keys section, and then set this value as the master_finger in the minion configuration file. Save the configuration file and then restart the Salt minion.
Minion Key Fingerprint

Run the following command on each Salt minion to view the minion key fingerprint:
```
salt-call --local key.finger
```
Compare this value to the value that is displayed when you run the salt-key --finger <MINION_ID> command on the Salt master.

### Key Management

Salt uses AES encryption for all communication between the Master and the Minion. This ensures that the commands sent to the Minions cannot be tampered with, and that communication between Master and Minion is authenticated through trusted, accepted keys.

Before commands can be sent to a Minion, its key must be accepted on the Master. Run the salt-key command to list the keys known to the Salt Master:

```
[mc@salt-master ~]$ salt-key -L
Accepted Keys:
Denied Keys:
Unaccepted Keys:
centos-srv-salt-minion-01.home.lab
ubuntu-srv-salt-minion-02.home.lab
Rejected Keys:
```
This example shows that the Salt Master is aware of four Minions, but none of the keys has been accepted. To accept the keys and allow the Minions to be controlled by the Master, again use the salt-key command:

```
[mc@salt-master ~]$ salt-key -L
Accepted Keys:
centos-srv-salt-minion-01.home.lab
ubuntu-srv-salt-minion-02.home.lab
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

The salt-key command allows for signing keys individually or in bulk. The example above, using -A bulk-accepts all pending keys. To accept keys individually use the lowercase of the same option, -a keyname.

See also

salt-key manpage
https://docs.saltstack.com/en/latest/ref/cli/salt-key.html#salt-key


# Basic commands concept

### Sending Commands

Communication between the Master and a Minion may be verified by running the test.ping command:

```
[mc@salt-master ~]$ salt '*' test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
centos-srv-salt-minion-01.home.lab:
    True
```

```
[mc@salt-master ~]$ salt '*' cmd.run 'ls -la /home/mc'
ubuntu-srv-salt-minion-02.home.lab:
    total 40
    drwxr-xr-x 5 mc   mc   4096 Feb 28 18:07 .
    drwxr-xr-x 3 root root 4096 Feb 24 20:19 ..
    -rw------- 1 mc   mc    556 Feb 28 17:42 .bash_history
    -rw-r--r-- 1 mc   mc    220 Apr  4  2018 .bash_logout
    -rw-r--r-- 1 mc   mc   3771 Apr  4  2018 .bashrc
    drwx------ 2 mc   mc   4096 Feb 24 20:21 .cache
    drwx------ 3 mc   mc   4096 Feb 24 20:21 .gnupg
    -rw-r--r-- 1 mc   mc    807 Apr  4  2018 .profile
    drwx------ 2 mc   mc   4096 Feb 28 17:42 .ssh
    -rw-r--r-- 1 mc   mc      0 Feb 24 20:33 .sudo_as_admin_successful
    -rw------- 1 root root 3027 Feb 28 18:07 .viminfo
centos-srv-salt-minion-01.home.lab:
    total 20
    drwx------. 3 mc   mc   111 Feb 28 13:16 .
    drwxr-xr-x. 3 root root  16 Feb 24 13:34 ..
    -rw-------. 1 mc   mc    25 Feb 28 12:41 .bash_history
    -rw-r--r--. 1 mc   mc    18 Oct 30 13:07 .bash_logout
    -rw-r--r--. 1 mc   mc   193 Oct 30 13:07 .bash_profile
    -rw-r--r--. 1 mc   mc   231 Oct 30 13:07 .bashrc
    drwx------. 2 mc   mc    29 Feb 28 12:40 .ssh
    -rw-------. 1 mc   mc   512 Feb 28 13:16 .viminfo
```

```
[mc@salt-master ~]$ salt '*' pkg.install vim
centos-srv-salt-minion-01.home.lab:
    ----------
    vim-enhanced:
        ----------
        new:
            2:7.4.160-5.el7
        old:
ubuntu-srv-salt-minion-02.home.lab:
    ----------
    vim:
        ----------
        new:
            2:8.0.1453-1ubuntu1
        old:
```
```
[mc@salt-master ~]$ salt '*' pkg.remove vim
centos-srv-salt-minion-01.home.lab:
    ----------
ubuntu-srv-salt-minion-02.home.lab:
    ----------
    vim:
        ----------
        new:
        old:
            2:8.0.1453-1ubuntu1
[mc@salt-master ~]$ salt '*' pkg.remove vim-enhanced
ubuntu-srv-salt-minion-02.home.lab:
    ----------
centos-srv-salt-minion-01.home.lab:
    ----------
    vim-enhanced:
        ----------
        new:
        old:
            2:7.4.160-5.el7
```
```
[mc@centos-srv-salt-minion-01 ~]$ sudo salt-call test.ping
local:
    True
[mc@centos-srv-salt-minion-01 ~]$ sudo salt-call pkg.install vim
local:
    ----------
    vim-enhanced:
        ----------
        new:
            2:7.4.160-5.el7
        old:
```
```
mc@ubuntu-srv-salt-minion-02:~$ sudo salt-call test.ping
local:
    True
mc@ubuntu-srv-salt-minion-02:~$ sudo salt-call pkg.install vim
local:
    ----------
    vim:
        ----------
        new:
            2:8.0.1453-1ubuntu1
        old:

```
# Targeting Minion

## Minion ID
```
[mc@salt-master ~]$ salt 'ubuntu-srv-salt-minion-02.home.lab' test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
```

## Glob
Shell globs can be used to a list of minions
```buildoutcfg
[mc@salt-master ~]$ salt '*' test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
centos-srv-salt-minion-01.home.lab:
    True
```

Combine shell-glob with minion ID:
```buildoutcfg
[mc@salt-master ~]$ salt '*srv*' test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
centos-srv-salt-minion-01.home.lab:
    True
[mc@salt-master ~]$ salt 'ubuntu-srv*' test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
```

## List (-L)

Comma-separated list of minion ID's:
```
[mc@salt-master ~]$ salt -L centos-srv-salt-minion-01.home.lab,ubuntu-srv-salt-minion-02.home.lab test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
centos-srv-salt-minion-01.home.lab:
    True
```

## Regular Expression (-E)

Regular expressions for more complex targeting:
```
[mc@salt-master ~]$ salt -E '(centos|ubuntu)-srv-salt-minion-0(1|2)\.home\.lab' test.ping
centos-srv-salt-minion-01.home.lab:
    True
ubuntu-srv-salt-minion-02.home.lab:
    True
```

## Grains (-G)

Minion gathered information about operating system and envirionment, presented to the user
as grains. Grains are a simple data structure that allows to target based on some underlying aspcet of the system. 
Will be disscused in detalis later. 
```
[mc@salt-master ~]$ salt -G 'os:Centos' test.ping
centos-srv-salt-minion-01.home.lab:
    True
[mc@salt-master ~]$ salt -G 'os:Ubuntu' test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
[mc@salt-master ~]$ salt -G 'os:Debian' test.ping
No minions matched the target. No command was sent, no jid was assigned.
ERROR: No return received
```

## Compound (-C)

Combine several types in one command, no problem, use compound matcher.
```
[mc@salt-master ~]$ salt -C '*ubuntu* or G@os:Centos' test.ping
centos-srv-salt-minion-01.home.lab:
    True
ubuntu-srv-salt-minion-02.home.lab:
    True
```

https://docs.saltstack.com/en/latest/ref/configuration/nonroot.html

# Accessing Saltstack documentation

## sys.doc basics
The sys modules will give you additional insight into the modules and functions on a given minion.
Saltstack contains extensive docstrings for its codebase. To access these docstrings, we can
use the sys execution module.

```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.doc test.ping
test.ping:

    Used to make sure the minion is up and responding. Not an ICMP ping.

    Returns ``True``.

    CLI Example:

        salt '*' test.ping

```

```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.doc test
test.arg:

    Print out the data passed into the function ``*args`` and ```kwargs``, this
    is used to both test the publication data and cli argument passing, but
    also to display the information available within the publication data.
    Returns {"args": args, "kwargs": kwargs}.

    CLI Example:

        salt '*' test.arg 1 "two" 3.1 txt="hello" wow='{a: 1, b: "hello"}'
    

test.arg_clean:

    Like test.arg but cleans kwargs of the __pub* items
    CLI Example:

        salt '*' test.arg_clean 1 "two" 3.1 txt="hello" wow='{a: 1, b: "hello"}'
```

```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.doc
[mc@salt-master ~]$ salt '*minion-01*' sys.doc test
[mc@salt-master ~]$ salt '*minion-01*' sys.list_modules
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions test
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions test.ping
[mc@salt-master ~]$ salt '*minion-01*' sys.list_modules | grep cloud
[mc@salt-master ~]$ salt '*minion-01*' sys.doc cloud
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions cloud
[mc@salt-master ~]$ salt '*minion-01*' sys.doc cloud.create
```