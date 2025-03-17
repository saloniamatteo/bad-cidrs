# Set the output terminal and file (optional, for saving to a file)
set terminal pngcairo size 1920,1080 enhanced font 'Red Hat Display,14'
set output 'owners.png'

# Set the style to use histograms with a solid fill
set style data histograms
set style fill solid 1.0 border -1

# Optionally, set a title and axis labels
set title "Bad CIDRs owner overview (top 20)"
set xlabel "Owner/company"
set ylabel "Occurrence Count"

# Customize the x-axis to use the first column's text labels
set xtics rotate by -45

# Plot the data; here "using 2:xtic(1)" means:
# column 1 is the y-value (occurrence count) and column 2 is used for the x-tic labels.
plot 'owners.txt' using 1:xtic(2) title 'Occurrences' lc rgb "red"
