# First stage: Use the OpenJDK image
FROM openjdk:11-jdk-slim as builder

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Second stage: Use the official Python image
FROM python:3.11-slim

# Copy Java installation from the builder stage
COPY --from=builder /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/java-11-openjdk-amd64
COPY --from=builder /usr/bin/java /usr/bin/java
COPY --from=builder /usr/bin/javac /usr/bin/javac

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy requirements.txt
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy your application code
# COPY . .

# Start the application
CMD ["gunicorn", "app:app"]
