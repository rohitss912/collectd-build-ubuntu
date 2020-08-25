FROM ubuntu:20.04

RUN apt-get update

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y install dpatch libvarnishapi-dev build-essential devscripts fakeroot quilt dh-make automake libdistro-info-perl autoconf flex bison libtool pkg-config pbuilder debootstrap wget debhelper po-debconf autotools-dev libltdl-dev libgcrypt20-dev libglib2.0-dev gcc python3-dev curl debian-archive-keyring curl gnupg2 apt-transport-https

RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ groovy universe" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get clean

RUN apt-get -y build-dep collectd
