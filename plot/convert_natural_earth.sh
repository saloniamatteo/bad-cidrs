#!/bin/bash
# https://gnuplotting.org/code/convert_natural_earth/index.html
# ./convert_natural_earth.sh $RES $FILE
# RES: desired resolution in pixels of gnuplot plot
# FILE: input tif-file
# -------------------------------------------------------------
# Get tif files from:
# https://www.naturalearthdata.com/downloads/10m-raster-data/
# -------------------------------------------------------------
RES="$1"
IN="$2"
SCALED="${IN%.tif}_${RES}px.tif"
OUT="${SCALED%.tif}.txt"

# resize tiff image to desired resolution
magick convert "$IN" -resize $RES "$SCALED"

# convert to txt file
magick convert "$SCALED" "$OUT"

# replace ": (" with ","
sed -i 's/: (/\,/' "$OUT"

# remove all unneeded entries at end of line
sed -i 's/).*$//' "$OUT"

# convert longitude and latitude to the right values
# 0..RES => -180..180
# 0..RES/2 => -90..89
mv "$OUT" "$OUT.tmp"
awk -F, '{$1=$1*360/'$RES'-180;$2=-1*($2*360/'$RES'-90);}1' OFS=, "$OUT.tmp" > "$OUT"
rm "$OUT.tmp"

# remove unneeded header
sed -i '1d' "$OUT"

# add blank lines for pm3d
sed -i "${RES}~${RES}G" "$OUT"

# add new header
sed -i '1s/^/# long, lat, r, g, b\n/' "$OUT"
