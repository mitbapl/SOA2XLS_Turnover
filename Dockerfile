FROM python:3.9

RUN apt-get update && apt-get install -y openjdk-11-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
RUN echo "export PATH=$PATH:$JAVA_HOME/bin" >> /root/.bashrc

WORKDIR /app
COPY . .

CMD ["python", "app.py"]
