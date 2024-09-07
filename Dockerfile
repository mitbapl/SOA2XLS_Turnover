# Stage 1: Build the environment
FROM openjdk:11-jdk-slim as builder

# Install any build dependencies here (if needed)
# Example: RUN apt-get update && apt-get install -y python3 python3-pip

# Stage 2: Final image
FROM openjdk:11-jre-slim

# Copy necessary files from the builder stage
COPY --from=builder /path/to/needed/files /path/in/final/image

# Set up environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy application code
# COPY . .

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Start the application
CMD ["gunicorn", "app:app"]
