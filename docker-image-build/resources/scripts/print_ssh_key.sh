#!/bin/sh

if [ -f /home/devuser/.ssh/id_rsa.pub ]; then
   cat /home/devuser/.ssh/id_rsa.pub
else
   echo "The ssh keys have not yet been configured.\n They can be configured by running the following command:"
   echo "check_ssh_conf.sh -u [username] -e [email]"
   echo "Or by setting up the environmental variables GIT_USERNAME and GIT_EMAIL in .env file."

fi
