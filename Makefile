################################################################################
##
##  Building a GNU Octave singularity image using 64 bit libraries.
##
################################################################################

OCTAVE_VER ?= stable

all: build/gnu_octave_$(OCTAVE_VER).sif

# Octave build preparation
build/01_build_openblas.sif:     build/00_ubuntu_build_image.sif
build/02_build_suitesparse.sif:  build/01_build_openblas.sif
build/03_build_arpack_ng.sif:    build/02_build_suitesparse.sif
build/04_build_qrupdate.sif:     build/03_build_arpack_ng.sif
build/05_build_glpk.sif:         build/04_build_qrupdate.sif

# Octave builds
build/06_build_octave_stable.sif:  build/05_build_glpk.sif
build/gnu_octave_stable.sif:       build/06_build_octave_stable.sif

build/%.sif: src/%.def
	mkdir -p build
	sudo singularity build $@ $<
