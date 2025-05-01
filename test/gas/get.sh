#!/usr/bin/env bash

BASE_URL=`cat ../../.env`
# 田んぼ_西北
TARGET=田んぼ_西北
NAME=`python3 -c "import urllib.parse; print(urllib.parse.quote('${TARGET}'))"`
URL="${BASE_URL}?action=get&sheetName=${NAME}"

echo ${URL}
curl -L ${URL}
