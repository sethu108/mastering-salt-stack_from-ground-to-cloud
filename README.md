# Mastering Salt Stack from ground to Cloud

# Installation

## BOOTSTRAP - MULTI-PLATFORM
https://repo.saltstack.com/#bootstrap

### On the Salt Master
```buildoutcfg
curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P -M
```
Your Salt master can manage itself, so a Salt minion is installed along with the Salt master. If you do not want to install the minion, also pass the -N option.

### On the Salt Minion
```buildoutcfg
curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P
```

## Install using wget

#### Using wget to install your distribution's stable packages
```
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh
```

### Installing a specific version from git using wget
```
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -P git v2016.11.5
```

## Based on specific platform

## Fedora
#### Packages are available in the standard Fedora repositories. Install the salt-minion, salt-master, or other Salt components:
```buildoutcfg
sudo dnf install -y salt-master \
salt-minion \
salt-ssh \
salt-syndic \
salt-cloud \
salt-api
```

## Redhat / CentOS 7 

Installs the latest release. Updating installs the latest release even if it is a new major version.

Run the following commands to install the SaltStack repository and key
```buildoutcfg
sudo yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm 
sudo yum clean expire-cache
```

#### Install the salt-minion, salt-master, or other Salt components:
```buildoutcfg
sudo yum install -y salt-master \
salt-minion \
salt-ssh \
salt-syndic \
salt-cloud \
salt-api
```

#### (Upgrade only) Restart all upgraded services, for example
```buildoutcfg
sudo systemctl restart salt-minion
```

## Ubuntu
#### Ubuntu 18 (bionic)

#### Installs the latest release. Updating installs the latest release even if it is a new major version.

#### Run the following command to import the SaltStack repository key:
```buildoutcfg
wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
```
#### Save the following line to /etc/apt/sources.list.d/saltstack.list:
```buildoutcfg
sudo echo "deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest bionic main" >> /etc/apt/sources.list.d/saltstack.list
```
#### Run 
```buildoutcfg
sudo apt-get update
```
#### Install the salt-minion, salt-master, or other Salt components:
```buildoutcfg
sudo apt-get install -y salt-master \
salt-minion \
salt-ssh \
salt-syndic \
salt-cloud \
salt-api
```

#### (Upgrade only) Restart all upgraded services, for example:
```buildoutcfg
sudo systemctl restart salt-minion
```

## Other distros
https://docs.saltstack.com/en/latest/topics/installation/index.html#platform-specific-installation-instructions

# Configuring Salt

Salt configuration is very simple. The default configuration for the master will work for most installations and the only requirement for setting up a minion is to set the location of the master in the minion configuration file.

The configuration files will be installed to /etc/salt and are named after the respective components, /etc/salt/master, and /etc/salt/minion.

## Master Configuration

By default the Salt master listens on ports 4505 and 4506 on all interfaces (0.0.0.0). To bind Salt to a specific IP, redefine the "interface" directive in the master configuration file, typically /etc/salt/master, as follows:
```
- #interface: 0.0.0.0
+ interface: 172.16.2.101
```
After updating the configuration file, restart the Salt master. See the master configuration reference for more details about other configurable options.
```
sudo systemctl restart salt-master
```
## Minion Configuration

Although there are many Salt Minion configuration options, configuring a Salt Minion is very simple. By default a Salt Minion will try to connect to the DNS name "salt"; if the Minion is able to resolve that name correctly, no configuration is needed.

If the DNS name "salt" does not resolve to point to the correct location of the Master, redefine the "master" directive in the minion configuration file, typically /etc/salt/minion, as follows:

```
- #master: salt
+ master: 172.16.2.101
or 
+ master: salt-master
```

**NOTE:** Please check your **salt-master** ip address with some of tools that are available on your distribtution, probably it will be different than one I am using in this example. 
I got question in some of previous version of course, where students have issues during configuration/comunication between salt-master and salt-minion because they actualy used copy/paste of ip from
this tutorial. 

After updating the configuration file, restart the Salt minion. See the minion configuration reference for more details about other configurable options.
```
sudo systemctl restart salt-minion
```

### Having trouble?

The simplest way to troubleshoot Salt is to run the master and minion in the foreground with log level set to debug:
```buildoutcfg
salt-master --log-level=debug
```
For information on salt's logging system please see the logging document.

### Run as an unprivileged (non-root) user

To run Salt as another user, set the user parameter in the master config file.

Additionally, ownership, and permissions need to be set such that the desired user can read from and write to the following directories (and their subdirectories, where applicable):
```buildoutcfg
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
```buildoutcfg
salt-key -F master
```
Copy the master.pub fingerprint from the Local Keys section, and then set this value as the master_finger in the minion configuration file. Save the configuration file and then restart the Salt minion.
Minion Key Fingerprint

Run the following command on each Salt minion to view the minion key fingerprint:
```buildoutcfg
salt-call --local key.finger
```
Compare this value to the value that is displayed when you run the salt-key --finger <MINION_ID> command on the Salt master.

### Key Management

Salt uses AES encryption for all communication between the Master and the Minion. This ensures that the commands sent to the Minions cannot be tampered with, and that communication between Master and Minion is authenticated through trusted, accepted keys.

Before commands can be sent to a Minion, its key must be accepted on the Master. Run the salt-key command to list the keys known to the Salt Master:

```buildoutcfg
[mc@salt-master ~]$ salt-key -L
Accepted Keys:
Denied Keys:
Unaccepted Keys:
centos-srv-salt-minion-01.home.lab
ubuntu-srv-salt-minion-02.home.lab
Rejected Keys:
```
This example shows that the Salt Master is aware of four Minions, but none of the keys has been accepted. To accept the keys and allow the Minions to be controlled by the Master, again use the salt-key command:

```buildoutcfg
[mc@salt-master ~]$ salt-key -L
Accepted Keys:
centos-srv-salt-minion-01.home.lab
ubuntu-srv-salt-minion-02.home.lab
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

The salt-key command allows for signing keys individually or in bulk. The example above, using -A bulk-accepts all pending keys. To accept keys individually use the lowercase of the same option, -a keyname.

See also salt-key manpage:

https://docs.saltstack.com/en/latest/ref/cli/salt-key.html#salt-key

# Basic commands concept

## Sending Commands

Communication between the Master and a Minion may be verified by running the test.ping command:

```buildoutcfg
[mc@salt-master ~]$ salt '*' test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
centos-srv-salt-minion-01.home.lab:
    True
```

```buildoutcfg
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

```buildoutcfg
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
```buildoutcfg
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
### salt-call
```buildoutcfg
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
```buildoutcfg
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
```buildoutcfg
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
```buildoutcfg
[mc@salt-master ~]$ salt -L centos-srv-salt-minion-01.home.lab,ubuntu-srv-salt-minion-02.home.lab test.ping
ubuntu-srv-salt-minion-02.home.lab:
    True
centos-srv-salt-minion-01.home.lab:
    True
```

## Regular Expression (-E)

Regular expressions for more complex targeting:
```buildoutcfg
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
```buildoutcfg
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
```buildoutcfg
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

### sys.list_modules and sys.list_functions
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

```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions sys
centos-srv-salt-minion-01.home.lab:
    - sys.argspec
    - sys.doc
    - sys.list_functions
    - sys.list_modules
    - sys.list_renderers
    - sys.list_returner_functions
    - sys.list_returners
    - sys.list_runner_functions
    - sys.list_runners
    - sys.list_state_functions
    - sys.list_state_modules
    - sys.reload_modules
    - sys.renderer_doc
    - sys.returner_argspec
    - sys.returner_doc
    - sys.runner_argspec
    - sys.runner_doc
    - sys.state_argspec
    - sys.state_doc
    - sys.state_schema
```

## cmd module
```buildoutcfg
[mc@salt-master ~]$  salt '*minion-01*' sys.doc cmd
cmd.exec_code:

    Pass in two strings, the first naming the executable language, aka -
    python2, python3, ruby, perl, lua, etc. the second string containing
    the code you wish to execute. The stdout will be returned.

    All parameters from :mod:`cmd.run_all <salt.modules.cmdmod.run_all>` except python_shell can be used.

    CLI Example:

        salt '*' cmd.exec_code ruby 'puts "cheese"'
        salt '*' cmd.exec_code ruby 'puts "cheese"' args='["arg1", "arg2"]' env='{"FOO": "bar"}'
    

cmd.exec_code_all:

    Pass in two strings, the first naming the executable language, aka -
    python2, python3, ruby, perl, lua, etc. the second string containing
    the code you wish to execute. All cmd artifacts (stdout, stderr, retcode, pid)
    will be returned.

    All parameters from :mod:`cmd.run_all <salt.modules.cmdmod.run_all>` except python_shell can be used.
```

```buildoutcfg
[mc@salt-master ~]$  salt '*minion-01*' sys.doc cmd.run
cmd.run:

    Execute the passed command and return the output as a string

    :param str cmd: The command to run. ex: ``ls -lart /home``

    :param str cwd: The directory from which to execute the command. Defaults
        to the home directory of the user specified by ``runas`` (or the user
        under which Salt is running if ``runas`` is not specified).

    :param str stdin: A string of standard input can be specified for the
        command to be run using the ``stdin`` parameter. This can be useful in
        cases where sensitive information must be read from standard input.

    :param str runas: Specify an alternate user to run the command. The default
        behavior is to run as the user under which Salt is running.

        Warning:

            For versions 2018.3.3 and above on macosx while using runas,
            to pass special characters to the command you need to escape
            the characters on the shell.

            Example:

                cmd.run 'echo '\''h=\"baz\"'\''' runas=macuser

    :param str group: Group to run command as. Not currently supported
        on Windows.

    :param str password: Windows only. Required when specifying ``runas``. This
        parameter will be ignored on non-Windows platforms.

        New in version 2016.3.0

    :param str shell: Specify an alternate shell. Defaults to the system's
        default shell.

    :param bool python_shell: If ``False``, let python handle the positional
        arguments. Set to ``True`` to use shell features, such as pipes or
        redirection.

    :param bool bg: If ``True``, run command in background and do not await or
        deliver it's results

        New in version 2016.3.0

    :param dict env: Environment variables to be set prior to execution.

        Note:
            When passing environment variables on the CLI, they should be
            passed as the string representation of a dictionary.

                salt myminion cmd.run 'some command' env='{"FOO": "bar"}'

    :param bool clean_env: Attempt to clean out all other shell environment
        variables and set only those provided in the 'env' argument to this
        function.

    :param str prepend_path: $PATH segment to prepend (trailing ':' not
        necessary) to $PATH

        New in version 2018.3.0

    :param str template: If this setting is applied then the named templating
        engine will be used to render the downloaded file. Currently jinja,
        mako, and wempy are supported.

    :param bool rstrip: Strip all whitespace off the end of output before it is
        returned.

    :param str umask: The umask (in octal) to use when running the command.

    :param str output_encoding: Control the encoding used to decode the
        command's output.

        Note:
            This should not need to be used in most cases. By default, Salt
            will try to use the encoding detected from the system locale, and
            will fall back to UTF-8 if this fails. This should only need to be
            used in cases where the output of the command is encoded in
            something other than the system locale or UTF-8.

            To see the encoding Salt has detected from the system locale, check
            the `locale` line in the output of :py:func:`test.versions_report
            <salt.modules.test.versions_report>`.

        New in version 2018.3.0

    :param str output_loglevel: Control the loglevel at which the output from
        the command is logged to the minion log.

        Note:
            The command being run will still be logged at the ``debug``
            loglevel regardless, unless ``quiet`` is used for this value.

    :param bool ignore_retcode: If the exit code of the command is nonzero,
        this is treated as an error condition, and the output from the command
        will be logged to the minion log. However, there are some cases where
        programs use the return code for signaling and a nonzero exit code
        doesn't necessarily mean failure. Pass this argument as ``True`` to
        skip logging the output if the command has a nonzero exit code.

    :param bool hide_output: If ``True``, suppress stdout and stderr in the
        return data.

        Note:
            This is separate from ``output_loglevel``, which only handles how
            Salt logs to the minion log.

        New in version 2018.3.0

    :param int timeout: A timeout in seconds for the executed process to return.

    :param bool use_vt: Use VT utils (saltstack) to stream the command output
        more interactively to the console and the logs. This is experimental.

    :param bool encoded_cmd: Specify if the supplied command is encoded.
        Only applies to shell 'powershell'.

    :param bool raise_err: If ``True`` and the command has a nonzero exit code,
        a CommandExecutionError exception will be raised.

    Warning:
        This function does not process commands through a shell
        unless the python_shell flag is set to True. This means that any
        shell-specific functionality such as 'echo' or the use of pipes,
        redirection or &&, should either be migrated to cmd.shell or
        have the python_shell=True flag set here.

        The use of python_shell=True means that the shell will accept _any_ input
        including potentially malicious commands such as 'good_command;rm -rf /'.
        Be absolutely certain that you have sanitized your input prior to using
        python_shell=True

    :param list success_retcodes: This parameter will be allow a list of
        non-zero return codes that should be considered a success.  If the
        return code returned from the run matches any in the provided list,
        the return code will be overridden with zero.

      New in version 2019.2.0

    :param bool stdin_raw_newlines: False
        If ``True``, Salt will not automatically convert the characters ``\\n``
        present in the ``stdin`` value to newlines.

      New in version 2019.2.0

    CLI Example:

        salt '*' cmd.run "ls -l | awk '/foo/{print \\$2}'"

    The template arg can be set to 'jinja' or another supported template
    engine to render the command arguments before execution.
    For example:

        salt '*' cmd.run template=jinja "ls -l /tmp/{{grains.id}} | awk '/foo/{print \\$2}'"

    Specify an alternate shell with the shell parameter:

        salt '*' cmd.run "Get-ChildItem C:\\ " shell='powershell'

    A string of standard input can be specified for the command to be run using
    the ``stdin`` parameter. This can be useful in cases where sensitive
    information must be read from standard input.

        salt '*' cmd.run "grep f" stdin='one\\ntwo\\nthree\\nfour\\nfive\\n'

    If an equal sign (``=``) appears in an argument to a Salt command it is
    interpreted as a keyword argument in the format ``key=val``. That
    processing can be bypassed in order to pass an equal sign through to the
    remote shell command by manually specifying the kwarg:

        salt '*' cmd.run cmd='sed -e s/=/:/g'
```

## pkg module

```buildoutcfg
[mc@salt-master ~]$ salt '*' sys.list_functions pkg
ubuntu-srv-salt-minion-02.home.lab:
    - pkg.add_repo_key
    - pkg.autoremove
    - pkg.available_version
    - pkg.del_repo
    - pkg.del_repo_key
    - pkg.expand_repo_def
    - pkg.file_dict
    - pkg.file_list
    - pkg.get_repo
    - pkg.get_repo_keys
    - pkg.get_selections
    - pkg.hold
    - pkg.info_installed
    - pkg.install
    - pkg.latest_version
    - pkg.list_pkgs
    - pkg.list_repo_pkgs
    - pkg.list_repos
    - pkg.list_upgrades
    - pkg.mod_repo
    - pkg.owner
    - pkg.purge
    - pkg.refresh_db
    - pkg.remove
    - pkg.set_selections
    - pkg.show
    - pkg.unhold
    - pkg.upgrade
    - pkg.upgrade_available
    - pkg.version
    - pkg.version_cmp
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
```
```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions pkg | grep available
    - pkg.available_version
    - pkg.upgrade_available
```
```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions pkg | grep install
    - pkg.group_install
    - pkg.groupinstall
    - pkg.info_installed
    - pkg.install
    - pkg.list_installed_patches
```
```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions pkg | grep remove
    - pkg.remove
```
### pkg.available_version

```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.available_version vim
ubuntu-srv-salt-minion-02.home.lab:
    2:8.0.1453-1ubuntu1
centos-srv-salt-minion-01.home.lab:
```
```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.available_version vim-enhanced
ubuntu-srv-salt-minion-02.home.lab:
centos-srv-salt-minion-01.home.lab:
    2:7.4.160-5.el7
```
```buildoutcfg
[mc@salt-master ~]$ salt '*' sys.doc pkg.available_version 
pkg.available_version:

This function is an alias of ``latest_version``.

    Return the latest version of the named package available for upgrade or
    installation. If more than one package name is specified, a dict of
    name/version pairs is returned.

    If the latest version of a given package is already installed, an empty
    string will be returned for that package.

    A specific repo can be requested using the ``fromrepo`` keyword argument,
    and the ``disableexcludes`` option is also supported.

    New in version 2014.7.0
        Support for the ``disableexcludes`` option

    CLI Example:

        salt '*' pkg.latest_version <package name>
        salt '*' pkg.latest_version <package name> fromrepo=epel-testing
        salt '*' pkg.latest_version <package name> disableexcludes=main
        salt '*' pkg.latest_version <package1> <package2> <package3> ...
    
```
```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.available_version vim vim-enhanced
ubuntu-srv-salt-minion-02.home.lab:
    ----------
    vim:
        2:8.0.1453-1ubuntu1
    vim-enhanced:
centos-srv-salt-minion-01.home.lab:
    ----------
    vim:
    vim-enhanced:
        2:7.4.160-5.el7
```

### pkg.install
```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.install vim vim-enhanced
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

### pkg.remove
```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.remove vim vim-enhanced
ubuntu-srv-salt-minion-02.home.lab:
    Passed invalid arguments to pkg.remove: 'NoneType' object is not iterable
    
        .. versionchanged:: 2015.8.12,2016.3.3,2016.11.0
            On minions running systemd>=205, `systemd-run(1)`_ is now used to
            isolate commands which modify installed packages from the
            ``salt-minion`` daemon's control group. This is done to keep systemd
            from killing any apt-get/dpkg commands spawned by Salt when the
            ``salt-minion`` service is restarted. (see ``KillMode`` in the
            `systemd.kill(5)`_ manpage for more information). If desired, usage of
            `systemd-run(1)`_ can be suppressed by setting a :mod:`config option
            <salt.modules.config.get>` called ``systemd.scope``, with a value of
            ``False`` (no quotes).
    
        .. _`systemd-run(1)`: https://www.freedesktop.org/software/systemd/man/systemd-run.html
        .. _`systemd.kill(5)`: https://www.freedesktop.org/software/systemd/man/systemd.kill.html
    
        Remove packages using ``apt-get remove``.
    
        name
            The name of the package to be deleted.
    
    
        Multiple Package Options:
    
        pkgs
            A list of packages to delete. Must be passed as a python list. The
            ``name`` parameter will be ignored if this option is passed.
    
        .. versionadded:: 0.16.0
    
    
        Returns a dict containing the changes.
    
        CLI Example:
    
        .. code-block:: bash
    
            salt '*' pkg.remove <package name>
            salt '*' pkg.remove <package1>,<package2>,<package3>
            salt '*' pkg.remove pkgs='["foo", "bar"]'
        
centos-srv-salt-minion-01.home.lab:
    Passed invalid arguments to pkg.remove: 'NoneType' object is not iterable
    
        .. versionchanged:: 2015.8.12,2016.3.3,2016.11.0
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
    
        Remove packages
    
        name
            The name of the package to be removed
    
    
        Multiple Package Options:
    
        pkgs
            A list of packages to delete. Must be passed as a python list. The
            ``name`` parameter will be ignored if this option is passed.
    
        .. versionadded:: 0.16.0
    
    
        Returns a dict containing the changes.
    
        CLI Example:
    
        .. code-block:: bash
    
            salt '*' pkg.remove <package name>
            salt '*' pkg.remove <package1>,<package2>,<package3>
            salt '*' pkg.remove pkgs='["foo", "bar"]'
        
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*' pkg.remove vim,vim-enhanced
centos-srv-salt-minion-01.home.lab:
    ----------
    vim-enhanced:
        ----------
        new:
        old:
            2:7.4.160-5.el7
ubuntu-srv-salt-minion-02.home.lab:
    ----------
    vim:
        ----------
        new:
        old:
            2:8.0.1453-1ubuntu1
```

### pkg.list_pkgs
```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.list_pkgs
ubuntu-srv-salt-minion-02.home.lab:
    ----------
    accountsservice:
        0.6.45-1ubuntu1
    acl:
        2.2.52-3build1
    acpid:
        1:2.0.28-1ubuntu1
    adduser:
...
centos-srv-salt-minion-01.home.lab:
    ----------
    GeoIP:
        1.5.0-13.el7
    NetworkManager:
        1:1.12.0-6.el7
    NetworkManager-libnm:
        1:1.12.0-6.el7
    NetworkManager-team:
        1:1.12.0-6.el7
    NetworkManager-tui:
        1:1.12.0-6.el7
```

```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.list_pkgs | grep zip
    bzip2:
    gzip:
    bzip2-libs:
    gzip:
```
```buildoutcfg
[mc@salt-master ~]$ salt '*' pkg.list_pkgs | grep -E "zip|minion"
ubuntu-srv-salt-minion-02.home.lab:
    bzip2:
    gzip:
    salt-minion:
centos-srv-salt-minion-01.home.lab:
    bzip2-libs:
    gzip:
    salt-minion:
```

## user module
```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.doc user.add
user.add:

    Add a user to the minion

    CLI Example:

        salt '*' user.add name <uid> <gid> <groups> <home> <shell>
    

[mc@salt-master ~]$ salt '*minion-01*' cmd.run 'ls -lah' runas=tom
centos-srv-salt-minion-01.home.lab:
    ERROR: User 'tom' is not available
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 10000 10000  tom /home/tom /bin/bash
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 10000 10000 tom '/home/tom' '/bin/bash'
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 
centos-srv-salt-minion-01.home.lab:
    True
[mc@salt-master ~]$ salt '*minion-01*' cmd.run 'ls -lah' runas=tom
centos-srv-salt-minion-01.home.lab:
    total 12K
    drwx------. 2 tom  tom   62 Mar  3 02:47 .
    drwxr-xr-x. 4 root root  27 Mar  3 02:47 ..
    -rw-r--r--. 1 tom  tom   18 Oct 30 13:07 .bash_logout
    -rw-r--r--. 1 tom  tom  193 Oct 30 13:07 .bash_profile
    -rw-r--r--. 1 tom  tom  231 Oct 30 13:07 .bashrc
[mc@salt-master ~]$ salt '*minion-01*' user.remove tom 
centos-srv-salt-minion-01.home.lab:
    'user.remove' is not available.
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.del tom 
centos-srv-salt-minion-01.home.lab:
    ----------
    user.del:
        'user.del' is not available.
    user.delete:
        
            Remove a user from the minion
        
            CLI Example:
        
                salt '*' user.delete name remove=True force=True
            
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.delete tom 
centos-srv-salt-minion-01.home.lab:
    True
[mc@salt-master ~]$ salt '*minion-01*' cmd.run 'ls -lah' runas=tom
centos-srv-salt-minion-01.home.lab:
    ERROR: User 'tom' is not available
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 10000 10000 /home/tom /bin/bash
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 10000 10000 '/home/tom' '/bin/bash'
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 1000 1000 '/home/tom' '/bin/bash'
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 1002 1002 '/home/tom' '/bin/bash'
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.add tom 
centos-srv-salt-minion-01.home.lab:
    True
[mc@salt-master ~]$ salt '*minion-01*' cmd.run 'grep tom /etc/passwd' runas=tom
centos-srv-salt-minion-01.home.lab:
    tom:x:1001:1001::/home/tom:/bin/bash
[mc@salt-master ~]$ salt '*minion-01*' sys.doc user.add
user.add:

    Add a user to the minion

    CLI Example:

        salt '*' user.add name <uid> <gid> <groups> <home> <shell>
    

[mc@salt-master ~]$ salt '*minion-01*' user.add jerry 1002 1002
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*minion-01*' user.info tom
centos-srv-salt-minion-01.home.lab:
    ----------
    fullname:
    gid:
        1001
    groups:
        - tom
    home:
        /home/tom
    homephone:
    name:
        tom
    other:
    passwd:
        x
    roomnumber:
    shell:
        /bin/bash
    uid:
        1001
    workphone:
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions user
centos-srv-salt-minion-01.home.lab:
    - user.add
    - user.chfullname
    - user.chgid
    - user.chgroups
    - user.chhome
    - user.chhomephone
    - user.chloginclass
    - user.chother
    - user.chroomnumber
    - user.chshell
    - user.chuid
    - user.chworkphone
    - user.delete
    - user.get_loginclass
    - user.getent
    - user.info
    - user.list_groups
    - user.list_users
    - user.primary_group
    - user.rename
[mc@salt-master ~]$ salt '*minion-01*' sys.doc user.chshell
user.chshell:

    Change the default shell of the user

    CLI Example:

        salt '*' user.chshell foo /bin/zsh
    

[mc@salt-master ~]$ salt '*minion-01*' user.chshell tom /bin/nologin
centos-srv-salt-minion-01.home.lab:
    True
[mc@salt-master ~]$ salt '*minion-01*' cmd.run 'grep tom /etc/passwd' runas=tom
centos-srv-salt-minion-01.home.lab:
    tom:x:1001:1001::/home/tom:/bin/nologin
[mc@salt-master ~]$ ssh minion-01
Last login: Sun Mar  3 01:58:42 2019 from salt-master.home.lab
[mc@centos-srv-salt-minion-01 ~]$ sudo su
[root@centos-srv-salt-minion-01 mc]# su - tom
Last login: Sun Mar  3 02:54:00 EST 2019
su: failed to execute /bin/nologin: No such file or directory
[root@centos-srv-salt-minion-01 mc]# exit
exit
[mc@centos-srv-salt-minion-01 ~]$ ls
[mc@centos-srv-salt-minion-01 ~]$ exit
logout
Connection to minion-01 closed.
[mc@salt-master ~]$ salt '*minion-01*' user.chshell tom /bin/bash
centos-srv-salt-minion-01.home.lab:
    True
[mc@salt-master ~]$ ssh minion-01
Last login: Sun Mar  3 02:54:08 2019 from salt-master.home.lab
[mc@centos-srv-salt-minion-01 ~]$ sudo su
[root@centos-srv-salt-minion-01 mc]# su - tom
Last login: Sun Mar  3 02:54:16 EST 2019 on pts/0
[tom@centos-srv-salt-minion-01 ~]$ exit
logout
[root@centos-srv-salt-minion-01 mc]# exit
exit
[mc@centos-srv-salt-minion-01 ~]$ exit
logout
Connection to minion-01 closed.
[mc@salt-master ~]$ salt '*' user.add tom jerry
centos-srv-salt-minion-01.home.lab:
    False
ubuntu-srv-salt-minion-02.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*' user.add tom,jerry
ubuntu-srv-salt-minion-02.home.lab:
    False
centos-srv-salt-minion-01.home.lab:
    False
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*' user.add tom
centos-srv-salt-minion-01.home.lab:
    False
ubuntu-srv-salt-minion-02.home.lab:
    True
ERROR: Minions returned with non-zero exit code
[mc@salt-master ~]$ salt '*' user.add jerry
centos-srv-salt-minion-01.home.lab:
    True
ubuntu-srv-salt-minion-02.home.lab:
    True
[mc@salt-master ~]$ salt '*' cmd.run 'grep -E "tom|jerry" /etc/passwd'
centos-srv-salt-minion-01.home.lab:
    tom:x:1001:1001::/home/tom:/bin/bash
    jerry:x:1002:1002::/home/jerry:/bin/bash
ubuntu-srv-salt-minion-02.home.lab:
    tom:x:1001:1001::/home/tom:/bin/sh
    jerry:x:1002:1002::/home/jerry:/bin/sh
[mc@salt-master ~]$ 

```

## saltutil module

```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' sys.list_functions saltutil
centos-srv-salt-minion-01.home.lab:
    - saltutil.clear_cache
    - saltutil.clear_job_cache
    - saltutil.cmd
    - saltutil.cmd_iter
    - saltutil.find_cached_job
    - saltutil.find_job
    - saltutil.is_running
    - saltutil.kill_all_jobs
    - saltutil.kill_job
    - saltutil.list_extmods
    - saltutil.mmodule
    - saltutil.pillar_refresh
    - saltutil.refresh_beacons
    - saltutil.refresh_grains
    - saltutil.refresh_matchers
    - saltutil.refresh_modules
    - saltutil.refresh_pillar
    - saltutil.regen_keys
    - saltutil.revoke_auth
    - saltutil.runner
    - saltutil.running
    - saltutil.signal_job
    - saltutil.sync_all
    - saltutil.sync_beacons
    - saltutil.sync_clouds
    - saltutil.sync_engines
    - saltutil.sync_grains
    - saltutil.sync_log_handlers
    - saltutil.sync_matchers
    - saltutil.sync_modules
    - saltutil.sync_output
    - saltutil.sync_outputters
    - saltutil.sync_pillar
    - saltutil.sync_proxymodules
    - saltutil.sync_renderers
    - saltutil.sync_returners
    - saltutil.sync_sdb
    - saltutil.sync_serializers
    - saltutil.sync_states
    - saltutil.sync_thorium
    - saltutil.sync_utils
    - saltutil.term_all_jobs
    - saltutil.term_job
    - saltutil.update
    - saltutil.wheel
```
```buildoutcfg
[mc@salt-master ~]$ salt '*' saltutil.sync_all
ubuntu-srv-salt-minion-02.home.lab:
    ----------
    beacons:
    clouds:
    engines:
    grains:
    log_handlers:
    matchers:
    modules:
    output:
    proxymodules:
    renderers:
    returners:
    sdb:
    serializers:
    states:
    thorium:
    utils:
centos-srv-salt-minion-01.home.lab:
    ----------
    beacons:
    clouds:
    engines:
    grains:
    log_handlers:
    matchers:
    modules:
    output:
    proxymodules:
    renderers:
    returners:
    sdb:
    serializers:
    states:
    thorium:
    utils:
```

From other terminal
```buildoutcfg
[mc@salt-master ~]$ salt '*minion-01*' cmd.run 'sleep 600'
```
on master server 
```buildoutcfg
[mc@salt-master ~]$ salt '*' saltutil.running
centos-srv-salt-minion-01.home.lab:
    |_
      ----------
      arg:
          - sleep 600
      fun:
          cmd.run
      jid:
          20190315154355276910
      pid:
          11290
      ret:
      tgt:
          *minion-01*
      tgt_type:
          glob
      user:
          mc
ubuntu-srv-salt-minion-02.home.lab:
[mc@salt-master ~]$ salt '*' saltutil.kill_job 20190315154355276910
ubuntu-srv-salt-minion-02.home.lab:
centos-srv-salt-minion-01.home.lab:
    Signal 9 sent to job 20190315154355276910 at pid 11290
[mc@salt-master ~]$ salt '*' saltutil.running
ubuntu-srv-salt-minion-02.home.lab:
centos-srv-salt-minion-01.home.lab:
[mc@salt-master ~]$ 
```

after we kill jid
```buildoutcfg
centos-srv-salt-minion-01.home.lab:
    Minion did not return. [No response]
[mc@salt-master ~]$ 
```

# Salt states
https://docs.saltstack.com/en/latest/ref/states/all/
```buildoutcfg
...
#
file_roots:
  base:
    - /srv/salt
#
...
```

## The Top file

```buildoutcfg
[mc@salt-master salt]$ tree /srv/salt/
/srv/salt/
├── apache2.sls
├── common-tools.sls
├── httpd.sls
├── top.sls
├── vim-enhanced.sls
└── vim.sls

```

```buildoutcfg
[mc@salt-master ~]$ sudo mkdir -p /srv/salt
[mc@salt-master ~]$ sudo chown mc -R /srv/salt
[mc@salt-master ~]$ touch /srv/salt/top.sls
```

```buildoutcfg
[mc@salt-master salt]$ cat top.sls 
base:
  '*':
    - common-tools
  'G@os:Centos':
    - vim-enhanced
    - httpd
  'G@os:Ubuntu':
    - vim
    - apache2
```

```buildoutcfg
[mc@salt-master salt]$ cat common-tools.sls 
common-tools:
  pkg.installed:
    - pkgs:
      - curl
      - wget
      - unzip
      - git
      - screen
      - net-tools
```
```buildoutcfg
[mc@salt-master salt]$ cat vim-enhanced.sls 
vim:
  pkg.installed:
    - pkgs:
      - vim-enhanced
``` 
```buildoutcfg
[mc@salt-master salt]$ cat vim.sls 
vim:
  pkg.installed:
    - pkgs:
      - vim
``` 

```buildoutcfg
[mc@salt-master salt]$ cat httpd.sls 
httpd:
  pkg.installed:
    - pkgs:
      - httpd
```

```buildoutcfg
service httpd start:
  service.running:
    - name: httpd
    - enable: True
    - require:
      - pkg: httpd

firewalld allow port 80:
  firewalld.present:
    - name: public
    - ports:
      - 80/tcp
```

```buildoutcfg
[mc@salt-master salt]$ cat apache2.sls 
apache2:
  pkg.installed:
    - pkgs:
      - apache2
```

```buildoutcfg
[mc@salt-master salt]$ cat dev/top.sls 
dev:
  '*minion-01*': 
    - states.db
  '*minion-02*':
    - states.web
```

```buildoutcfg
[mc@salt-master salt]$ cat dev/states/db.sls 
mariadb-server:
  pkg.installed:
    - pkgs:
      - mariadb-server
```

```buildoutcfg
[mc@salt-master salt]$ cat dev/states/web.sls 
nginx:
  pkg.installed:
    - pkgs:
      - nginx
```

## Understanding YAML

The default renderer for SLS files is the YAML renderer. YAML is a markup language with many powerful features. However, Salt uses a small subset of YAML that maps over very commonly used data structures, like lists and dictionaries. It is the job of the YAML renderer to take the YAML data structure and compile it into a Python data structure for use by Salt.

Though YAML syntax may seem daunting and terse at first, there are only three very simple rules to remember when writing YAML for SLS files.

### Rule One: Indentation

YAML uses a fixed indentation scheme to represent relationships between data layers. 

Salt requires that the indentation for each level consists of exactly two spaces. Do not use tabs.

### Rule Two: Colons

Python dictionaries are, of course, simply key-value pairs. Users from other languages may recognize this data type as hashes or associative arrays.

Dictionary keys are represented in YAML as strings terminated by a trailing colon. Values are represented by either a string following the colon, separated by a space:

YAML: 
```buildoutcfg
my_key: my_value
```

Python: 
```buildoutcfg
{'my_key': 'my_value'}
```

json: 

YAML: 
```buildoutcfg
my_key:
  my_value
```

Python: 
```buildoutcfg
{'my_key': 'my_value'}
```

YAML: 
```buildoutcfg
first_level_dict_key:
  second_level_dict_key: value_in_second_level_dict
```

Python: 
```buildoutcfg
{'first_level_dict_key': {'second_level_dict_key': 'value_in_second_level_dict'}}
```

json:
```buildoutcfg
{
  "first_level_dict_key": {
    "second_level_dict_key": "value_in_second_level_dict"
  }
}
```

### Rule Three: Dashes

To represent lists of items, a single dash followed by a space is used. Multiple items are a part of the same list as a function of their having the same level of indentation.

YAML: 
```buildoutcfg
my_dictionary:
  - list_value_one
  - list_value_two
  - list_value_three
```

Python: 
```buildoutcfg
{'my_dictionary': ['list_value_one', 'list_value_two', 'list_value_three']}
```
 
json: 
```buildoutcfg
{
  "my_dictionary": [
    "list_value_one", 
    "list_value_two", 
    "list_value_three"
  ]
}
``` 
 
 
 



### Learning More

One easy way to learn more about how YAML gets rendered into Python data structures is to use an online YAML parser to see the Python output.

One excellent choice for experimenting with YAML parsing is: http://yaml-online-parser.appspot.com/


## Understanding Jinja

Jinja is the default templating language in SLS files.

Jinja in States
https://cryptic-cliffs-32040.herokuapp.com/
http://jinja.quantprogramming.com/


Jinja is evaluated before YAML, which means it is evaluated before the States are run.

*Example 1.*

YAML:
```buildoutcfg
student_name: Goku
course_name: Salt Stack
provided_by: https://monkeycourses.com
```

Jinja Template:
```buildoutcfg
Welcome {{ student_name }},

Welcome to {{ course_name }} provided by {{ provided_by }}, let's learn!

Thanks
```

*Example 2.*

YAML:
```buildoutcfg
student_name: Goku
student_active: true
course_name: Salt Stack
provided_by: https://monkeycourses.com
support_email: info [at] monkeycourses.com
```

Jinja Template:
```buildoutcfg
Welcome {{ student_name }},

{% if student_active %}
    Welcome to {{ course_name }} provided by {{ provided_by }}, let's learn!
{% elif not student_active %}
    Oh, you account is locked! Please contact support at
 {{ support_email }}! 
{% endif %}

Thanks
```

*Example 3.*

YAML:
```buildoutcfg
grains:
  { 'os': 'Debian' }
```

Jinja Template:
```buildoutcfg
{% if grains['os'] != 'FreeBSD' %}
tcsh:
    pkg:
        - installed
{% endif %}

motd:
  file.managed:
    {% if grains['os'] == 'FreeBSD' %}
    - name: /etc/motd
    {% elif grains['os'] == 'Debian' %}
    - name: /etc/motd.tail
    {% endif %}
    - source: salt://motd
```

*Example 6.*
YAML:
```buildoutcfg
grains:
  { 'os': 'Debian' }
```

```buildoutcfg
{% set motd = ['/etc/motd'] %}
{% if grains['os'] == 'Debian' %}
  {% set motd = ['/etc/motd.tail', '/var/run/motd'] %}
{% endif %}

{% for motdfile in motd %}
{{ motdfile }}:
  file.managed:
    - source: salt://motd
{% endfor %}
```
students:
  - {'name': 'Goku', 'student_active': false}
  - {'name': 'Krilin', 'student_active': true}
  - {'name': 'Picolo', 'student_active': true}

course_name: '"Salt Stack From Ground To Cloud"'
provided_by: https://monkeycourses.com
support_email: info [@] monkeycourses.com

{% for student in students %}

Hi {{ student.name }},

{% if student.student_active %}
Welcome to {{ course_name }} course provided by {{ provided_by }}, let's learn!
{% elif not student.student_active %}
Oh, your account is locked! Please contact support at {{ support_email }} !!!
{% endif %}
Thanks
{% endfor %}

