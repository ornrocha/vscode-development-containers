#!/bin/sh



/home/devuser/.scripts/check_ssh_conf.sh -u "$GIT_USERNAME" -e "$GIT_EMAIL"


if [ -f /home/devuser/workspace/requirements.txt ]; then
	/home/devuser/devenv/bin/pip install --no-cache-dir -r /home/devuser/workspace/requirements.txt
fi


if [ -f /home/devuser/.ssh/id_rsa ]; then
	eval `ssh-agent -s` && ssh-add /home/devuser/.ssh/id_rsa
fi


echo "container started"
init_jupyter_spark.sh &
trap : TERM INT; sleep infinity & wait

