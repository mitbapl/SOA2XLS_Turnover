# Use a lightweight Python image as a base
FROM python:3.9-slim

# Install Java (JDK) and other necessary dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Set the JAVA_HOME environment variable to the correct path
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . /app

# Set the working directory
WORKDIR /app

# Verify Java installation and libjvm.so presence
RUN java -version
RUN find $JAVA_HOME -name "libjvm.so" || (echo "libjvm.so not found" && exit 1)

# Start the Python application
CMD ["python", "app.py"]
