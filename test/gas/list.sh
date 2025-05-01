#!/usr/bin/env bash

BASE_URL=`cat ../../.env`
URL="${BASE_URL}?action=list"

echo ${URL}
curl -L ${URL}
