# Use a lightweight Python image as a base
FROM python:3.9-slim

# Install an alternative JDK and other necessary dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk-headless \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set the JAVA_HOME environment variable to the correct path
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Python dependencies (such as tabula-py)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . /app

# Set the working directory
WORKDIR /app

# Check if libjvm.so exists in the correct directory
RUN find $JAVA_HOME -name "libjvm.so" || (echo "libjvm.so not found" && exit 1)

# Run the Python application
CMD ["python", "your_script.py"]
