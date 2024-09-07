# Stage 1: Build the Java project
FROM maven:3.8.2-jdk-17 AS build

# Copy your Java project files
COPY . .

# Build the project
RUN mvn clean package -Pprod -DskipTests

# Stage 2: Set up the runtime environment
FROM openjdk:17-jdk-slim

# Set the environment variables for Java
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk
ENV PATH $JAVA_HOME/bin:$PATH

# Install Python and pip (necessary for tabula-py)
RUN apt-get update && apt-get install -y python3 python3-pip

# Install tabula-py Python library
RUN pip3 install tabula-py

# Copy the application JAR from the build stage
COPY --from=build /target/your-app.jar /app/your-app.jar

# Copy your Python application if needed (tabula integration)
COPY your_python_script.py /app/

# Set the working directory
WORKDIR /app

# Expose necessary ports
EXPOSE 8080

# Command to run your Java application
CMD ["java", "-jar", "your-app.jar"]
