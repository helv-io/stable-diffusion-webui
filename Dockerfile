FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Set the Timezone
ARG TZ
ENV TZ=${TZ}

# Install required packages and libraries
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    curl \
    python3 \
    python3-venv \
    git \
    wget \
    vim \
    inetutils-ping \
    sudo \
    net-tools \
    iproute2 \
    tzdata \
    libgoogle-perftools4 \
    libtcmalloc-minimal4 \
    ffmpeg && \
    apt clean && \
    apt upgrade -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui .

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3
RUN pip3 install -r requirements.txt
RUN python3 launch.py --skip-torch-cuda-test --exit

# Cache to optimize redeployments
VOLUME /root/.cache

# Expose default port
EXPOSE 7861

# Define an environment variable for passing arguments
ENV LAUNCH_ARGS=""

CMD ["sh", "-c", "python3 launch.py $LAUNCH_ARGS"]
