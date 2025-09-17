FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*
# Update the package list and install the default OpenJDK Development Kit (JDK)
# This will typically install the latest LTS version available in Ubuntu's repositories
RUN apt-get update -y && apt-get install -y default-jdk

# Set the JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/default-java

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs

RUN npm install @salesforce/cli --global

RUN apt-get update && apt-get install -y git

CMD ["bash"]