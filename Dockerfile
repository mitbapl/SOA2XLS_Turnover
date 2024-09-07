# Use the official Python image
FROM python:3.11

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ncurses-bin \
    build-essential \
    libssl-dev \
    libffi-dev \
    openjdk-11-jdk && \
    rm -rf /var/lib/apt/lists/* && \  # Clean up to reduce image size
    java -version  # Verify Java installation
    
# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy requirements.txt
COPY requirements.txt .
# Copy colors.sh
COPY scripts/colors.sh ./scripts/

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Start the application
CMD ["gunicorn", "app:app"]
