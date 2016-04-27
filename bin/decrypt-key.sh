#!/bin/sh
set -eu

F_IN=$1
F_OUT=$2

openssl aes-256-cbc -d -salt -md sha256 -in "$F_IN" -out "$F_OUT"
