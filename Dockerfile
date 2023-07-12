FROM debian:12

WORKDIR /pixilab
VOLUME /home/blocks

# Download and install Java.
RUN apt-get update \
    && apt-get install -y wget apt-transport-https \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /usr/share/keyrings/adoptium.asc \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-11-jdk

# Download and install Chromium.
RUN apt-get install chromium -y

# Download and install CodeMeter + AxProtector.
RUN wget https://pixilab.se/outgoing/blocks/cloud-support/codemeter.deb \
    && apt-get install -y ./codemeter.deb \
    && rm ./codemeter.deb \
    && wget https://pixilab.se/outgoing/blocks/cloud-support/axprotector.deb \
    && apt-get install -y ./axprotector.deb \
    && rm ./axprotector.deb

# Bump max number of file descriptors to something more useful (for, e.g., websockets).
ARG FDS=10000
RUN echo -e "\nDefaultLimitNOFILE=$FDS\n" >> /etc/systemd/user.conf \
    && echo -e "\nDefaultLimitNOFILE=$FDS\n" >> /etc/systemd/system.conf \
    && echo -e "*       soft    nofile  $FDS\n*       hard    nofile  $FDS\n" >> /etc/security/limits.conf

# Copy start.sh to /pixilab and expose Blocks port.
COPY start.sh .
RUN chmod +x ./start.sh
EXPOSE 8080
ENTRYPOINT [ "./start.sh" ]
