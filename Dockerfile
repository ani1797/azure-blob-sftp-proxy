FROM ubuntu:latest

ENV STORAGE_DRIVE=/mnt/store/

ENV SFTP_USER=user
ENV SFTP_UID=1000
ENV SFTP_GID=1000
ENV SFTP_PASS=pass
ENV SFTP_PORT=22

WORKDIR "${STORAGE_DRIVE}"

# Install Required Packages
RUN apt-get update && apt-get install -y -qq curl ca-certificates libcurl4-gnutls-dev libcurl3-gnutls ssh \
  && curl -L https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o /tmp/ms-prod.deb \
  && dpkg -i /tmp/ms-prod.deb && apt-get update \
  && apt-get install -y -qq blobfuse fuse \
  && rm -rf /var/lib/apt/lists/* /tmp/ms-prod.deb

# Update SSH Configurations
RUN sed -i "s/#Port 22/Port ${SFTP_PORT}/g" /etc/ssh/sshd_config \
  && sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g' /etc/ssh/sshd_config

# Add a new user for SFTP access
RUN addgroup --gid "${SFTP_GID}" "${SFTP_USER}" \
  && useradd -s /usr/bin/bash -d "${STORAGE_DRIVE}" -u "${SFTP_UID}" -g "${SFTP_GID}" -M "${SFTP_USER}" \
  && echo "${SFTP_USER}:${SFTP_PASS}" | chpasswd

EXPOSE ${SFTP_PORT}

COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh
