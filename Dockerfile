# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install Java (OpenJDK 11) for Tabula
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get clean

# Expose the port the app runs on
EXPOSE 5000

# Make sure the upload folder exists
RUN mkdir -p /app/uploads

# Run the application
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]  # Replace 'app:app' with your module and application name
