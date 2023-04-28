#!/bin/bash


/home/devuser/.scripts/check_ssh_conf.sh -u "$GIT_USERNAME" -e "$GIT_EMAIL"


if [ -f /home/devuser/.ssh/id_rsa ]; then
	eval `ssh-agent -s` && ssh-add /home/devuser/.ssh/id_rsa
fi

if [ $DISABLE_JUPYTER = 0 ]; then
    echo "Jupyter enabled"
	if [ -f /home/devuser/.scripts/init_jupyter_spark.sh ]; then
			init_jupyter_spark.sh &
	fi
else
   echo "Jupyter disabled"
fi 


echo "container started"

# Remove old spark dir content
if [ -d /home/devuser/.spark_local_dir ]; then
	rm -r /home/devuser/.spark_local_dir/*
fi 

/bin/bash /opt/spark/start-spark.sh

