#!/usr/bin/gnuplot
# plot the companies/owners top 20 chart

reset

set terminal pngcairo size 1920,1080 enhanced font 'Red Hat Display,14'
set output 'owners.png'

set title "Bad CIDRs owner overview (top 20)"
set xlabel "Owner/company"
set ylabel "Occurrence Count"

set style data histograms
set style fill solid 1.0 border -1

# Customize the x-axis to use the first column's text labels
set xtics rotate by -45

# Here "using 2:xtic(1)" means: column 1 is the y-value (occurrence count),
# and column 2 is used for the x-tic labels.
plot 'owners.txt' using 1:xtic(2) title 'Occurrences' lc rgb "red"
