FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG KAVITA_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV HOME="/config"

RUN \
  apt-get update && \
  apt-get install -y \
    libicu70 && \
  echo "**** install kavita ****" && \
  mkdir -p \
    /app/kavita && \
  if [ -z ${KAVITA_RELEASE+x} ]; then \
    KAVITA_RELEASE=$(curl -sX GET "https://api.github.com/repos/kareadita/kavita/releases/latest" \
      | jq -r '.tag_name'); \
  fi && \
  curl -o \
    /tmp/kavita.tar.gz -fL \
    "https://github.com/Kareadita/Kavita/releases/download/${KAVITA_RELEASE}/kavita-linux-x64.tar.gz" && \
  tar xf \
    /tmp/kavita.tar.gz -C \
    /app/kavita --strip-components=1 && \
  chown -R 911:911 /app/kavita && \
  chmod +x /app/kavita/Kavita && \
  cp /app/kavita/config/appsettings.json /defaults/ && \
  rm -rf /app/kavita/config && \
  ln -s /config /app/kavita/config && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 5000
