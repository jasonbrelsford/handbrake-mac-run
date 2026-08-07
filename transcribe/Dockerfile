
FROM dorowu/ubuntu-desktop-lxde-vnc:latest


# Disable Google Chrome repo to avoid GPG error, then install dependencies for transcription
RUN sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/google-chrome.list 2>/dev/null || true \
    && apt-get update --fix-missing \
    && apt-get install -y \
        ffmpeg \
        python3 \
        python3-pip \
        inotify-tools \
        curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install whisper for transcription with increased timeout
RUN pip3 install --default-timeout=300 openai-whisper

# Install gdrive (same as main project)
RUN curl -L -o /usr/local/bin/gdrive \
    https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive-linux-x64 && \
    chmod +x /usr/local/bin/gdrive

# Create working directory
WORKDIR /data

# Copy transcription script
COPY watch-transcribe.sh /watch-transcribe.sh
RUN chmod +x /watch-transcribe.sh

ENTRYPOINT ["/watch-transcribe.sh"]