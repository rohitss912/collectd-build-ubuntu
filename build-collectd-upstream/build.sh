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
    QUILT_PATCH_OPTS="--reject-format=unified"
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

wget https://github.com/collectd/collectd/archive/main.zip
unzip main.zip

cd collectd-main
rm -rf docs .travis.yml .mailmap .gitmodules .github .clang-format .cirrus.yml
#generates the configure and Makefile.in scripts
./build.sh
cd ..
#Tar the new upstream code
tar -cvzf collectd-5.11.1-1.tar.gz collectd-main

cd "$SCRIPT_DIR"/collectd_source/collectd-5.11.0/
uupdate -v 5.11.1-1 ../../collectd_latest/collectd-5.11.1-1.tar.gz
cd ../collectd-5.11.1-1

sed -i '/our \$TypesDB.*/d' ./debian/patches/collection_conf_path.patch

while $DQUILT push; do $DQUILT refresh; done

debuild -b -uc -us
#TODO - dch


