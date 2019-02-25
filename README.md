Install and configure Salt
=================================

Installation:

Install using wget

Using wget to install your distribution's stable packages:

wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh

Installing a specific version from git using wget:

wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -P git v2016.11.5