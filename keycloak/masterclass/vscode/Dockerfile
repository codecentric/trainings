FROM lscr.io/linuxserver/openvscode-server:latest

USER root

RUN apt-get update && \
    apt-get install -y \
    openjdk-21-jdk \
    maven \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN java -version && mvn -version

# Pre-install Red Hat Java extension
RUN /app/openvscode-server/bin/openvscode-server \
    --install-extension redhat.java \
    --extensions-dir /config/.openvscode-server/extensions \
    || true

RUN apt-get update && apt-get install -y gnupg wget software-properties-common
RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt install -y terraform

#USER abc
EXPOSE 3000

#LABEL org.opencontainers.image.source=https://github.com/codecentric/trainings
