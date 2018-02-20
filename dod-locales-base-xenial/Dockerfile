FROM ubuntu:xenial

# let's make apt list package versions, since those are handy during devel
RUN echo 'APT::Get::Show-Versions "1";' > /etc/apt/apt.conf.d/verbose

ENV HOME /root
ENV TERM xterm-256color
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install \
      --yes \
      --no-install-recommends \
      apt-utils \
      apt-transport-https \
      ca-certificates \
      curl \
      locales \
      software-properties-common \
      sudo \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN cp /usr/share/i18n/SUPPORTED /etc/locale.gen
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure -f noninteractive locales

RUN apt-get update && \
    apt-get \
      --yes \
      --allow-downgrades \
      --allow-remove-essential \
      --allow-change-held-packages \
      dist-upgrade && \
    rm -rf /var/lib/apt/lists/*
