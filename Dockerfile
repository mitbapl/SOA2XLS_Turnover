FROM python:3.9
FROM continuumio/miniconda3

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
