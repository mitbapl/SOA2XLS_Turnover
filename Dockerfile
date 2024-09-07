# Use a base image
FROM ubuntu:20.04

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install OpenJDK and Python
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Verify Java and Python installations
RUN java -version
RUN python3 --version

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Set the working directory
WORKDIR /app

# Command to run your application (update as necessary)
CMD ["bash"]
