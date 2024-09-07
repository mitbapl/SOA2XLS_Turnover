sudo apt-get install default-jre

# Use Python's official lightweight image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Install dependencies for downloading and running Java
RUN apt-get update && apt-get install -y wget unzip

# Manually download and install OpenJDK
RUN wget https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_linux-x64_bin.tar.gz \
    && mkdir -p /usr/lib/jvm \
    && tar -xvzf openjdk-17+35_linux-x64_bin.tar.gz -C /usr/lib/jvm \
    && rm openjdk-17+35_linux-x64_bin.tar.gz

# Set JAVA_HOME and update PATH environment variables
ENV JAVA_HOME=/usr/lib/jvm/jdk-17
ENV PATH="$JAVA_HOME/bin:$PATH"

# Copy your application code into the container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port your Flask app will use
EXPOSE 5000

# Command to run the Flask app using Gunicorn
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000"]
