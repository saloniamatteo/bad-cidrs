PLOT_OWNERS_COUNT=20
PLOT_COUNTRIES_COUNT=20

# Check if the gnuplot command is available
check_gnuplot:
	@if ! command -v gnuplot &> /dev/null; then \
		echo "Please install GNU plot! (command: gnuplot)"; \
		exit 1; \
	fi

# Check if the geoiplookup command is available
check_geoip:
	@if ! command -v geoiplookup &> /dev/null; then \
		echo "Please install the GeoIP command & databases! (command: geoiplookup)"; \
		exit 1; \
	fi

# Create plot: owners/companies
companies: plot-owners

owners: plot-owners

plot-owners: check_geoip cidrs-oneline.txt
	@sort plot/cidrs-oneline.txt | uniq -c | sort -nr | head -n ${PLOT_OWNERS_COUNT} > plot/owners.txt
	@GNUPLOT_LIB="plot" gnuplot plot/owners.gnu
	@echo "owners.png"

cidrs-oneline.txt:
	@awk '{print $$2}' CIDRs.txt > plot/cidrs-oneline.txt

# Create plot: countries
countries: plot-countries

plot-countries: check_gnuplot countries-list.txt
	@sort plot/countries-list.txt | uniq -c | sort -nr | head -n ${PLOT_COUNTRIES_COUNT} > plot/countries.txt
	@GNUPLOT_LIB="plot" gnuplot plot/countries.gnu
	@echo "countries.png"

countries-list.txt:
	plot/fetch_countries.sh

# Create plot: world map
map: plot-map

plot-map: check_gnuplot points.txt
	@GNUPLOT_LIB="plot" gnuplot plot/world_map.gnu
	@echo "world_map.png"

points.txt: check_geoip
	plot/fetch_ip_locations.sh

# Clean stuff
clean:
	rm -f *.png
	rm -f plot/cidrs-oneline.txt
	rm -f plot/countries-list.txt
	rm -f plot/countries.txt
	rm -f plot/country.txt
	rm -f plot/owners.txt
	rm -f plot/points.txt

.PHONY: companies plot-owners countries plot-countries map plot-map clean
