# Pyspark/Python Development Containers

This repository contains a set of configurations to create pyspark an python development environments in vscode using docker containers. For development in pyspark two different strategies can be used, using spark in local mode or in standalone mode. 


## VSCode Development Environments


|Environment|Configurations|Spark Mode|
|-----------|-------------|:-----------:|
|Python|[python-devenv-wks](./vscode-development-containers/assets/python-devenv-wks.zip)|-|
|Pyspark|[pyspark-devenv-local-wks](./vscode-development-containers/assets/pyspark-devenv-local-wks.zip)|Local|
|Pyspark|[pyspark-devenv-standalone-wks](./vscode-development-containers/assets/pyspark-devenv-standalone-wks.zip)|Standalone|



 ## Requirements

* [Visual Studio Code](https://code.visualstudio.com/)
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension)


## Installation
To get started, follow these steps:

1. Install Visual Studio Code (VSCode)
2. Install and configure [Docker](https://www.docker.com/get-started) for your operating system.
3. Install the [Remote Development extension pack](https://code.visualstudio.com/docs/remote/containers#_installation)


### Install development environment

1. Download the devcontainer files for the desired [VScode development environment](#vscode-development-environments) (zip extension), and unzip the files to a location of your choice.

2. Configure the environment variables at your choice, if needed (see section [Environment variables](#environment-variables)).

   - Change the name of file **.env_template** inside folder **.devcontainer** to **.env**.
   - Add or modify the environment variables with the values that fit best for you.

3. Start VSCode.
4. Press on **View** &rarr; **Command Palette** &rarr; search for **Remote-Containers: Open Folder in Container...**.
5. Choose and press over **Remote-Containers: Open Folder in Container...**
6. Select folder **pyspark-devenv-{spark mode}-wks** or **python-devenv-wks** that contains folder **.devcontainer**.
7. Leave the process running until the installation is complete.


## Environment Variables

### **Common environment variables:**

| Variable             | Description                                                                          | Default Value |
|----------------------|--------------------------------------------------------------------------------------|---------------|
| JUPYTER_PORT         | Port to access to Jupyter environment                                                | 8888          |
| GIT_EMAIL            | Email that will be used to configure git                                             | default       |
| GIT_USERNAME         | Username that will be used to configure git                                          | default       |
| DISABLE_JUPYTER      | If you want to disable jupyter environment set this value to 1                       | 0             |
| JUPYTER_ALLOW_ORIGIN | The address origin that are allowed to access to your jupyter server                 | 0.0.0.0       |
| JUPYTER_PASSWORD     | The password to access to your jupyter server (hashed password)                      | hashed string of "devuser"  |



### **Pyspark environment variables:**

#### **Both modes**
| Variable             | Description                                                                          | Default Value |
|----------------------|--------------------------------------------------------------------------------------|---------------|
| JUPYTER_SPARk_MEMORY | The amount of memory that spark used by jupyter is allowed to consume                | 2g |
| JUPYTER_SPARK_CORES | Number of cpu cores that spark used by jupyter is allowed to use               | 2 |
| SPARK_EXECUTOR_MEMORY |  The amount of memory that spark executor can consume             | 2g |

#### **Standalone Mode**
| Variable             | Description                                                                          | Default Value |
|----------------------|--------------------------------------------------------------------------------------|---------------|
| SPARK_WORKER_CORES   | Number of cpu cores that a spark worker can use                                      | 2             |
| SPARK_WORKER_MEMORY  | The amount of memory that a spark worker can use                                     | 4g            |
| HISTORY_CLEANER_INTERVAL | Specifies how often the filesystem job history cleaner checks for files to delete| 1d            |
| HISTORY_MAX_AGE | History files older than this value will be deleted when the filesystem history cleaner runs| 7d          |
