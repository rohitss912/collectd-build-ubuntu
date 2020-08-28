FROM ubuntu:xenial

RUN apt-get update

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y install dpatch libvarnishapi-dev build-essential devscripts fakeroot quilt dh-make automake libdistro-info-perl autoconf flex bison libtool pkg-config pbuilder debootstrap wget debhelper dh-systemd po-debconf autotools-dev libltdl-dev libgcrypt20-dev libglib2.0-dev gcc python3-dev curl debian-archive-keyring curl gnupg2 apt-transport-https git equivs

RUN curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | apt-key add -

RUN echo 'deb https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ xenial main\n\
deb-src https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ xenial main'\
>> /etc/apt/sources.list.d/varnishcache_varnish60lts.list && \
apt-get update