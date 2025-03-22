#!/usr/bin/gnuplot
# plot the world map with lon,lat points from points.txt

reset

set terminal pngcairo size 2560,1440 enhanced font 'Red Hat Display,14'
set output 'world_map.png'

set title "Bad CIDRs geo overview"

set xlabel "Longitude"
set ylabel "Latitude"
set xrange [-180:180]
set xtics -180,40,180
set mxtics 2
set yrange [-90:90]
set ytics -90,20,90
set mytics 2
unset key

set view map

set datafile separator ','
set size ratio -1

plot 'natural-earth-2560x1440px.txt' w rgbimage, \
	 'points.txt' w p ls 2 lw 2 lc rgb "red"
