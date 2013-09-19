#! /bin/bash

# will create a pdf for each of the screen width

WIDTHS="320 480 768 960 1280 1600";
MARGIN=20
URL="http://www.example.com/"
PAGEPATH="home.html"
OPTIONS="--margins ${MARGIN} --paginate no --orientation landscape --print-background yes"

for i in ${WIDTHS}; do
  echo "generating pdf for screen width ${i}px"
  wkpdf --source ${SITE}${PAGEPATH} --screen-width ${i} ${OPTIONS} --output "${PAGEPATH}-${i}px.pdf"
done
