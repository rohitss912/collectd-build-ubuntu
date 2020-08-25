#! /bin/bash
set -e

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

#Setup dquilt for applying patches
echo "alias dquilt="quilt --quiltrc=${HOME}/.quiltrc-dpkg"" >> ~/.bashrc
echo "complete -F _quilt_completion $_quilt_complete_opt dquilt" >> ~/.bashrc
cat > ~/.quiltrc-dpkg <<EOL
d=.
while [ ! -d $d/debian -a $(readlink -e echo "$d") != / ];
    do d=$d/..; done
if [ -d $d/debian ] && [ -z $QUILT_PATCHES ]; then
    # if in Debian packaging tree with unset $QUILT_PATCHES
    QUILT_PATCHES="debian/patches"
    QUILT_PATCH_OPTS="--reject-format=unified"
    QUILT_DIFF_ARGS="-p ab --no-timestamps --no-index --color=auto"
    QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"

    if ! [ -d $d/debian/patches ]; then mkdir $d/debian/patches; fi
fi
EOL
chmod +x ~/.quiltrc-dpkg
source ~/.bashrc

#Pulls source .dsc .debian.tar.gz .orig.tar.gz and source code from https://packages.ubuntu.com/groovy/collectd
mkdir -p "$SCRIPT_DIR"/collectd_source
cd "$SCRIPT_DIR"/collectd_source

apt-get source collectd

ls -F

#pull main branch code
mkdir -p "$SCRIPT_DIR"/collectd_latest
cd "$SCRIPT_DIR"/collectd_latest

wget https://github.com/collectd/collectd/archive/main.zip
unzip main.zip

cd collectd-main
#generates the configure and Makefile.in scripts
./build.sh
cd ..
#Tar the new upstream code
tar -cvzf collectd-5.11.1-1.tar.gz collectd-main
ls -F

cd "$SCRIPT_DIR"/collectd_source/collectd-5.11.0/
uupdate -v 5.11.1-1 ../../collectd_latest/collectd-5.11.1-1.tar.gz
cd ../collectd-5.11.1-1
while dquilt push; do dquilt refresh; done

#TODO - dch and 'debuild -b -uc -us'


