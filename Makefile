.PHONY: all
all: risk_free_lending.pdf

%.pdf: %.org $(wildcard *.svg) init.el
	yes yes | emacs \
	    --batch \
	    --load=init.el \
	    $< \
	    -f org-babel-tangle
	yes yes | emacs \
	    --batch \
	    --load=init.el \
	    $< \
	    -f org-latex-export-to-pdf

.PHONY: clean
clean:
	rm -rf \
	   _minted-*/ \
	   svg-inkscape/ \
	   texfrag/ \
	   *.synctex.gz \
	   *.aux \
	   *.bbl \
	   *.bbla \
	   *.bcf \
	   *.bib \
	   *.blg \
	   *.dvi \
	   *.fdb_latexmk \
	   *.fls \
	   *.log \
	   *.out \
	   *.pdf \
	   *.pyg \
	   *.tex \
	   *.tex~ \
	   *.svg

.PHONY: full-clean
full-clean:
	make clean
	rm -rf ltximg/ auto/
