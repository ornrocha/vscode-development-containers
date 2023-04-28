#!/bin/sh

PUSH_LOCAL_SERVER=0
PUSH_REMOTE_SERVER=0

BUILD_PYTHON_ENV=1
BUILD_SPARK_LOCAL=1
BUILD_SPARK_STANDALONE=1

BUILD_PYTHON_VERSION=3.10
SPARK_VERSION=3.3.2
HADOOP_VERSION=3
TAG_AS_LATEST=0
NO_CACHE=""

LOCAL_SERVER_URL="127.0.0.1:5000"
REMOTE_SERVER_URL="ornrocha"


export BUILDKIT_PROGRESS=plain  #type of progress output (auto, plain, tty)
export DOCKER_BUILDKIT=1

if [ ! -d logs ];then
   mkdir logs
fi


build_docker_images()
{


  if [ $BUILD_PYTHON_ENV -eq 1 ];then
    docker build $NO_CACHE -t $LOCAL_SERVER_URL/python-devenv:$BUILD_PYTHON_VERSION  --build-arg IMAGE_PYTHON_VERSION=$BUILD_PYTHON_VERSION --target pythondevenv . 2>&1 | tee logs/python-devenv-build-$BUILD_PYTHON_VERSION.log
    docker tag $LOCAL_SERVER_URL/python-devenv:$BUILD_PYTHON_VERSION $REMOTE_SERVER_URL/python-devenv:$BUILD_PYTHON_VERSION
    
    if [ $TAG_AS_LATEST -eq 1 ];then
        docker tag $LOCAL_SERVER_URL/python-devenv:$BUILD_PYTHON_VERSION $LOCAL_SERVER_URL/python-devenv:latest
        docker tag $LOCAL_SERVER_URL/python-devenv:$BUILD_PYTHON_VERSION $REMOTE_SERVER_URL/python-devenv:latest
    fi

    if [ $PUSH_LOCAL_SERVER -eq 1 ];then
      docker push $LOCAL_SERVER_URL/python-devenv:$BUILD_PYTHON_VERSION
      if [ $TAG_AS_LATEST -eq 1 ];then
          docker push $LOCAL_SERVER_URL/python-devenv:latest
      fi
    fi

    if [ $PUSH_REMOTE_SERVER -eq 1 ];then
      docker push $REMOTE_SERVER_URL/python-devenv:$BUILD_PYTHON_VERSION
      if [ $TAG_AS_LATEST -eq 1 ];then
        docker push $REMOTE_SERVER_URL/python-devenv:latest
      fi
    fi
  fi  

  if [ $BUILD_SPARK_LOCAL -eq 1 ];then
    docker build $NO_CACHE -t $LOCAL_SERVER_URL/pyspark-devenv-local:$BUILD_PYTHON_VERSION-$SPARK_VERSION  --build-arg IMAGE_PYTHON_VERSION=$BUILD_PYTHON_VERSION \
    --build-arg SPARK_VERSION=$SPARK_VERSION --build-arg HADOOP_VERSION=$HADOOP_VERSION --target sparklocal . 2>&1 | tee logs/pyspark-devenv-local-build-$SPARK_VERSION.log

    docker tag $LOCAL_SERVER_URL/pyspark-devenv-local:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-local:$BUILD_PYTHON_VERSION-$SPARK_VERSION

    if [ $TAG_AS_LATEST -eq 1 ];then
      docker tag $LOCAL_SERVER_URL/pyspark-devenv-local:$BUILD_PYTHON_VERSION-$SPARK_VERSION $LOCAL_SERVER_URL/pyspark-devenv-local:latest
      docker tag $LOCAL_SERVER_URL/pyspark-devenv-local:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-local:latest
    fi

    if [ $PUSH_LOCAL_SERVER -eq 1 ];then
      docker push $LOCAL_SERVER_URL/pyspark-devenv-local:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      
      if [ $TAG_AS_LATEST -eq 1 ];then
          docker push $LOCAL_SERVER_URL/pyspark-devenv-local:latest
      fi
    fi

    if [ $PUSH_REMOTE_SERVER -eq 1 ];then
      docker push $REMOTE_SERVER_URL/pyspark-devenv-local:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      if [ $TAG_AS_LATEST -eq 1 ];then
        docker push $REMOTE_SERVER_URL/pyspark-devenv-local:latest
      fi
    fi

  fi 

  if [ $BUILD_SPARK_STANDALONE -eq 1 ];then 

    docker build $NO_CACHE -t $LOCAL_SERVER_URL/pyspark-devenv-worker:$BUILD_PYTHON_VERSION-$SPARK_VERSION --build-arg IMAGE_PYTHON_VERSION=$BUILD_PYTHON_VERSION \
    --build-arg SPARK_VERSION=$SPARK_VERSION --build-arg HADOOP_VERSION=$HADOOP_VERSION  --target sparkworker . 2>&1 | tee logs/pyspark-devenv-worker-build-$SPARK_VERSION.log

    docker build $NO_CACHE -t $LOCAL_SERVER_URL/pyspark-devenv-standalone:$BUILD_PYTHON_VERSION-$SPARK_VERSION --build-arg IMAGE_PYTHON_VERSION=$BUILD_PYTHON_VERSION \
    --build-arg SPARK_VERSION=$SPARK_VERSION --build-arg HADOOP_VERSION=$HADOOP_VERSION --target sparkstandalone . 2>&1 | tee logs/pyspark-devenv-standalone-build-$SPARK_VERSION.log
    
    docker build $NO_CACHE -t $LOCAL_SERVER_URL/pyspark-devenv-history:$BUILD_PYTHON_VERSION-$SPARK_VERSION --build-arg IMAGE_PYTHON_VERSION=$BUILD_PYTHON_VERSION \
    --build-arg SPARK_VERSION=$SPARK_VERSION --build-arg HADOOP_VERSION=$HADOOP_VERSION --target sparkhistory . 2>&1 | tee logs/pyspark-devenv-history-build-$SPARK_VERSION.log
    
    docker tag $LOCAL_SERVER_URL/pyspark-devenv-worker:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-worker:$BUILD_PYTHON_VERSION-$SPARK_VERSION
    docker tag $LOCAL_SERVER_URL/pyspark-devenv-history:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-history:$BUILD_PYTHON_VERSION-$SPARK_VERSION
    docker tag $LOCAL_SERVER_URL/pyspark-devenv-standalone:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-standalone:$BUILD_PYTHON_VERSION-$SPARK_VERSION

    if [ $TAG_AS_LATEST -eq 1 ];then
      docker tag $LOCAL_SERVER_URL/pyspark-devenv-standalone:$BUILD_PYTHON_VERSION-$SPARK_VERSION $LOCAL_SERVER_URL/pyspark-devenv-standalone:latest
      docker tag $LOCAL_SERVER_URL/pyspark-devenv-worker:$BUILD_PYTHON_VERSION-$SPARK_VERSION $LOCAL_SERVER_URL/pyspark-devenv-worker:latest
      docker tag $LOCAL_SERVER_URL/pyspark-devenv-history:$BUILD_PYTHON_VERSION-$SPARK_VERSION $LOCAL_SERVER_URL/pyspark-devenv-history:latest

      docker tag $LOCAL_SERVER_URL/pyspark-devenv-standalone:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-standalone:latest
      docker tag $LOCAL_SERVER_URL/pyspark-devenv-worker:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-worker:latest
      docker tag $LOCAL_SERVER_URL/pyspark-devenv-history:$BUILD_PYTHON_VERSION-$SPARK_VERSION $REMOTE_SERVER_URL/pyspark-devenv-history:latest
    fi


    if [ $PUSH_LOCAL_SERVER -eq 1 ];then
      docker push $LOCAL_SERVER_URL/pyspark-devenv-worker:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      docker push $LOCAL_SERVER_URL/pyspark-devenv-history:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      docker push $LOCAL_SERVER_URL/pyspark-devenv-standalone:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      
      if [ $TAG_AS_LATEST -eq 1 ];then
        docker push $LOCAL_SERVER_URL/pyspark-devenv-standalone:latest
        docker push $LOCAL_SERVER_URL/pyspark-devenv-worker:latest
        docker push $LOCAL_SERVER_URL/pyspark-devenv-history:latest
      fi
    fi

    if [ $PUSH_REMOTE_SERVER -eq 1 ];then
      docker push $REMOTE_SERVER_URL/pyspark-devenv-worker:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      docker push $REMOTE_SERVER_URL/pyspark-devenv-history:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      docker push $REMOTE_SERVER_URL/pyspark-devenv-standalone:$BUILD_PYTHON_VERSION-$SPARK_VERSION
      
      if [ $TAG_AS_LATEST -eq 1 ];then
        docker push $REMOTE_SERVER_URL/pyspark-devenv-standalone:latest
        docker push $REMOTE_SERVER_URL/pyspark-devenv-worker:latest
        docker push $REMOTE_SERVER_URL/pyspark-devenv-history:latest
      fi
    fi

  fi  
}




print_usage()
{
  echo ""
  echo "Usage: $0 [optional parameters]"
  echo "Parameters list:"
  echo "\t--spark  [A valid spark version]"
  echo "\t--hadoop [A hadoop version (compliant with spark)]"
  echo "\t--python [the flag of python image to use from https://hub.docker.com/_/python]"
  echo "\t--progress [The type of docker progress output (auto, plain, tty)]"
  echo "\t--tag-latest (Flag to set image as latest version)"
  echo "\t--no-cache (Flag to set docker build without caching)"
  echo "\t--local-push (Flag to push images to local repository)"
  echo "\t--remote-push (Flag to push images to remote repository)"
  echo "\t--no-spark-local (Flag to deactivate the build of spark local image)"
  echo "\t--no-spark-standalone (Flag to deactivate the build of spark standalone image)"
  echo "\t--no-python-env (Flag to deactivate the build of python dev image)"
  echo "\t--local-server [The url of local docker repository]"
  echo "\t--remote-server [The url of remote docker repository]"

  exit 0 # Exit script after printing help
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    '--help')   set -- "$@" '-h'   ;;
    '--spark') set -- "$@" '-s'   ;;
    '--hadoop') set -- "$@" '-a'   ;;
    '--python') set -- "$@" '-p'   ;;
    '--progress') set -- "$@" '-g'   ;;
    '--tag-latest') set -- "$@" '-t'   ;;     
    '--no-cache') set -- "$@" '-n'   ;;  
    '--local-push')   set -- "$@" '-l'   ;;
    '--remote-push')     set -- "$@" '-r'   ;;
    '--no-spark-local')     set -- "$@" '-b'   ;;
    '--no-spark-standalone')     set -- "$@" '-e'   ;;
    '--no-python-env')     set -- "$@" '-y'   ;;
    '--local-server')     set -- "$@" '-o'   ;;
    '--remote-server')     set -- "$@" '-m'   ;;
    *)          set -- "$@" "$arg" ;;
  esac
done

# Default behavior
number=0; rest=false; ws=false

# Parse short options
OPTIND=1
while getopts "hs:a:p:g:o:m:rltnbey" opt
do
  case "$opt" in
    'h') print_usage; exit 0 ;;
    's') SPARK_VERSION=$OPTARG ;;
    'a') HADOOP_VERSION=$OPTARG ;;
    'p') BUILD_PYTHON_VERSION=$OPTARG ;;
    'g') BUILDKIT_PROGRESS=$OPTARG ;;
    'o') LOCAL_SERVER_URL=$OPTARG ;;
    'm') REMOTE_SERVER_URL=$OPTARG ;;
    'n') NO_CACHE="--no-cache" ;;     
    't') TAG_AS_LATEST=1 ;;     
    'r') PUSH_REMOTE_SERVER=1 ;;
    'l') PUSH_LOCAL_SERVER=1 ;;
    'b') BUILD_SPARK_LOCAL=0 ;;
    'e') BUILD_SPARK_STANDALONE=0 ;;
    'y') BUILD_PYTHON_ENV=0 ;;
    '?') print_usage >&2; exit 1 ;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

echo "Using the following settings:"
echo "PUSH_LOCAL_SERVER=$PUSH_LOCAL_SERVER"
echo "PUSH_REMOTE_SERVER=$PUSH_REMOTE_SERVER"
echo "BUILD_PYTHON_VERSION=$BUILD_PYTHON_VERSION"
echo "SPARK_VERSION=$SPARK_VERSION"
echo "HADOOP_VERSION=$HADOOP_VERSION"
echo "TAG_AS_LATEST=$TAG_AS_LATEST"
echo "BUILDKIT_PROGRESS=$BUILDKIT_PROGRESS"
echo "DOCKER_BUILDKIT=$DOCKER_BUILDKIT"
echo "NO_CACHE=$NO_CACHE"
echo "LOCAL_SERVER_URL=$LOCAL_SERVER_URL"
echo "REMOTE_SERVER_URL=$REMOTE_SERVER_URL"

build_docker_images
