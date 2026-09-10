# tuxbox server template

Your own personal Linux "server" for this course, running as a Docker
container on your own laptop.

Start by clicking **"Use this template"** on GitHub to create your own copy
of this repo, then clone that instead of this one.

## Setup

```
git clone <your repo's URL>
cd docker-server-template
```

Check `.env.example` — if you want to change any of the values, copy it
to a new file named only `.env` and do your changes there before building
the container.

```
docker compose up -d --build
```

The container prints the exact `ssh` command to use once it's ready —
check with `docker compose logs`. By default it's:

```
ssh student@localhost
```

Password: `changeme123`.

Use `docker compose stop` / `start` to pause/resume — avoid `docker compose
down`, which throws away everything except your home directory.

## FAQ / things that work differently here than on a "real" server

- **No `systemctl`.** This image doesn't run systemd. Start/stop services
  with `sudo service <name> start|stop|restart` instead.
- **Services don't come back after a restart on their own.** There's no
  init system to bring them back up — just start them again with `service`.
- **Firewall tools (`ufw`, `iptables`) won't behave like a real host
  firewall** due to how container networking works, so they're out of
  scope here.
- **Only your home directory and `/var/www` persist across a full
  rebuild.** Everything else resets to the image's contents if the
  container is removed and recreated - so e.g. installed packages
  (`apache2`, etc.) need reinstalling after a rebuild, but web content you
  put in `/var/www` survives.
- **`halt`/`reboot`/`poweroff`/`shutdown` don't work.** They rely on an init
  system (systemd) running as PID 1, which isn't the case here, and
  containers don't have the privilege to actually halt/reboot anyway. To
  stop your server, run `docker compose stop` (or `down`) from your host.
- **No IPv6.** Docker's default network is IPv4-only regardless of your
  host's own connectivity, so `ping -6` and similar won't work.
