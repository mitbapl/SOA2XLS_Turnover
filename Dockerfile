# Use an official OpenJDK image as the base image
FROM openjdk:11-jre-slim

# Install Python and necessary dependencies
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Set environment variables for Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy requirements.txt and install Python dependencies
COPY requirements.txt .
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt

# Copy the application code into the container
COPY . .

# Verify Java installation (optional step for debugging)
RUN java -version

# Start the application
CMD ["gunicorn", "app:app"]
