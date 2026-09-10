#!/bin/bash
set -e

# The home directory is a named volume, so on first run (or if it was
# recreated) it may not have the right ownership yet - fix that before
# sshd starts, otherwise login will fail with permission errors.
chown -R "${STUDENT_USER}:${STUDENT_USER}" "/home/${STUDENT_USER}"

# Make sure host keys exist (they're normally generated at package-install
# time during the image build, but regenerate defensively).
ssh-keygen -A

# Unlike other services, cron is started here automatically on every boot -
# it's expected to just be running in the background, like on a real server.
service cron start

# apache2 isn't installed by default - students install it themselves as
# part of the course. Start it if present, but don't fail boot if it isn't
# (or isn't installed yet).
service apache2 start 2>/dev/null || true

PORT_SUFFIX=""
if [ "${SSH_PORT:-22}" != "22" ]; then
    PORT_SUFFIX=" -p ${SSH_PORT}"
fi

cat <<EOF

========================================================
 Server is up. Connect with:

     ssh ${STUDENT_USER}@localhost${PORT_SUFFIX}

========================================================

EOF

exec /usr/sbin/sshd -D
