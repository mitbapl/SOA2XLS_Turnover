# Stage 1: Build the Java application using Maven
FROM maven:3.8.3-openjdk-17 AS build
COPY . .
RUN mvn clean package -DskipTests=true

# Stage 2: Use a lightweight OpenJDK image with Python
FROM python:3.9-slim

# Install Java (OpenJDK 17) and other necessary dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Set the JAVA_HOME environment variable to the correct path for OpenJDK 17
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Copy the Java JAR file from the build stage
COPY --from=build /target/newsapp-0.0.1-SNAPSHOT.jar /app/newsapp.jar

# Copy the Python requirements file and install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the application files
COPY . /app

# Set the working directory to /app
WORKDIR /app

# Expose the application port
EXPOSE 8080

# Verify Java installation and ensure libjvm.so exists
RUN java -version
RUN test -f $JAVA_HOME/lib/server/libjvm.so || (echo "libjvm.so not found" && exit 1)

# Start both the Java and Python applications
CMD ["python app.py"]
