#!/bin/bash

## automate process of salt-master configuration changes

## clean previous configuration
sudo rm -rf /srv/*

## copy salt content into /srv
sudo cp -R salt /srv

## copy formulas content into /srv/formulas
sudo cp -R formulas /srv/formulas

## copy pillar content into /srv/pillar
sudo cp -R pillar /srv/pillar

## copy keys content into /etc/salt/keys
sudo cp -R keys/* /etc/salt/keys
sudo chmod 600 /etc/salt/keys/*

## copy cloud content into /etc/salt
sudo cp -R cloud/* /etc/salt

# copy salt master conf into /etc/salt/
sudo cp master /etc/salt/

# restart salt master service and check it status
sudo /etc/init.d/salt-master restart
sudo /etc/init.d/salt-master status
