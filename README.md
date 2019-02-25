Install and configure Salt
=================================

Installation:

Bootstrap:
wget -O -- http://bootstrap.saltstack.org | sudo sh
or
cd /tmp
curl -L https://bootstarp.saltstack.com -o install_salt.sh
sudo sh install_salt.sh git develop
or 
python -m urlib “https://bootstap.saltstack.com” | sudo sh -s --  git develop
