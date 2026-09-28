FROM debian:bookworm-slim

# handbrake-cli lives in the "non-free" component, which is not enabled by
# default on the official debian slim image. Enable contrib/non-free before
# installing, otherwise apt-get fails with "Unable to locate package"
# (exit code 100). Bookworm (Debian 12) is used instead of Bullseye (11)
# because Bullseye's security pool has rotated packages, causing 404s on the
# pinned versions during apt-get install.
RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# Install dependencies
RUN apt-get update && apt-get install -y \
    handbrake-cli \
    inotify-tools \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/bin/gdrive \
    https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive-linux-x64 && \
    chmod +x /usr/local/bin/gdrive

# Create a working directory
WORKDIR /data


# Copy watcher scripts
COPY watch.sh /watch.sh
COPY start-watchers.sh /start-watchers.sh
COPY transcribe/watch-transcribe.sh /transcribe/watch-transcribe.sh
RUN chmod +x /watch.sh /start-watchers.sh /transcribe/watch-transcribe.sh

ENTRYPOINT ["/start-watchers.sh"]

