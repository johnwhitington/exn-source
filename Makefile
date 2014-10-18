SOURCES = exnsource.mli exnsource.ml

REAL_OCAMLFIND = ocamlfind

RESULT = exnsource

OCAMLNCFLAGS = -g -w -3
OCAMLBCFLAGS = -g -w -3
OCAMLLDFLAGS = -g

all : native-code-library byte-code-library htdoc

clean ::
	rm -rf doc

install : libinstall

-include OCamlMakefile

