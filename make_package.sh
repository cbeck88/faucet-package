#!/bin/bash

# Builds a .tar.gz archive that can be unpacked in root to install
#
# Usage:
# ./make_package.sh
#
# supervisord configuration files are in `conf` directory.
# nginx conf is in the root
# account_key is in `example` directory.

set -e

usage() {
    cat << EOF
    ./make_package.sh

    Produces package.tar.gz artifact in root of repository
    Unpack this in / to install a supervisord config that runs the services
    with autorestart=true.
EOF
}

if [ "$#" -ne 0 ]; then
    echo "wrong number of arguments: $#"
    usage
    exit 1
fi


ROOT=`git rev-parse --show-toplevel`

if [ ! -f "$ROOT/mobilecoin/target/release/mobilecoind" ]; then
    echo "mobilecoin/target/release/mobilecoind not found: You must build in release mode before packaging"
    exit 1
fi

if [ ! -f "$ROOT/mobilecoin/target/release/mobilecoind-dev-faucet" ]; then
    echo "mobilecoind/target/release/mobilecoind-dev-faucet not found: You must build in release mode before packaging"
    exit 1
fi

cd /tmp
rm -rf package
mkdir -p package
cd package
mkdir -p usr/local/bin/
mkdir -p var/lib/mobilecoind
# Note: If we don't put a ledger in the package, then don't create mobilecoind/ledger-db, the mobilecoind process wants to do that

mkdir -p var/lib/mobilecoind/watcher-db
mkdir -p var/lib/mobilecoind/mobilecoind-db
mkdir -p var/lib/faucet
mkdir -p etc/supervisor/conf.d/

cd ..
chmod -R 755 package
cd package

cp -f "$ROOT/mobilecoin/target/release/mobilecoind" usr/local/bin/
chmod 755 usr/local/bin/mobilecoind
cp -f "$ROOT/conf/mobilecoind.conf" etc/supervisor/conf.d/mobilecoind.conf
chmod 644 etc/supervisor/conf.d/mobilecoind.conf

# This is needed for mobilecoind to be able to send to fog
cp -f "$ROOT/mobilecoin/ingest-enclave.css" var/lib/mobilecoind/
chmod 644 var/lib/mobilecoind/ingest-enclave.css

cp -f "$ROOT/mobilecoin/target/release/mobilecoind-dev-faucet" usr/local/bin/
chmod 755 usr/local/bin/mobilecoind-dev-faucet
cp -f "$ROOT/conf/faucet.conf" etc/supervisor/conf.d/faucet.conf
chmod 644 etc/supervisor/conf.d/faucet.conf
cp -f "$ROOT/example/account_key.json" var/lib/faucet/account_key_example.json
chmod 640 var/lib/faucet/account_key_example.json

cp -f "$ROOT/nginx.conf" var/lib/faucet/nginx.conf
chmod 644 var/lib/faucet/nginx.conf
cp -f "$ROOT/conf/nginx.conf" etc/supervisor/conf.d/nginx.conf
chmod 644 etc/supervisor/conf.d/nginx.conf

cd ..
tar cvfz "package.tar.gz" --transform "s|^package||" package
mv package.tar.gz "$ROOT/"
rm -rf package
