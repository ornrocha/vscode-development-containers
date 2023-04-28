###########################################################
### Load Python  image and install required packages    ###
###########################################################

ARG IMAGE_PYTHON_VERSION=3.10
ARG BASE_PYTHON_TAG="$IMAGE_PYTHON_VERSION-slim-bullseye"

FROM python:${BASE_PYTHON_TAG} AS base

LABEL maintainer="Orlando Rocha <ornrocha@gmail.com>"

ENV OPENJDK_VERSION="11"

RUN apt-get update -y && export DEBIAN_FRONTEND=noninteractive \
    &&  apt-get install -y --no-install-recommends \
    build-essential \
    apt-transport-https \
    sudo \
    nano \
    wget \
    git \
    curl \
    gnupg2 \
    openssh-client \
    "openjdk-${OPENJDK_VERSION}-jre-headless" \
    ca-certificates-java \
    unzip \
    && apt-get autoremove -y \ 
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*


###################################################
### Add user and create user home               ###
###################################################       

COPY ./resources/scripts/create_user.sh /tmp/create_user.sh
RUN /bin/bash /tmp/create_user.sh  "devuser" "1000" "1000"

######################################################
### Create a base python environment               ###
######################################################   

ENV VENV_NAME="devenv" \
    VENV_SITE_PACKAGES="/home/devuser/devenv/lib/python$IMAGE_PYTHON_VERSION/site-packages" \
    DEVELOPMENT_FOLDER=/home/devuser/workspace \
    EXTENSION_PYTHONPATH=/home/devuser/external_pythonpath \
    JAVA_HOME="/usr/lib/jvm/java-$OPENJDK_VERSION-openjdk-amd64" \
    GIT_EMAIL=${GIT_EMAIL:-"default"} \
    GIT_USERNAME=${GIT_USERNAME:-"default"} \
    JUPYTER_PORT=${JUPYTER_PORT:-8888} \
    PATH=$PATH:/home/devuser/.scripts


COPY ./resources/scripts/check_ssh_conf.sh /home/devuser/.scripts/check_ssh_conf.sh
COPY ./resources/scripts/print_ssh_key.sh /home/devuser/.scripts/print_ssh_key.sh
COPY ./resources/scripts/jupyter_config.sh /home/devuser/.scripts/jupyter_config.sh

RUN mkdir -p $DEVELOPMENT_FOLDER && chown -R devuser:devuser $DEVELOPMENT_FOLDER \
    && mkdir $EXTENSION_PYTHONPATH && chown -R devuser:devuser $EXTENSION_PYTHONPATH \
    && chmod -R +x /home/devuser/.scripts \
    && chown -R devuser:devuser /home/devuser/.scripts \
    && mkdir -p /home/devuser/.ssh && chown -R devuser:devuser /home/devuser/.ssh \
    && mkdir -p /mnt/data && chown -R devuser:devuser /mnt/data \
    && echo 'export JAVA_HOME="/usr/lib/jvm/java-'$OPENJDK_VERSION'-openjdk-amd64"' >> /home/devuser/.bashrc \
    && echo 'export JRE_HOME="/usr/lib/jvm/java-'$OPENJDK_VERSION'-openjdk-amd64/jre/"' >> /home/devuser/.bashrc \
    && echo 'export PATH="$PATH:$JAVA_HOME/bin:/home/devuser/devenv/bin"' >> /home/devuser/.bashrc \
    && echo 'export PYTHONPATH="$PYTHONPATH:'$EXTENSION_PYTHONPATH'"' >> /home/devuser/.bashrc \
    && echo "source /home/devuser/devenv/bin/activate" >> /home/devuser/.bashrc  
    
  


USER devuser
WORKDIR /home/devuser

RUN python -m venv devenv \
    && devenv/bin/pip install --no-cache-dir -U pip setuptools wheel notebook ipykernel black pylint \
    && /home/devuser/devenv/bin/python3 -m ipykernel install --user --name=devenv \
    && set -ex;  \
    find /home/devuser/devenv -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name __pycache__ \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.exe' \) \) \
        \) -exec rm -rf '{}' +;


VOLUME /home/devuser/workspace /mnt/data

######################################################
### Create a Python dev environment                ###
###################################################### 
FROM base AS pythondevenv

ENV WITH_SPARK_KERNEL=0

COPY ./resources/scripts/local_mode/start.sh /home/devuser/.scripts/start.sh 


USER root

RUN /bin/bash /home/devuser/.scripts/jupyter_config.sh \   
    && chmod -R +x /home/devuser/.scripts/init_jupyter_spark.sh \
    && chmod -R +x /home/devuser/.scripts/start.sh

EXPOSE $JUPYTER_PORT

WORKDIR /home/devuser/workspace
USER devuser

CMD ["start.sh"]

######################################################
### Create a base spark environment                ###
######################################################  

FROM base AS sparkbase

ARG SPARK_VERSION="3.3.2"
ARG HADOOP_VERSION="3"
ARG IMAGE_PYTHON_VERSION=$IMAGE_PYTHON_VERSION

ENV SPARK_HOME="/opt/spark" \
    PYSPARK_PYTHON="/home/devuser/devenv/bin/python" \
    PYSPARK_DRIVER_PYTHON="/home/devuser/devenv/bin/python" \
    JUPYTER_SPARk_MEMORY=${JUPYTER_SPARk_MEMORY:-2g} \
    JUPYTER_SPARK_CORES=${JUPYTER_SPARK_CORES:-2} \
    SPARK_EXECUTOR_MEMORY=${SPARK_EXECUTOR_MEMORY:-2g} \ 
    SPARK_MASTER_HOST=${SPARK_MASTER_HOST:-spark-master} \
    SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-7077} \
    SPARK_EVENT_LOG=/opt/spark/spark-events

USER root

RUN mkdir /home/devuser/.spark_jars && chown -R devuser:devuser /home/devuser/.spark_jars \
    && echo 'export SPARK_HOME="/opt/spark"' >> /home/devuser/.bashrc \
    && echo 'export PATH="$PATH:/opt/spark/bin:/opt/spark/sbin"' >> /home/devuser/.bashrc \
    && echo 'export PYSPARK_PYTHON="/home/devuser/devenv/bin/python"' >> /home/devuser/.bashrc \
    && echo 'export PYSPARK_DRIVER_PYTHON="/home/devuser/devenv/bin/python"' >> /home/devuser/.bashrc \
    && mkdir -p "/home/devuser/devenv/lib/python$IMAGE_PYTHON_VERSION/site-packages/pyspark" \
    && mkdir -p "/home/devuser/devenv/lib/python$IMAGE_PYTHON_VERSION/site-packages/py4j" \
    && chown -R devuser:devuser "/home/devuser/devenv/lib/python$IMAGE_PYTHON_VERSION/site-packages/pyspark" \
    && chown -R devuser:devuser "/home/devuser/devenv/lib/python$IMAGE_PYTHON_VERSION/site-packages/py4j" \
    && /bin/bash /home/devuser/.scripts/jupyter_config.sh \
    && chmod -R +x /home/devuser/.scripts/init_jupyter_spark.sh


RUN wget -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
    && mkdir -p /opt/spark \
    && tar -xzf apache-spark.tgz -C /opt/spark --strip-components=1 \
    && rm apache-spark.tgz \
    && cd /opt/spark/python/lib \
    && PYJ="$(echo py4j*)" \
    && unzip '/opt/spark/python/lib/'$PYJ -d '/opt/spark/python/' \
    && mkdir -p /opt/spark/spark-events \
    && chown -R devuser:devuser /opt/spark/spark-events \
    && cp -R /opt/spark/python/pyspark/*  "/home/devuser/devenv/lib/python$IMAGE_PYTHON_VERSION/site-packages/pyspark" \
    && cp -R /opt/spark/python/py4j/* "/home/devuser/devenv/lib/python$IMAGE_PYTHON_VERSION/site-packages/py4j"


VOLUME /home/devuser/.spark_jars 

############################################################
### Create image of spark in local mode                  ###
############################################################  
FROM sparkbase AS sparklocal

COPY ./resources/spark/local/spark-defaults.conf /opt/spark/conf/spark-defaults.conf
COPY ./resources/spark/local/spark-env.sh /opt/spark/conf/spark-env.sh
COPY ./resources/scripts/local_mode/start.sh /home/devuser/.scripts/start.sh 


RUN chmod -R +x /home/devuser/.scripts/start.sh \
    && chown -R devuser:devuser /opt/spark

WORKDIR /home/devuser/workspace
USER devuser

        
EXPOSE 4040

CMD ["start.sh"]


###########################################################
### Create image for spark as a worker                 ###
###########################################################

FROM sparkbase as sparkworker

WORKDIR /opt/spark

ENV SPARK_WORKLOAD="worker" \
    SPARK_MASTER=spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT

COPY ./resources/spark/standalone/spark-defaults.conf /opt/spark/conf/spark-defaults.conf
COPY ./resources/spark/standalone/spark-env.sh /opt/spark/conf/spark-env.sh
COPY ./resources/spark/standalone/start-spark.sh /opt/spark/start-spark.sh    

RUN chmod -R +x /opt/spark/start-spark.sh \
    && mkdir /home/devuser/.spark_local_dir \
    && chown -R devuser:devuser /home/devuser/.spark_local_dir \
    && chown -R devuser:devuser /opt/spark

    
EXPOSE 8081

USER devuser

CMD ["/bin/bash", "/opt/spark/start-spark.sh"]

###########################################################
### Create image for spark as a worker                 ###
###########################################################
FROM sparkbase as sparkhistory

WORKDIR /opt/spark

ENV SPARK_WORKLOAD="history" \
    HISTORY_CLEANER_INTERVAL=${HISTORY_CLEANER_INTERVAL:-1d} \
    HISTORY_MAX_AGE=${HISTORY_MAX_AGE:-7d}

COPY ./resources/spark/standalone/spark-defaults.conf /opt/spark/conf/spark-defaults.conf
COPY ./resources/spark/standalone/spark-env.sh /opt/spark/conf/spark-env.sh
COPY ./resources/spark/standalone/start-spark.sh /opt/spark/start-spark.sh 

RUN chmod -R +x /opt/spark/start-spark.sh \
    && mkdir /home/devuser/.spark_local_dir \
    && chown -R devuser:devuser /home/devuser/.spark_local_dir \
    && chown -R devuser:devuser /opt/spark

EXPOSE 18080

USER devuser

CMD ["/bin/bash", "/opt/spark/start-spark.sh"]



################################################################
### Create a base configuration to spark in standalone mode  ###
################################################################  
FROM sparkbase AS sparkstandalone

ENV SPARK_MASTER_PORT=7077 \
    SPARK_MASTER=spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT \
    SPARK_WORKLOAD="master"

USER root

COPY ./resources/spark/standalone/spark-defaults.conf /opt/spark/conf/spark-defaults.conf
COPY ./resources/spark/standalone/spark-env.sh /opt/spark/conf/spark-env.sh
COPY ./resources/spark/standalone/start-spark.sh /opt/spark/start-spark.sh
COPY ./resources/scripts/standalone_mode/start.sh /home/devuser/.scripts/start.sh  

RUN echo 'export PYSPARK_SUBMIT_ARGS="--master '$SPARK_MASTER' pyspark-shell"' >> /home/devuser/.bashrc \
    && mkdir /home/devuser/.spark_local_dir \
    && chown -R devuser:devuser /home/devuser/.spark_local_dir \
    && chmod -R +x /home/devuser/.scripts/start.sh \
    && chmod -R +x /opt/spark/start-spark.sh \
    && chown -R devuser:devuser /opt/spark


EXPOSE 8080 7077 6066 4040 4041

WORKDIR /home/devuser/workspace
USER devuser


CMD ["start.sh"]    