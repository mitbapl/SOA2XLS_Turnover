FROM python:3.9
FROM openjdk:8-jdk-slim

# Clone the OpenJDK repository
RUN git clone https://github.com/openjdk/jdk.git /jdk

# Install JDK
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/default-java
ENV PATH $JAVA_HOME/bin:$PATH

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy your application files
COPY . /app
WORKDIR /app

# Command to run your application
CMD ["python", "app.py"]
