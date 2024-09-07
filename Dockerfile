# Start from a base image that has OpenJDK and Python
FROM openjdk:11-slim

# Install Python and other necessary packages
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy your application files
COPY . .

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Expose the port your application runs on
EXPOSE 5000

# Command to run your Flask application
CMD ["python3", "your_flask_app.py"]
