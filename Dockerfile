# Use Python base image
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-jre \
    build-essential \
    && apt-get clean

# Set environment variables for Java
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory
WORKDIR /app

# Copy application files
COPY . /app
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt
# Expose the port Flask will run on
EXPOSE 10000

# Start the Flask application
# CMD ["python", "app.py"]
CMD ["python", "-m", "eventlet", "-w", "0", "app.py"]
