# Use an official Python image
FROM python:3.11-slim
# Use a base image with both Python and Java pre-installed
FROM openjdk:11-slim

# Install Python and other dependencies
RUN apt-get update && apt-get install -y python3 python3-pip

# Set environment variables for Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy the application code to the container
WORKDIR /app
COPY . /app

# Install any Python dependencies
RUN pip3 install -r requirements.txt

# Set the command to run your app
CMD ["python3", "app.py"]
