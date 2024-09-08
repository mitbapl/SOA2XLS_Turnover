FROM python:3.9
FROM openjdk:8-jdk-slim
FROM continuumio/miniconda3

# Install dependencies (if needed)
RUN if [ -f package.json ]; then npm install; fi
RUN if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Install mamba
RUN conda install mamba -c conda-forge

# Create the environment and install packages
RUN mamba create -n pyimagej pyimagej openjdk=8 -c conda-forge

# Activate the environment and set the working directory
SHELL ["conda", "run", "-n", "pyimagej", "/bin/bash", "-c"]
# Clone the OpenJDK repository
RUN git clone https://github.com/openjdk/jdk.git /jdk

# Install JDK
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm
ENV PATH $JAVA_HOME/bin:$PATH

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy your application files
COPY . /app
WORKDIR /app

# Command to run your application
CMD ["python", "app.py"]
