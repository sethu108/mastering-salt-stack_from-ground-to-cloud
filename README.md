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
[root@master ~]# salt-key -L
Unaccepted Keys:
alpha
bravo
charlie
delta
Accepted Keys:
```
This example shows that the Salt Master is aware of four Minions, but none of the keys has been accepted. To accept the keys and allow the Minions to be controlled by the Master, again use the salt-key command:

```
[root@master ~]# salt-key -A
[root@master ~]# salt-key -L
Unaccepted Keys:
Accepted Keys:

```

The salt-key command allows for signing keys individually or in bulk. The example above, using -A bulk-accepts all pending keys. To accept keys individually use the lowercase of the same option, -a keyname.

See also

salt-key manpage
https://docs.saltstack.com/en/latest/ref/cli/salt-key.html#salt-key


```
[root@master ~]# salt alpha test.ping
alpha:
    True
```
Communication between the Master and all Minions may be tested in a similar way:
```
[root@master ~]# salt '*' test.ping
```

Each of the Minions should send a True response as shown above.

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






https://docs.saltstack.com/en/latest/ref/configuration/nonroot.html


 Minion Targeting
We have referred to the targeting of minions multiple times. The target is used in the main salt command as the first argument. (We briefly mentioned that targeting is also used in states. . Just be aware that targeting is used for more than just the salt command.) Now, we will look at the options for how you can target using different attributes.
In our testing setup, we have a master and four additional minions.
Table 2-3. Testing setup for minion targeting
ID
Master?
Operating system
master.example
Yes
CentOS 6.6
minion1.example
No
CentOS 6.6
minion2.example
No
CentOS 6.6
minion3.example
No
Ubuntu 14.04
minion4.example
No
Ubuntu 14.04
You can use any mix of minions that you need. You will just need to adjust the outputs of the examples accordingly. Also, we will be using the test.ping module heavily; this is a simple execution module that we have already introduced. There are multiple ways of targeting your minions. We are going to discuss the most common. This is not an exhaustive list, but rather merely some examples to get you familiar with how you can target commands to different collections of minions.
Minion ID
The simplest way to target is to specify minions based on ID:

[vagrant@master ~]$ sudo salt minion1.example test.ping
minion1.example:
    True

List (-L)
Next, you can provide a comma-separated list of minion IDs:

[vagrant@master ~]$ sudo salt -L master.example,minion1.example test.ping
master.example:
    True
minion1.example:
    True

Glob
Simple, shell-style globs can be expanded to a list of minions. As we discussed earlier, an asterisk will expand to every known minion:

[vagrant@master ~]$ sudo salt '*' test.ping
minion1.example:
    True
minion3.example:
    True
minion4.example:
    True
minion2.example:
    True
master.example:
    True

NOTE
As you can clearly see in this example, the minions are not expected to return in any given order. The order is simply the first minion to send data back on the return socket.
You can also combine a glob with the minion ID:

[vagrant@master ~]$ sudo salt 'min*' test.ping
minion4.example:
    True
minion1.example:
    True
minion2.example:
    True
minion3.example:
    True

Regular Expression (-E)
Regular expressions allow for more complex patterns:

[vagrant@master ~]$ sudo salt -E 'minion(1|2)\.example' test.ping
minion1.example:
    True
minion2.example:
    True

This is a pretty simple regular expression. It just says:

    Match anything starting with minion,
    Then match either a 1 or a 2,
    And then match anything ending with .example.

If you have a strong naming scheme, you can do powerful matching using regular expressions.
Grains (-G)
The minions will gather information about the operating system (and the environment in general) and present it to the user as grains. Grains are a simple data structure that allows you to target based on some underlying aspect of the systems you are running. (Grains will be discussed in detail in ) For example, grains provide the operating system name (e.g., CentOS) and the version (e.g., 6.6). This allows you to send a command to, say, upgrade the Apache package only on CentOS 6.6 hosts.
TIP
It is important to note that the grains are loaded when the Salt minion starts. Grains are meant for static data. There are ways to load grains more dynamically.
Let’s see a quick example using the operating system name. We can ping only the CentOS hosts:

[vagrant@master ~]$ sudo salt -G 'os:CentOS' test.ping
master.example:
    True
minion2.example:
    True
minion1.example:
    True

And then likewise with the Ubuntu minions:

[vagrant@master ~]$ sudo salt -G 'os:Ubuntu' test.ping
minion4.example:
    True
minion3.example:
    True

Compound (-C)
The preceding methods of targeting minions are very powerful. But what if you want to combine several types in one command? That is where the compound matcher comes in. You can combine any of the other matchers in one command. The compound matcher works using simple prefixes for each type. Let’s look at a simple example:

[vagrant@master ~]$ sudo salt -C 'master* or G@os:Ubuntu' test.ping
minion4.example:
    True
minion3.example:
    True
master.example:
    True

The different types of matchers are identified with a single capital letter followed by the at sign (@). In our example we used a grains matcher, G@, followed by the name and value of the grain, os:Ubuntu, just as in the grains example in the previous section. We also used a standard globbing type: master*. Notice there was no single letter prefix, however. Just as with the salt command, a minion ID and/or a glob is the default matcher if nothing else is specified. Lastly, we need to combine the two types of matches using the or operator. (You can use the standard Boolean operators: and, or, and not.) Combining the other matchers is extremely powerful, and we have only scratched the surface of what is available.
Targeting Summary
We have shown some of the major ways you can target your minions. However, there are a few others. For example, you can target by IP address or via node groups. Node groups are an arbitrary list of minions defined in the master’s configuration file. The previous examples will take you far. But be aware that there are other options for targeting your minions, and this is a list that can grow over time.
