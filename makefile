all: 
	ocamlc -c FAlphabeta.ml
	ocamlc -c FMain.ml
	ocamlc -c FAlphabeta.cmo FSkeleton.ml
	ocamlc -c FAlphabeta.cmo FMain.cmo FSkeleton.cmo Puissance4.ml
	ocamlc -o demo graphics.cma FAlphabeta.cmo FMain.cmo FSkeleton.cmo Puissance4.cmo

clean:
	rm -rf demo *cmi *.cmo
