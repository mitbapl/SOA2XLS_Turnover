#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install OpenJDK 11
echo "Installing OpenJDK 11..."
apt-get update
apt-get install -y openjdk-11-jdk

# Set JAVA_HOME environment variable
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Add Java to the PATH
export PATH=$JAVA_HOME+"/bin:"+$PATH

# Verify Java installation
java -version

# Continue with your deployment process
# For example, you might want to install other dependencies or run your application
# npm install or pip install -r requirements.txt
