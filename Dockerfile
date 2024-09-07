FROM python:3.9

# Install Java
RUN apt-get update && \
    apt-get install -y openjdk-11-jre

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy your application files
COPY . /app
WORKDIR /app

# Command to run your application
CMD ["python", "app.py"]
