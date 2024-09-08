# Use a lightweight Python image
FROM python:3.9-slim

# Install dependencies, including Java for tabula-py
RUN apt-get update && apt-get install -y \
    default-jdk \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . /app

WORKDIR /app

# Ensure the shared libraries are correctly linked
RUN ldconfig

# Check if libjvm.so exists in the correct directory
RUN find $JAVA_HOME -name "libjvm.so" || (echo "libjvm.so not found" && exit 1)

# Start the Python application
CMD ["python", "app.py"]
