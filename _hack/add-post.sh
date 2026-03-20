#!/bin/bash
#
# Create post files from images.
#
# Run this from the repo root, not from ./hack!
#

set -e

TITLE="$1"
DATE="$2"
IMG="$3"

# Yeah... it's not great
FILENAME=$(echo ${DATE}-${TITLE} | sed -e 's/ - /-/g' -e "s/'//g" -e 's/ /-/g')

# Preflight
for v in TITLE DATE IMG FILENAME; do
    if [[ -z "${!v}" ]]; then
        echo "ERROR: $v is not set" >&2
        exit 1
    else
	echo "$v: ${!v}"
    fi
done

echo ""
echo "Are we good?"
read confirm

echo "Generating watermarked image..."
magick "${IMG}" \
  \( ./_hack/watermark.png -resize $(magick identify -format "%[fx:int(w*0.25)]" "${IMG}")x \) \
  -gravity southwest -geometry +10+10 -composite \
  "./images/${FILENAME}.jpg"

echo "Creating post..."
cat > "./_posts/$FILENAME.md" <<EOF
---
layout: post
title: "${TITLE}"
description: "Astrophotographs of ${TITLE} taken on ${DATE}"
date: ${DATE}
feature_image: images/${FILENAME}.jpg
---

* Telescope: **Seestar S30 (Mosaic Mode)**
* Total Exposure Time: **000 x 20s = 0.00 Hrs**
* Stacking Software: **Seestar app**
* Editing Software: **Seestar app**
* [Wikipedia entry for ${TITLE}](REPLACE)
EOF

echo "Dropping into post..."
vim "./_posts/$FILENAME.md"

echo "Done!"
