FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Set the Timezone
ARG TZ
ENV TZ=${TZ}

# Install required packages and libraries
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	libgl1 \
	libglib2.0-0 \
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
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN pip3 install xformers

WORKDIR /app

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui .

# setup venv in /venv to avoid conflict with volume in /stable-diffusion-webui
RUN echo 'venv_dir=/venv' > webui-user.sh

ENV install_dir=/
RUN ./webui.sh -f can_run_as_root --exit --skip-torch-cuda-test

ENV VIRTUAL_ENV=/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Cache to optimize redeployments
VOLUME /root/.cache

# Expose default port
EXPOSE 7861

CMD ["python3", "launch.py", "--enable-insecure-extension-access", "--listen", "--no-half"]
