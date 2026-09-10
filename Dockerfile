FROM ubuntu:24.04

ARG STUDENT_USER=student
ARG STUDENT_PASSWORD=changeme123
ENV STUDENT_USER=${STUDENT_USER}

# ubuntu:24.04 is a "minimized" cloud image (no man pages/docs, stripped
# package set) - restore the normal system so it behaves like a real server.
RUN yes | unminimize

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        cron \
        sudo \
        nano \
        curl \
        iproute2 \
        iputils-ping \
        net-tools \
        dnsutils \
        dialog \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# Ubuntu's default sshd_config already allows password auth for regular
# users, but make it explicit so this keeps working if the base image changes.
RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Student account with sudo rights. Note: no systemd/init system in this
# image, so services (e.g. apache2) are started with `service <name> start`,
# not `systemctl`.
RUN useradd -m -s /bin/bash -G sudo "${STUDENT_USER}" && \
    echo "${STUDENT_USER}:${STUDENT_PASSWORD}" | chpasswd

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# Strip any CR characters (in case the file was checked out with Windows
# CRLF line endings) and make it executable, so it always runs in the
# container regardless of the host it was cloned on.
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
