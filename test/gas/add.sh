#!/usr/bin/env bash

BASE_URL=`cat ../../.env`
# 田んぼ_西北
TARGET=田んぼ_西北
NAME=`python3 -c "import urllib.parse; print(urllib.parse.quote('${TARGET}'))"`

URL="${BASE_URL}?action=add&sheetName=${NAME}"

echo ${URL}

# https://qiita.com/cajonito/items/9e66ef60831d51105bc0
# 「リダイレクト先はGETすべし」という習慣の様で、-L付き-X POSTではリダイレクト後にGETしてしまう、らしい(curlの挙動)
# -Xせず-Lのみとするとうまく動くみたい
curl -L --post302 -X POST ${URL} \
  -H "Content-Type: application/json" \
  -d '{"年":"2025", "収穫量":"400kg", "苗の量":"10袋", "メモ":"テスト"}'
