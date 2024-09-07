#!/bin/bash

# Exit immediately if a command exits with a non-zero status
#set -e

# Install OpenJDK 11
#echo "Installing OpenJDK 11..."
#apt-get update
#apt-get install -y openjdk-11-jdk

# Set JAVA_HOME environment variable
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so /usr/lib64/microsoft-r/3.3/lib64/R/lib/libjvm.so
export PATH=$JAVA_HOME/bin:$PATH
# export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/lib/server
# Verify Java installation
#java -version
export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-oracle/jre/lib/amd64/server
# sudo R CMD javareconf
# Continue with your deployment process
# For example, you might want to install other dependencies or run your application
# npm install or pip install -r requirements.txt
