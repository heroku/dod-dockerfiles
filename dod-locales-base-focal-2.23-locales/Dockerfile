FROM ubuntu:focal

ARG SOURCE_GLIBC_VERSION=2.23
ARG TARGET_GLIBC_VERSION=2.31

# let's make apt list package versions, since those are handy during devel
RUN echo 'APT::Get::Show-Versions "1";' > /etc/apt/apt.conf.d/verbose

ENV HOME=/root \
    TERM=xterm-256color \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY scripts/ ${HOME}

# get all available locales and configure them
RUN apt-get update && apt-get install --yes \
    locales \
    gnupg \
    python3 \
    vim \
    gcc \
    make \
    gawk \
    wget \
    autoconf \
    g++ \
    git \
    xz-utils \
    bison \
    && rm -rf /var/lib/apt/lists/*

RUN "${HOME}/localepatch.sh" ${SOURCE_GLIBC_VERSION} ${TARGET_GLIBC_VERSION}
RUN "${HOME}/locale-gen-patch.sh" ${TARGET_GLIBC_VERSION}

ENV PATH=/opt/glibc-${TARGET_GLIBC_VERSION}-heroku/bin:$PATH

RUN locale-gen en_US.UTF-8 && update-locale
RUN cp ${HOME}/SUPPORTED /etc/locale.gen
RUN dpkg-reconfigure -f noninteractive locales

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get --purge --yes remove python3 vim gcc gawk wget autoconf g++ git bison && apt-get autoremove --yes

RUN rm -rf ${HOME}/*.sh ${HOME}/SUPPORTED

# ensure distro is upgraded
RUN apt-get update && \
    apt-get \
      --yes \
      --allow-downgrades \
      --allow-remove-essential \
      --allow-change-held-packages \
      dist-upgrade && \
    rm -rf /var/lib/apt/lists/*
