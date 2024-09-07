# Use an appropriate base image
FROM ubuntu:20.04

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install OpenJDK and Python
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME and update PATH
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Verify Java installation
RUN java -version

# Set the working directory
WORKDIR /app

# Copy your Python application files to the container
COPY your_python_script.py /app/

# Install tabula-py (or other dependencies)
RUN pip3 install tabula-py

# Command to run your application
CMD ["python3", "your_python_script.py"]
