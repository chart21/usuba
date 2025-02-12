.PHONY: all clean configure

# Directories
SRC_DIR := src
BIN_DIR := bin
SAMPLES_DIR := ../examples/samples
# MENHIR := menhir
# MENHIRFLAGS := --infer --explain
# INCLUDES := -I normalization -I optimization -I parsing -I c_gen -I verification -I c_gen/runtimes -I tests -I tightprove -I tightprove/parsing -I maskverif
DUNE := dune

MAIN := main

all:
	@if [ ! -f ./src/config.ml ]; then \
		echo "config.ml was not found.";\
		echo "./configure will be executed but you can/should rerun it if your directories are not located in the same places"; \
		./configure; \
	fi
	@echo $(FILE_EXISTS)
	$(DUNE) build
	chmod +w _build/default/bin/cli/main.exe
	cp _build/default/bin/cli/main.exe usubac

clean:
	rm -f *~ .*~ usubac
	$(DUNE) clean

test: all
	./usubac -tests
	@echo $(SAMPLES_DIR)
	./run_checks.pl --samples $(SAMPLES_DIR)
