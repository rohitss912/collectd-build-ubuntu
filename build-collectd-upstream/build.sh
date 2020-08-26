#!/bin/bash
set -e

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

#Setup dquilt for applying patches
cat >> ~/.quiltrc-dpkg <<END_TEXT
d=.
while [ ! -d \$d/debian -a \$(readlink -e \$d) != / ];
    do d=\$d /..; done
if [ -d \$d/debian ] && [ -z \$QUILT_PATCHES ]; then
    # if in Debian packaging tree with unset \$QUILT_PATCHES
    QUILT_PATCHES="debian/patches"
    QUILT_PATCH_OPTS="--unified-reject-files"
    QUILT_DIFF_ARGS="-p ab --no-timestamps --no-index --color=auto"
    QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"

    if ! [ -d \$d/debian/patches ]; then mkdir \$d/debian/patches; fi
fi
END_TEXT
chmod +x ~/.quiltrc-dpkg
DQUILT="quilt --quiltrc=${HOME}/.quiltrc-dpkg"
source ~/.bashrc

#Pulls source .dsc .debian.tar.gz .orig.tar.gz and source code from https://packages.ubuntu.com/groovy/collectd
mkdir -p "$SCRIPT_DIR"/collectd_source
cd "$SCRIPT_DIR"/collectd_source

apt-get source collectd

ls -F

#pull main branch code perform some clenaup
mkdir -p "$SCRIPT_DIR"/collectd_latest
cd "$SCRIPT_DIR"/collectd_latest

wget https://github.com/collectd/collectd/archive/402e6b060cb81bce2a3905ccbca2ca6fbec73e43.zip
unzip 402e6b060cb81bce2a3905ccbca2ca6fbec73e43.zip

cp -rf collectd* collectd-main
cd collectd-main
rm -rf docs .travis.yml .mailmap .gitmodules .github .clang-format .cirrus.yml
#generates the configure and Makefile.in scripts
./build.sh
cd ..
#Tar the new upstream code
tar -cvzf collectd-5.11.1-1.tar.gz collectd-main

# Update the current source with upstream changes
cd "$SCRIPT_DIR"/collectd_source/collectd-5.11.0/
uupdate -v 5.11.1-1 ../../collectd_latest/collectd-5.11.1-1.tar.gz
cd ../collectd-5.11.1-1

#Update the rules file with collectd-signalfx settings
cd debian
cat >> temp.txt <<END_TEXT

# SFX 5.8 port forward
confflags += --without-included-ltdl \\
                        --without-libgrpc++ \\
                        --without-libgps \\
                        --without-liblua \\
                        --without-libriemann \
                        --without-libsigrok \\
                        --disable-cpusleep \\
                        --disable-dpdkstat \\
                        --disable-grpc \\
                        --disable-gps \\
                        --disable-lua \\
                        --disable-mqtt \\
                        --disable-intel_rdt \\
                        --disable-write_riemann \\
                        --disable-dpdkevents \\
                        --disable-intel_pmu \\
                        --disable-zone

# SFX name length settings
confflags += --with-data-max-name-len=1024
END_TEXT

sed -i '/--enable-all-plugins/r temp.txt' rules
rm -f temp.txt
cd ..

#Update failing Patch as per new source code.
sed -i '/our \$TypesDB.*/d' ./debian/patches/collection_conf_path.patch

# Recursively apply all patches
while $DQUILT push; do $DQUILT refresh; done

# builds the debain package
debuild -b -uc -us
#TODO - dch