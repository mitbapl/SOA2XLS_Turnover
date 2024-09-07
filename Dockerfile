# Use the official Python image
FROM python:3.11
FROM python:3.11

# Install necessary packages
RUN apt-get update && \
    apt-get install -y ncurses-bin \ 
    build-essential \
    libssl-dev \
    libffi-dev \
    openjdk-11-jdk

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Set working directory
WORKDIR /app

# Copy requirements.txt
COPY requirements.txt .

# Install dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Start the application
CMD ["gunicorn", "app:app"]
