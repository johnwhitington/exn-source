SOURCES = exnsource.mli exnsource.ml

REAL_OCAMLFIND = ocamlfind

RESULT = exnsource

OCAMLNCFLAGS = -g
OCAMLBCFLAGS = -g
OCAMLLDFLAGS = -g

all : native-code-library byte-code-library native-code htdoc

clean ::
	rm -rf doc

install : libinstall

-include OCamlMakefile

