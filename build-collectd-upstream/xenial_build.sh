#!/bin/bash
set -e

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

mkdir -p "$SCRIPT_DIR/collectd-build" && cd "$SCRIPT_DIR"/collectd-build

#Pulls collectd 5.12 branch from git
git clone -b collectd-5.12 --depth 1 https://github.com/collectd/collectd.git
#Pulls the latest debian build archive for collectd
curl -sSL -OJ http://archive.ubuntu.com/ubuntu/pool/universe/c/collectd/collectd_5.11.0-7.debian.tar.xz
tar -xvf collectd_5.11.0-7.debian.tar.xz && mv debian collectd/debian

cd collectd
echo 9 > debian/compat
echo > debian/patches/series
sed -i 's/varnish_la_LIBADD.*/varnish_la_LIBADD = \$(BUILD_WITH_LIBVARNISH_LIBS) -lm/g' Makefile.am

#Update the rules file with collectd-signalfx settings
cd debian
cat >> temp.txt <<END_TEXT

# SFX 5.8 port forward
confflags += --without-included-ltdl \\
                        --without-libgrpc++ \\
                        --without-libgps \\
                        --without-libriemann_client \\
                        --without-libsigrok \\
                        --disable-cpusleep \\
                        --disable-dpdkstat \\
                        --disable-grpc \\
                        --disable-gps \\
                        --disable-netstat_udp \\
                        --disable-lua \\
                        --disable-mqtt \\
                        --disable-intel_rdt \\
                        --disable-write_riemann \\
                        --disable-dpdkevents \\
                        --disable-intel_pmu \\
                        --disable-zookeeper \\
                        --disable-pinba \\
                        --disable-amqp \\
                        --disable-amqp1 \\
                        --disable-barometer \\
                        --disable-capabilities \\
                        --disable-zone \\
                        --disable-dpdk_telemetry \\
                        --disable-write_kafka \\
                        --disable-write_mongodb \\
                        --disable-write_prometheus \\
                        --disable-write_stackdriver \\
                        --disable-static

# SFX name length settings
confflags += --with-data-max-name-len=1024
END_TEXT

sed -i '/--enable-all-plugins/r temp.txt' rules
rm -f temp.txt

START_LINE=$(grep -n 'Build-Depends:' control | cut -d: -f 1)
END_LINE=$(grep -n 'Build-Conflicts:' control  | cut -d: -f 1)

sed -i "$START_LINE,$END_LINE d" control

cat >> temp.txt <<END_TEXT
Build-Depends: debhelper (>= 9), dpkg-dev (>= 1.14.10), dh-systemd, po-debconf, dh-strip-nondeterminism, dh-autoreconf,
 bison, flex, autotools-dev, libltdl-dev, pkg-config,
 libmysqlclient-dev,
 libiptc-dev (>= 1.8.4-2) [linux-any] | libip4tc-dev [linux-any] | iptables-dev (>= 1.4.3.2-2) [linux-any],
 libiptc-dev (>= 1.8.4-2) [linux-any] | libip6tc-dev [linux-any] | iptables-dev (>= 1.4.3.2-2) [linux-any],
 javahelper,
 libatasmart-dev [linux-any],
 libcap-dev [linux-any],
 libcurl4-gnutls-dev (>= 7.18.2-5) | libcurl4-gnutls-dev (<= 7.18.2-1) | libcurl3-gnutls-dev,
 libdbi0-dev,
 libesmtp-dev,
 libgcrypt20-dev,
 libglib2.0-dev,
 libgps-dev,
 libhiredis-dev,
 libldap2-dev,
 liblua5.3-dev,
 libmemcached-dev,
 libmicrohttpd-dev,
 libmodbus-dev,
 libmongoc-dev,
 libmnl-dev [linux-any],
 libnotify-dev,
 libopenipmi-dev,
 liboping-dev (>= 0.3.3),
 libow-dev,
 libpcap0.8-dev | libpcap-dev,
 libperl-dev,
 libpq-dev,
 libriemann-client-dev (>= 1.6.0),
 librrd-dev (>= 1.4~),
 libsnmp-dev (>= 5.4.2.1~dfsg-4~) | libsnmp-dev | libsnmp9-dev,
 libsnmp-dev (>= 5.4.2.1~dfsg-4~) | perl (<< 5.10.1~rc2-1~),
 libtokyocabinet-dev [linux-any],
 libtokyotyrant-dev [linux-any],
 libudev-dev [linux-any],
 libvarnishapi-dev,
 libvirt-dev (>= 0.4.0-6) [linux-any],
 libxml2-dev,
 libyajl-dev,
 linux-libc-dev (>= 2.6.25-4) [linux-any] | linux-libc-dev (<< 2.6.25-1) [linux-any],
 default-jdk [!hppa !sparc !kfreebsd-i386 !kfreebsd-amd64],
 python3-dev,
 libmosquitto-dev,
 libslurm-dev
END_TEXT

sed -i '/Uploaders:.*/r temp.txt' control
cat control
rm -f temp.txt && cd ..
#Build the package and its dependencies
mk-build-deps --tool 'apt-get -y --no-install-recommends' --install debian/control
debuild -b -uc -us