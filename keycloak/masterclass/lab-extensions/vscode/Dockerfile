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


#USER abc
EXPOSE 3000

LABEL org.opencontainers.image.source=https://github.com/codecentric/trainings
