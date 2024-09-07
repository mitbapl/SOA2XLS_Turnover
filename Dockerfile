# Stage 1: Use a base image with OpenJDK
FROM openjdk:11-slim as java-base

# Stage 2: Use Python 3.9-slim
FROM python:3.9-slim

# Install OpenJDK in the Python image
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Set the working directory
WORKDIR /app

# Copy your application files into the container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run your Python application
CMD ["python", "app.py"]
