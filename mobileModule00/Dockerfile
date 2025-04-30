FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    wget \
    xauth \
    libpulse0 \
    x11-apps \
    libx11-xcb1 \
    sudo

RUN useradd -ms /bin/bash flutter_user
RUN mkdir -p /home/flutter_user/app
RUN chown -R flutter_user:flutter_user /home/flutter_user
RUN echo "flutter_user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/flutter_user

WORKDIR /home/flutter_user/app

USER flutter_user
RUN git clone https://github.com/flutter/flutter.git /home/flutter_user/flutter
ENV PATH="/home/flutter_user/flutter/bin:${PATH}"

RUN flutter config --no-analytics
RUN flutter doctor

WORKDIR /home/flutter_user/app