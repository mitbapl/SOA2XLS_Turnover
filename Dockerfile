# Use the AdoptOpenJDK 11 base image
FROM adoptopenjdk/openjdk11:latest

# Install Python and necessary tools
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy your application files
COPY . .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Command to run your Python application
CMD ["python3", "app.py"]
