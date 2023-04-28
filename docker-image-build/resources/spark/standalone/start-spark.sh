#!/bin/bash

if [ ! -z "$SPARK_MASTER_HOST" ] && [ ! -z "$SPARK_MASTER_PORT" ]; then
   sed -i 's|spark.master[ \t]*spark://[[:alnum:]_-]\+:[0-9]\+|spark.master	spark://'${SPARK_MASTER_HOST}'\:'${SPARK_MASTER_PORT}'|g' /opt/spark/conf/spark-defaults.conf
fi   

if [ ! -z "$SPARK_EXECUTOR_MEMORY" ];
then
   sed -i 's|spark.executor.memory[ \t]*[[:alnum:]_-]\+|spark.executor.memory    '${SPARK_EXECUTOR_MEMORY}'|g' /opt/spark/conf/spark-defaults.conf
fi 

if [ ! -z "$SPARK_DRIVER_MEMORY" ];
then
   sed -i 's|spark.driver.memory[ \t]*[[:alnum:]_-]\+|spark.driver.memory    '${SPARK_DRIVER_MEMORY}'|g' /opt/spark/conf/spark-defaults.conf
fi    


. "/opt/spark/bin/load-spark-env.sh"
# When the spark work_load is master run class org.apache.spark.deploy.master.Master
if [ "$SPARK_WORKLOAD" == "master" ];
then

export SPARK_MASTER_HOST=`hostname`


cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.master.Master --host $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port 8080


elif [ "$SPARK_WORKLOAD" == "worker" ];
then

# When the spark work_load is worker run class org.apache.spark.deploy.master.Worker
cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.worker.Worker --webui-port 8081 spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT

elif [ "$SPARK_WORKLOAD" == "history" ];
then
   if [ ! -z "$HISTORY_CLEANER_INTERVAL" ];
    then
      sed -i 's|spark.history.fs.cleaner.interval[ \t]*[[:alnum:]_-]\+|spark.history.fs.cleaner.interval    '${HISTORY_CLEANER_INTERVAL}'|g' /opt/spark/conf/spark-defaults.conf
   fi 

   if [ ! -z "$HISTORY_MAX_AGE" ];
    then
      sed -i 's|spark.history.fs.cleaner.maxAge[ \t]*[[:alnum:]_-]\+|spark.history.fs.cleaner.maxAge    '${HISTORY_MAX_AGE}'|g' /opt/spark/conf/spark-defaults.conf
   fi 

    export SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=/opt/spark/spark-events -Dspark.history.ui.port=18080"
    cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.history.HistoryServer
else
    echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker, history"
fi

