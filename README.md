# Introduction

This repository contains all the ansible configuration needed to configure three vault instances running as a HA cluster, two percona servers running replication with failover, and a front-end wordpress + civicrm website

# Execution

1. Ensure that you have ssh access to the server and that you can sudo as your user
2. Ensure that you have ansible installed locally or wherever you are running this from.
3. Update the production file with the information about which groups the new server should be associated and which roles it will execute
4. Run ansible-galaxy collection install community.mysql
5. Follow the documentation [here](https://lab.jmaconsulting.biz/jma/civipress/civipress/-/wikis/200_Automated_Scripts) to proceed with the installation
