FROM python:3.11-slim

# Install necessary system packages
RUN apt-get update && \
    apt-get install -y build-essential libssl-dev libffi-dev openjdk-11-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Set working directory
WORKDIR /app

# Copy requirements file and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install jpype1 && \
    pip install -r requirements.txt

# Copy the rest of your application code
COPY . .

# Command to run your app (adjust as necessary)
CMD ["python", "your_app.py"]
