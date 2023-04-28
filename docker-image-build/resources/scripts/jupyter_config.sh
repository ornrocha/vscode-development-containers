#!/bin/sh

USER_HOME=/home/devuser
VENV_NAME="devenv"
PYTHON_ENV_DIR=/home/devuser/$VENV_NAME
ENV_NAME="devenv"
KERNEL_NAME=$ENV_NAME
JUPYTER_PORT=${JUPYTER_PORT:-8888}
NOTEBOOKS_FOLDER_PATH="$USER_HOME/workspace"
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
SPARK_HOME="/opt/spark"
EXTENSION_PYTHONPATH="/home/devuser/external_pythonpath"
JUPYTER_SPARk_MEMORY=${JUPYTER_SPARk_MEMORY:-2g}
JUPYTER_SPARK_CORES=${JUPYTER_SPARK_CORES:-2}
SPARK_EXECUTOR_MEMORY=${SPARK_EXECUTOR_MEMORY:-2g}
WITH_SPARK_KERNEL=${WITH_SPARK_KERNEL:-1}


KERNEL_DIR=$USER_HOME/.local/share/jupyter/kernels/$KERNEL_NAME


config_kernel()
{
  cd $SPARK_HOME/python/lib && \
     PYJ="$(echo py4j*)" && \
     SPARK_PYTHONPATH="$SPARK_HOME/python"
  

  if [ -d $KERNEL_DIR ]; then 
    	 cat > $KERNEL_DIR/kernel.json << EOF
{
  "argv": [
    "$PYTHON_ENV_DIR/bin/python",
    "-m",
    "ipykernel_launcher",
    "-f",
    "{connection_file}"
  ],
  "display_name": "$ENV_NAME",
  "language": "python",
  "env": {
    "JAVA_HOME": "$JAVA_HOME",
    "SPARK_HOME": "$SPARK_HOME",
    "PYTHONPATH": "$SPARK_PYTHONPATH:$EXTENSION_PYTHONPATH",
    "PYTHONSTARTUP": "$SPARK_HOME/python/pyspark/shell.py",
    "PYSPARK_SUBMIT_ARGS": "--master local[$JUPYTER_SPARK_CORES] --driver-memory $JUPYTER_SPARk_MEMORY --executor-memory $SPARK_EXECUTOR_MEMORY pyspark-shell",
    "PYSPARK_PYTHON": "/home/devuser/$VENV_NAME/bin/python",
    "PYSPARK_DRIVER_PYTHON": "/home/devuser/$VENV_NAME/bin/python"
  }
}
EOF

  else
     echo "Jupyter kernel with name $KERNEL_NAME was not found."
  fi
  
}


create_init_script()
{

cat > $USER_HOME/.scripts/init_jupyter_spark.sh << EOF
#!/bin/bash

source /home/devuser/$VENV_NAME/bin/activate
jupyter notebook --no-browser --ip=\${JUPYTER_ALLOW_ORIGIN:-"0.0.0.0"} --notebook-dir='$NOTEBOOKS_FOLDER_PATH' --NotebookApp.password=\${JUPYTER_PASSWORD:-'sha1:a0189875c3e6:19569451b7c976e58e6476d8ff6b506532708fb7'} --port=\${JUPYTER_PORT:-8888}
EOF


}

config()
{
if [ $WITH_SPARK_KERNEL -eq 1 ];then
  config_kernel
fi
create_init_script
}


config

