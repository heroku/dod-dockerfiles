FROM ubuntu:focal

# let's make apt list package versions, since those are handy during devel
RUN echo 'APT::Get::Show-Versions "1";' > /etc/apt/apt.conf.d/verbose

ENV HOME=/root \
    TERM=xterm-256color \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# get all available locales and configure them
RUN apt-get update && apt-get install --yes locales && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8 && update-locale
RUN cp /usr/share/i18n/SUPPORTED /etc/locale.gen
RUN dpkg-reconfigure -f noninteractive locales

# Get xenial locale files. Don't do this normally!
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe" >> /etc/apt/sources.list

# Download the packages
RUN apt-get update && apt download locales-all/xenial

# Unpack the package to somewhere predictable
RUN dpkg -X locales-all_2.23*.deb /opt/2.23-compat

# Remove the questionable sources
RUN sed -i '$ d' /etc/apt/sources.list

# Remove the raw package
RUN rm -rf locales-all_2.23*.deb

# Do a dance around LC_TIME
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 --no-archive
RUN cp /usr/lib/locale/en_US.utf8/LC_TIME /opt/2.23-compat/usr/lib/locale/en_US.utf8/LC_TIME
RUN rm -rf /usr/lib/locale/en_US.utf8

# ensure distro is upgraded
RUN apt-get update && \
    apt-get \
      --yes \
      --allow-downgrades \
      --allow-remove-essential \
      --allow-change-held-packages \
      dist-upgrade && \
    rm -rf /var/lib/apt/lists/*
