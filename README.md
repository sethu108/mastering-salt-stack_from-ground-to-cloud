Install and configure Salt
=================================

Check first:
https://repo.saltstack.com/#bootstrap

Installation

BOOTSTRAP - MULTI-PALTFORM

# Install using wget

Using wget to install your distribution's stable packages:

wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh

Installing a specific version from git using wget:

wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -P git v2016.11.5

# Install using curl
On the Salt master

Run these commands on the system that you want to use as the central management point.

curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P -M

Your Salt master can manage itself, so a Salt minion is installed along with the Salt master. If you do not want to install the minion, also pass the -N option.
On each Salt minion

Run these commands on each system that you want to manage using Salt.

curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P

# Fedora
Packages are available in the standard Fedora repositories. Install the salt-minion, salt-master, or other Salt components:

    sudo dnf install salt-master
    sudo dnf install salt-minion
    sudo dnf install salt-ssh
    sudo dnf install salt-syndic
    sudo dnf install salt-cloud
    sudo dnf install salt-api
