FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# Configure DNS and package sources
RUN echo 'nameserver 8.8.8.8' > /etc/resolv.conf && \
    echo 'nameserver 8.8.4.4' >> /etc/resolv.conf

# Install dependencies for transcription
RUN apt-get update --fix-missing && apt-get install -y \
    ffmpeg \
    python3 \
    python3-pip \
    inotify-tools \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install whisper for transcription
RUN pip3 install openai-whisper

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