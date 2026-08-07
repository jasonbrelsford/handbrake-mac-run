FROM debian:bullseye-slim

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

