# Base image with OpenJDK
FROM openjdk:11-slim AS java_base

# Set JAVA_HOME
ENV JAVA_HOME=/usr/local/openjdk-11
ENV PATH=$JAVA_HOME/bin:$PATH

# Base image with Python
FROM python:3.9-slim AS python_base

# Install OpenJDK in the Python base image
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Set the working directory
WORKDIR /app

# Copy your application files
COPY . .

# Install Python dependencies
RUN pip install -r requirements.txt

# Command to run your Python application
CMD ["python", "your_script.py"]
