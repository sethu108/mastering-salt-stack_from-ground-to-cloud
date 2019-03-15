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
```

```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_modules
centos-srv-salt-minion-01.home.lab:
    - acl
    - aliases
    - alternatives
    - ansible
    - archive
    - artifactory
    - beacons
    - bigip
    - btrfs
    - buildout
    - cloud
    - cmd
    - composer
    - config
```

```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_modules | grep -E "test|pkg"
    - kernelpkg
    - lowpkg
    - pkg
    - pkg_resource
    - test
```


```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions
[mc@salt-master ~]$ salt '*minion-01*' sys.list_modules
centos-srv-salt-minion-01.home.lab:
    - acl
    - aliases
    - alternatives
    - ansible
    - archive
    - artifactory
    - beacons
    - bigip
    - btrfs
    - buildout
    - cloud
    - cmd
    - composer
    - config
    - consul
    - container_resource
    - cp
    - cron
    - cryptdev
    - data
    - defaults
    - devmap
    - disk
    - django
    - dnsmasq
    - dnsutil
    - drbd
    - environ
    - etcd
    - ethtool
    - event
    - extfs
    - file
    - firewalld
    - gem
    - genesis
    - glassfish
    - gnome
    - google_chat
    - grafana4
    - grains
    - group
    - hashutil
    - highstate_doc
    - hipchat
    - hosts
    - http
    - incron
    - ini
    - inspector
    - introspect
    - iosconfig
    - ip
    - ipset
    - iptables
    - jboss7
    - jboss7_cli
    - k8s
    - kernelpkg
    - key
    - keyboard
    - kmod
    - locale
    - locate
    - log
    - logrotate
    - lowpkg
    - lvm
    - mandrill
    - match
    - mattermost
    - mine
    - minion
    - modjk
    - mount
    - msteams
    - nagios_rpc
    - namecheap_domains
    - namecheap_domains_dns
    - namecheap_domains_ns
    - namecheap_ssl
    - namecheap_users
    - network
    - nexus
    - nova
    - nspawn
    - nxos_api
    - openscap
    - openstack_config
    - opsgenie
    - out
    - pagerduty
    - pagerduty_util
    - pam
    - parallels
    - partition
    - peeringdb
    - pillar
    - pkg
    - pkg_resource
    - postfix
    - ps
    - publish
    - pushover
    - pyenv
    - random
    - random_org
    - rbenv
    - rest_sample_utils
    - restartcheck
    - ret
    - rvm
    - s3
    - s6
    - salt_proxy
    - saltcheck
    - saltutil
    - schedule
    - scsi
    - sdb
    - seed
    - serverdensity_device
    - service
    - shadow
    - slack
    - slsutil
    - smbios
    - smtp
    - solrcloud
    - sqlite3
    - ssh
    - state
    - status
    - statuspage
    - supervisord
    - sys
    - sysctl
    - sysfs
    - syslog_ng
    - system
    - telegram
    - telemetry
    - temp
    - test
    - timezone
    - tuned
    - udev
    - uptime
    - user
    - vault
    - vbox_guest
    - virtualenv
    - vsphere
    - xfs
    - zabbix
    - zenoss
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions
centos-srv-salt-minion-01.home.lab:
    - acl.delfacl
    - acl.getfacl
    - acl.modfacl
    - acl.version
    - acl.wipefacls
    - aliases.get_target
    - aliases.has_target
    - aliases.list_aliases
    - aliases.rm_alias
    - aliases.set_target
    - alternatives.auto
    - alternatives.check_exists
    - alternatives.check_installed
    - alternatives.display
    - alternatives.install
    - alternatives.remove
    - alternatives.set
    - alternatives.show_current
    - alternatives.show_link
    - ansible.help
    - ansible.list
    - ansible.playbooks
    - archive.cmd_unzip
    - archive.cmd_zip
    - archive.gunzip
    - archive.gzip
    - archive.is_encrypted
    - archive.list
    - archive.rar
    - archive.tar
    - archive.unrar
    - archive.unzip
    - archive.zip
    - artifactory.get_latest_release
    - artifactory.get_latest_snapshot
    - artifactory.get_release
    - artifactory.get_snapshot
    - beacons.add
    - beacons.delete
    - beacons.disable
    - beacons.disable_beacon
    - beacons.enable
    - beacons.enable_beacon
    - beacons.list
    - beacons.list_available
    - beacons.modify
    - beacons.reset
    - beacons.save
    - bigip.add_pool_member
    - bigip.commit_transaction
    - bigip.create_monitor
    - bigip.create_node
    - bigip.create_pool
    - bigip.create_profile
    - bigip.create_virtual
    - bigip.delete_monitor
    - bigip.delete_node
    - bigip.delete_pool
    - bigip.delete_pool_member
    - bigip.delete_profile
    - bigip.delete_transaction
    - bigip.delete_virtual
    - bigip.list_monitor
    - bigip.list_node
    - bigip.list_pool
    - bigip.list_profile
    - bigip.list_transaction
    - bigip.list_virtual
    - bigip.modify_monitor
    - bigip.modify_node
    - bigip.modify_pool
    - bigip.modify_pool_member
    - bigip.modify_profile
    - bigip.modify_virtual
    - bigip.replace_pool_members
    - bigip.start_transaction
    - btrfs.add
    - btrfs.convert
    - btrfs.defragment
    - btrfs.delete
    - btrfs.devices
    - btrfs.features
    - btrfs.info
    - btrfs.mkfs
    - btrfs.properties
    - btrfs.resize
    - btrfs.usage
    - btrfs.version
    - buildout.bootstrap
    - buildout.buildout
    - buildout.run_buildout
    - buildout.upgrade_bootstrap
    - cloud.action
    - cloud.create
    - cloud.destroy
    - cloud.full_query
    - cloud.get_instance
    - cloud.has_instance
    - cloud.list_images
    - cloud.list_locations
    - cloud.list_sizes
    - cloud.map_run
    - cloud.network_create
    - cloud.network_list
    - cloud.profile
    - cloud.query
    - cloud.select_query
    - cloud.virtual_interface_create
    - cloud.virtual_interface_list
    - cloud.volume_attach
    - cloud.volume_create
    - cloud.volume_delete
    - cloud.volume_detach
    - cloud.volume_list
    - cmd.exec_code
    - cmd.exec_code_all
    - cmd.has_exec
    - cmd.powershell
    - cmd.powershell_all
    - cmd.retcode
    - cmd.run
    - cmd.run_all
    - cmd.run_bg
    - cmd.run_chroot
    - cmd.run_stderr
    - cmd.run_stdout
    - cmd.script
    - cmd.script_retcode
    - cmd.shell
    - cmd.shell_info
    - cmd.shells
    - cmd.tty
    - cmd.which
    - cmd.which_bin
    - composer.did_composer_install
    - composer.install
    - composer.selfupdate
    - composer.update
    - config.backup_mode
    - config.dot_vals
    - config.gather_bootstrap_script
    - config.get
    - config.items
    - config.manage_mode
    - config.merge
    - config.option
    - config.valid_fileproto
    - consul.acl_clone
    - consul.acl_create
    - consul.acl_delete
    - consul.acl_info
    - consul.acl_list
    - consul.acl_update
    - consul.agent_check_deregister
    - consul.agent_check_fail
    - consul.agent_check_pass
    - consul.agent_check_register
    - consul.agent_check_warn
    - consul.agent_checks
    - consul.agent_join
    - consul.agent_leave
    - consul.agent_maintenance
    - consul.agent_members
    - consul.agent_self
    - consul.agent_service_deregister
    - consul.agent_service_maintenance
    - consul.agent_service_register
    - consul.agent_services
    - consul.catalog_datacenters
    - consul.catalog_deregister
    - consul.catalog_node
    - consul.catalog_nodes
    - consul.catalog_register
    - consul.catalog_service
    - consul.catalog_services
    - consul.delete
    - consul.event_fire
    - consul.event_list
    - consul.get
    - consul.health_checks
    - consul.health_node
    - consul.health_service
    - consul.health_state
    - consul.list
    - consul.put
    - consul.session_create
    - consul.session_destroy
    - consul.session_info
    - consul.session_list
    - consul.status_leader
    - consul.status_peers
    - container_resource.cache_file
    - container_resource.copy_to
    - container_resource.run
    - cp.cache_dir
    - cp.cache_file
    - cp.cache_files
    - cp.cache_local_file
    - cp.cache_master
    - cp.envs
    - cp.get_dir
    - cp.get_file
    - cp.get_file_str
    - cp.get_template
    - cp.get_url
    - cp.hash_file
    - cp.is_cached
    - cp.list_master
    - cp.list_master_dirs
    - cp.list_master_symlinks
    - cp.list_minion
    - cp.list_states
    - cp.push
    - cp.push_dir
    - cp.recv
    - cp.recv_chunked
    - cp.stat_file
    - cron.list_tab
    - cron.ls
    - cron.raw_cron
    - cron.rm
    - cron.rm_env
    - cron.rm_job
    - cron.rm_special
    - cron.set_env
    - cron.set_job
    - cron.set_special
    - cron.write_cron_file
    - cron.write_cron_file_verbose
    - cryptdev.active
    - cryptdev.close
    - cryptdev.crypttab
    - cryptdev.open
    - cryptdev.rm_crypttab
    - cryptdev.set_crypttab
    - data.cas
    - data.clear
    - data.dump
    - data.get
    - data.has_key
    - data.items
    - data.keys
    - data.load
    - data.pop
    - data.update
    - data.values
    - defaults.deepcopy
    - defaults.get
    - defaults.merge
    - defaults.update
    - devmap.multipath_flush
    - devmap.multipath_list
    - disk.blkid
    - disk.dump
    - disk.format
    - disk.fstype
    - disk.inodeusage
    - disk.percent
    - disk.resize2fs
    - disk.smart_attributes
    - disk.tune
    - disk.usage
    - disk.wipe
    - django.collectstatic
    - django.command
    - django.createsuperuser
    - django.loaddata
    - django.syncdb
    - dnsmasq.fullversion
    - dnsmasq.get_config
    - dnsmasq.set_config
    - dnsmasq.version
    - dnsutil.A
    - dnsutil.AAAA
    - dnsutil.MX
    - dnsutil.NS
    - dnsutil.SPF
    - dnsutil.check_ip
    - dnsutil.hosts_append
    - dnsutil.hosts_remove
    - dnsutil.parse_hosts
    - dnsutil.parse_zone
    - dnsutil.serial
    - drbd.overview
    - environ.get
    - environ.has_value
    - environ.item
    - environ.items
    - environ.setenv
    - environ.setval
    - etcd.get
    - etcd.ls
    - etcd.rm
    - etcd.set
    - etcd.tree
    - etcd.update
    - etcd.watch
    - ethtool.set_coalesce
    - ethtool.set_offload
    - ethtool.set_ring
    - ethtool.show_coalesce
    - ethtool.show_driver
    - ethtool.show_offload
    - ethtool.show_ring
    - event.fire
    - event.fire_master
    - event.send
    - extfs.attributes
    - extfs.blocks
    - extfs.dump
    - extfs.mkfs
    - extfs.tune
    - file.access
    - file.append
    - file.apply_template_on_contents
    - file.basename
    - file.blockreplace
    - file.chattr
    - file.check_file_meta
    - file.check_hash
    - file.check_managed
    - file.check_managed_changes
    - file.check_perms
    - file.chgrp
    - file.chown
    - file.comment
    - file.comment_line
    - file.contains
    - file.contains_glob
    - file.contains_regex
    - file.copy
    - file.delete_backup
    - file.directory_exists
    - file.dirname
    - file.diskusage
    - file.extract_hash
    - file.file_exists
    - file.find
    - file.get_devmm
    - file.get_diff
    - file.get_gid
    - file.get_group
    - file.get_hash
    - file.get_managed
    - file.get_mode
    - file.get_selinux_context
    - file.get_source_sum
    - file.get_sum
    - file.get_uid
    - file.get_user
    - file.gid_to_group
    - file.grep
    - file.group_to_gid
    - file.is_blkdev
    - file.is_chrdev
    - file.is_fifo
    - file.is_link
    - file.join
    - file.lchown
    - file.line
    - file.link
    - file.list_backup
    - file.list_backups
    - file.list_backups_dir
    - file.lsattr
    - file.lstat
    - file.makedirs
    - file.makedirs_perms
    - file.manage_file
    - file.mkdir
    - file.mknod
    - file.mknod_blkdev
    - file.mknod_chrdev
    - file.mknod_fifo
    - file.move
    - file.normpath
    - file.open_files
    - file.pardir
    - file.patch
    - file.path_exists_glob
    - file.prepend
    - file.psed
    - file.read
    - file.readdir
    - file.readlink
    - file.remove
    - file.remove_backup
    - file.rename
    - file.replace
    - file.restore_backup
    - file.restorecon
    - file.rmdir
    - file.search
    - file.sed
    - file.sed_contains
    - file.seek_read
    - file.seek_write
    - file.set_mode
    - file.set_selinux_context
    - file.source_list
    - file.stats
    - file.statvfs
    - file.symlink
    - file.touch
    - file.truncate
    - file.uid_to_user
    - file.uncomment
    - file.user_to_uid
    - file.write
    - firewalld.add_interface
    - firewalld.add_masquerade
    - firewalld.add_port
    - firewalld.add_port_fwd
    - firewalld.add_rich_rule
    - firewalld.add_service
    - firewalld.add_service_port
    - firewalld.add_service_protocol
    - firewalld.add_source
    - firewalld.allow_icmp
    - firewalld.block_icmp
    - firewalld.default_zone
    - firewalld.delete_service
    - firewalld.delete_zone
    - firewalld.get_icmp_types
    - firewalld.get_interfaces
    - firewalld.get_masquerade
    - firewalld.get_rich_rules
    - firewalld.get_service_ports
    - firewalld.get_service_protocols
    - firewalld.get_services
    - firewalld.get_sources
    - firewalld.get_zones
    - firewalld.list_all
    - firewalld.list_icmp_block
    - firewalld.list_port_fwd
    - firewalld.list_ports
    - firewalld.list_services
    - firewalld.list_zones
    - firewalld.make_permanent
    - firewalld.new_service
    - firewalld.new_zone
    - firewalld.reload_rules
    - firewalld.remove_interface
    - firewalld.remove_masquerade
    - firewalld.remove_port
    - firewalld.remove_port_fwd
    - firewalld.remove_rich_rule
    - firewalld.remove_service
    - firewalld.remove_service_port
    - firewalld.remove_service_protocol
    - firewalld.remove_source
    - firewalld.set_default_zone
    - firewalld.version
    - gem.install
    - gem.list
    - gem.list_upgrades
    - gem.sources_add
    - gem.sources_list
    - gem.sources_remove
    - gem.uninstall
    - gem.update
    - gem.update_system
    - genesis.avail_platforms
    - genesis.bootstrap
    - genesis.ldd_deps
    - genesis.mksls
    - genesis.pack
    - genesis.unpack
    - glassfish.create_admin_object_resource
    - glassfish.create_connector_c_pool
    - glassfish.create_connector_resource
    - glassfish.create_jdbc_connection_pool
    - glassfish.create_jdbc_resource
    - glassfish.delete_admin_object_resource
    - glassfish.delete_connector_c_pool
    - glassfish.delete_connector_resource
    - glassfish.delete_jdbc_connection_pool
    - glassfish.delete_jdbc_resource
    - glassfish.delete_system_properties
    - glassfish.enum_admin_object_resource
    - glassfish.enum_connector_c_pool
    - glassfish.enum_connector_resource
    - glassfish.enum_jdbc_connection_pool
    - glassfish.enum_jdbc_resource
    - glassfish.get_admin_object_resource
    - glassfish.get_connector_c_pool
    - glassfish.get_connector_resource
    - glassfish.get_jdbc_connection_pool
    - glassfish.get_jdbc_resource
    - glassfish.get_system_properties
    - glassfish.quote
    - glassfish.unquote
    - glassfish.update_admin_object_resource
    - glassfish.update_connector_c_pool
    - glassfish.update_connector_resource
    - glassfish.update_jdbc_connection_pool
    - glassfish.update_jdbc_resource
    - glassfish.update_system_properties
    - gnome.get
    - gnome.getClockFormat
    - gnome.getClockShowDate
    - gnome.getIdleActivation
    - gnome.getIdleDelay
    - gnome.ping
    - gnome.set
    - gnome.setClockFormat
    - gnome.setClockShowDate
    - gnome.setIdleActivation
    - gnome.setIdleDelay
    - google_chat.send_message
    - grafana4.create_datasource
    - grafana4.create_org
    - grafana4.create_org_user
    - grafana4.create_update_dashboard
    - grafana4.create_user
```

```buildoutcfg
[mc@salt-master ~]$  salt '*minion-01*' sys.list_functions pkg
centos-srv-salt-minion-01.home.lab:
    - pkg.available_version
    - pkg.clean_metadata
    - pkg.del_repo
    - pkg.diff
    - pkg.download
    - pkg.file_dict
    - pkg.file_list
    - pkg.get_locked_packages
    - pkg.get_repo
    - pkg.group_diff
    - pkg.group_info
    - pkg.group_install
    - pkg.group_list
    - pkg.groupinstall
    - pkg.hold
    - pkg.info_installed
    - pkg.install
    - pkg.latest_version
    - pkg.list_downloaded
    - pkg.list_holds
    - pkg.list_installed_patches
    - pkg.list_patches
    - pkg.list_pkgs
    - pkg.list_repo_pkgs
    - pkg.list_repos
    - pkg.list_updates
    - pkg.list_upgrades
    - pkg.mod_repo
    - pkg.modified
    - pkg.normalize_name
    - pkg.owner
    - pkg.purge
    - pkg.refresh_db
    - pkg.remove
    - pkg.unhold
    - pkg.update
    - pkg.upgrade
    - pkg.upgrade_available
    - pkg.verify
    - pkg.version
    - pkg.version_cmp
[mc@salt-master ~]$  salt '*minion-01*' sys.list_functions pkg.install
centos-srv-salt-minion-01.home.lab:
    - pkg.install

[mc@salt-master ~]$  salt '*minion-01*' sys.doc pkg.install
pkg.install:

    Changed in version 2015.8.12,2016.3.3,2016.11.0
        On minions running systemd>=205, `systemd-run(1)`_ is now used to
        isolate commands which modify installed packages from the
        ``salt-minion`` daemon's control group. This is done to keep systemd
        from killing any yum/dnf commands spawned by Salt when the
        ``salt-minion`` service is restarted. (see ``KillMode`` in the
        `systemd.kill(5)`_ manpage for more information). If desired, usage of
        `systemd-run(1)`_ can be suppressed by setting a :mod:`config option
        <salt.modules.config.get>` called ``systemd.scope``, with a value of
        ``False`` (no quotes).

    .. _`systemd-run(1)`: https://www.freedesktop.org/software/systemd/man/systemd-run.html
    .. _`systemd.kill(5)`: https://www.freedesktop.org/software/systemd/man/systemd.kill.html

    Install the passed package(s), add refresh=True to clean the yum database
    before package is installed.

    name
        The name of the package to be installed. Note that this parameter is
        ignored if either "pkgs" or "sources" is passed. Additionally, please
        note that this option can only be used to install packages from a
        software repository. To install a package file manually, use the
        "sources" option.

        32-bit packages can be installed on 64-bit systems by appending the
        architecture designation (``.i686``, ``.i586``, etc.) to the end of the
        package name.

        CLI Example:

            salt '*' pkg.install <package name>

    refresh
        Whether or not to update the yum database before executing.

    reinstall
        Specifying reinstall=True will use ``yum reinstall`` rather than
        ``yum install`` for requested packages that are already installed.

        If a version is specified with the requested package, then
        ``yum reinstall`` will only be used if the installed version
        matches the requested version.

        Works with ``sources`` when the package header of the source can be
        matched to the name and version of an installed package.

        New in version 2014.7.0

    skip_verify
        Skip the GPG verification check (e.g., ``--nogpgcheck``)

    downloadonly
        Only download the packages, do not install.

    version
        Install a specific version of the package, e.g. 1.2.3-4.el5. Ignored
        if "pkgs" or "sources" is passed.

        Changed in version 2018.3.0
            version can now contain comparison operators (e.g. ``>1.2.3``,
            ``<=2.0``, etc.)

    update_holds : False
        If ``True``, and this function would update the package version, any
        packages held using the yum/dnf "versionlock" plugin will be unheld so
        that they can be updated. Otherwise, if this function attempts to
        update a held package, the held package(s) will be skipped and an
        error will be raised.

        New in version 2016.11.0

    setopt
        A comma-separated or Python list of key=value options. This list will
        be expanded and ``--setopt`` prepended to each in the yum/dnf command
        that is run.

        CLI Example:

            salt '*' pkg.install foo setopt='obsoletes=0,plugins=0'

        New in version 2019.2.0

    Repository Options:

    fromrepo
        Specify a package repository (or repositories) from which to install.
        (e.g., ``yum --disablerepo='*' --enablerepo='somerepo'``)

    enablerepo (ignored if ``fromrepo`` is specified)
        Specify a disabled package repository (or repositories) to enable.
        (e.g., ``yum --enablerepo='somerepo'``)

    disablerepo (ignored if ``fromrepo`` is specified)
        Specify an enabled package repository (or repositories) to disable.
        (e.g., ``yum --disablerepo='somerepo'``)

    disableexcludes
        Disable exclude from main, for a repo or for everything.
        (e.g., ``yum --disableexcludes='main'``)

        New in version 2014.7.0

    ignore_epoch : False
        Only used when the version of a package is specified using a comparison
        operator (e.g. ``>4.1``). If set to ``True``, then the epoch will be
        ignored when comparing the currently-installed version to the desired
        version.

        New in version 2018.3.0


    Multiple Package Installation Options:

    pkgs
        A list of packages to install from a software repository. Must be
        passed as a python list. A specific version number can be specified
        by using a single-element dict representing the package and its
        version.

        CLI Examples:

            salt '*' pkg.install pkgs='["foo", "bar"]'
            salt '*' pkg.install pkgs='["foo", {"bar": "1.2.3-4.el5"}]'

    sources
        A list of RPM packages to install. Must be passed as a list of dicts,
        with the keys being package names, and the values being the source URI
        or local path to the package.

        CLI Example:

            salt '*' pkg.install sources='[{"foo": "salt://foo.rpm"}, {"bar": "salt://bar.rpm"}]'

    normalize : True
        Normalize the package name by removing the architecture. This is useful
        for poorly created packages which might include the architecture as an
        actual part of the name such as kernel modules which match a specific
        kernel version.

            salt -G role:nsd pkg.install gpfs.gplbin-2.6.32-279.31.1.el6.x86_64 normalize=False

        New in version 2014.7.0

    diff_attr:
        If a list of package attributes is specified, returned value will
        contain them, eg.::

            {'<package>': {
                'old': {
                    'version': '<old-version>',
                    'arch': '<old-arch>'},

                'new': {
                    'version': '<new-version>',
                    'arch': '<new-arch>'}}}

        Valid attributes are: ``epoch``, ``version``, ``release``, ``arch``,
        ``install_date``, ``install_date_time_t``.

        If ``all`` is specified, all valid attributes will be returned.

        New in version 2018.3.0

    Returns a dict containing the new package names and versions::

        {'<package>': {'old': '<old-version>',
                       'new': '<new-version>'}}

    If an attribute list in diff_attr is specified, the dict will also contain
    any specified attribute, eg.::

        {'<package>': {
            'old': {
                'version': '<old-version>',
                'arch': '<old-arch>'},

            'new': {
                'version': '<new-version>',
                'arch': '<new-arch>'}}}

```
