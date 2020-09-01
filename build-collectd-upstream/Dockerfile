FROM ubuntu:xenial

RUN apt-get update

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y install dpatch build-essential devscripts fakeroot dh-make automake libdistro-info-perl autoconf flex bison libtool pkg-config pbuilder debootstrap wget debhelper dh-systemd po-debconf autotools-dev libltdl-dev libgcrypt20-dev libglib2.0-dev gcc python3-dev curl debian-archive-keyring curl gnupg2 apt-transport-https git equivs
