#!/usr/bin/env bash

export THRIFT_VERSION="0.9.3"
export THRIFT_HOME="/opt/toolchain/thrift-${THRIFT_VERSION}"
export PROTOC_HOME="/opt/toolchain/protobuf-2.5.0"
export PATH="${THRIFT_HOME}/bin:${PROTOC_HOME}/bin:$PATH"

if [[ ! -d "$THRIFT_HOME" ]]; then
    echo "THRIFT HOME ($THRIFT_HOME) does not exist!"
    exit 1
fi

if [[ ! -d "$PROTOC_HOME" ]]; then
    echo "PROTOC HOME ($PROTOC_HOME) does not exist!"
    exit 1
fi

# Somehow, mvn is not on the path by default
export PATH="$MAVEN3_HOME/bin:$PATH"

CURRENT_BRANCH=cdh6.3.3

# we need to re-run setup inside the docker container to get mvn-gbn script.
SETUP_FILE="$(mktemp)"
function cleanup_setup_file {
    rm -rf "$SETUP_FILE"
}
trap cleanup_setup_file EXIT

function die() {
    echo "$@" >&2
    exit 1
}

curl https://github.mtv.cloudera.com/raw/cdh/cdh/${CURRENT_BRANCH}/tools/gerrit-unittest-setup.sh -o "$SETUP_FILE"
source "$SETUP_FILE"

# mvn-gbn should now be on our path
mvn-gbn clean verify --fail-at-end || die "Tests failed with java8 ($JAVA_HOME)"
mvn-gbn verify --fail-at-end -Djvm="$OPENJDK_11_HOME/bin/java" || die "Tests failed with java11 ($OPENJDK_11_HOME)"
