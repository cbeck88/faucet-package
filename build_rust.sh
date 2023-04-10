#!/bin/bash

set -ex

git submodule update --init --recursive

pushd mobilecoin

./tools/download_sigstruct.sh 

export SGX_MODE=HW IAS_MODE=PROD CONSENSUS_ENCLAVE_CSS=$(pwd)/consensus-enclave.css

cargo build --release -p mc-mobilecoind -p mc-mobilecoind-dev-faucet --feature mc-mobilecoind/bypass-ip-check

popd
