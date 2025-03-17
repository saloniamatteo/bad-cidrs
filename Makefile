PLOT_OWNERS_COUNT=20
PLOT_COUNTRIES_COUNT=20

# Create plot: owners/companies
companies: plot-owners

owners: plot-owners

plot-owners: cidrs-oneline.txt
	@sort plot/cidrs-oneline.txt | uniq -c | sort -nr | head -n ${PLOT_OWNERS_COUNT} > plot/owners.txt
	@GNUPLOT_LIB="plot" gnuplot plot/owners.gp
	@echo "owners.png"

cidrs-oneline.txt:
	@awk '{print $$2}' CIDRs.txt > plot/cidrs-oneline.txt

# Create plot: countries
countries: plot-countries

plot-countries: countries-list.txt
	@sort plot/countries-list.txt | uniq -c | sort -nr | head -n ${PLOT_COUNTRIES_COUNT} > plot/countries.txt
	@GNUPLOT_LIB="plot" gnuplot plot/countries.gp
	@echo "countries.png"

countries-list.txt:
	plot/fetch_countries.sh

# Clean stuff
clean: clean-plot
	rm -f *.png

clean-plot:
	rm -f plot/cidrs-oneline.txt plot/countries.txt plot/countries-list.txt plot/country.txt plot/owners.txt

.PHONY: companies countries plot-owners plot-countries clean
