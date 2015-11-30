FROM ubuntu-debootstrap:precise

# let's make apt list package versions, since those are handy during devel
RUN echo 'APT::Get::Show-Versions "1";' > /etc/apt/apt.conf.d/verbose

ENV HOME /root
ENV TERM xterm-256color
ENV DEBIAN_FRONTEND=noninteractive

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN cp /usr/share/i18n/SUPPORTED /var/lib/locales/supported.d/all
RUN dpkg-reconfigure -f noninteractive locales

RUN apt-get update \
	&& apt-get --force-yes dist-upgrade -y \
	&& rm -rf /var/lib/apt/lists/*
