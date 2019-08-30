################################################################################
##
##  Building a GNU Octave singularity image using 64 bit libraries.
##
################################################################################

OCTAVE_VER        ?= 5.1.0
OCTAVE_STABLE_VER ?= 5.1.1

BUILD_DIR ?= build
LOG_DIR   ?= log/$(BUILD_DIR)

all: $(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).sif

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(LOG_DIR):
	mkdir -p $(LOG_DIR)

# Octave build preparation
$(BUILD_DIR)/01_build_openblas.sif:     $(BUILD_DIR)/00_build_ubuntu.sif
$(BUILD_DIR)/02_build_suitesparse.sif:  $(BUILD_DIR)/01_build_openblas.sif
$(BUILD_DIR)/03_build_arpack_ng.sif:    $(BUILD_DIR)/02_build_suitesparse.sif
$(BUILD_DIR)/04_build_qrupdate.sif:     $(BUILD_DIR)/03_build_arpack_ng.sif
$(BUILD_DIR)/05_build_glpk.sif:         $(BUILD_DIR)/04_build_qrupdate.sif

# Octave builds
$(BUILD_DIR)/06_build_octave_$(OCTAVE_VER).sif: $(BUILD_DIR)/05_build_glpk.sif
$(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).sif: \
	$(BUILD_DIR)/06_build_octave_$(OCTAVE_VER).sif

$(BUILD_DIR)/06_build_octave_$(OCTAVE_VER).def: \
	 src/06_build_octave_VERSION.def | $(BUILD_DIR)
	cp $< $@
	sed -i -e 's/VERSION/$(OCTAVE_VER)/g' $@
ifeq ($(OCTAVE_VER),$(OCTAVE_STABLE_VER))
	# Obtain the latest stable version from another source.
	sed -i -e 's/ftpmirror.gnu.org\/octave/octave.mround.de/g' $@
endif

$(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).def: \
	src/gnu_octave_VERSION.def | $(BUILD_DIR)
	cp $< $@
	sed -i -e 's/VERSION/$(OCTAVE_VER)/g' $@

$(BUILD_DIR)/%.def: src/%.def | $(BUILD_DIR)
	cp $< $@

$(BUILD_DIR)/%.sif: $(BUILD_DIR)/%.def | $(BUILD_DIR) $(LOG_DIR)
	sudo singularity build $@ $< \
	  2>&1 | tee log/$@-$(shell date +%F_%H-%M-%S).log.txt

export_def: $(BUILD_DIR)/gnu_octave_$(OCTAVE_VER)_all.def

$(BUILD_DIR)/gnu_octave_$(OCTAVE_VER)_all.def: \
	$(BUILD_DIR)/00_build_ubuntu.def \
	$(BUILD_DIR)/01_build_openblas.def \
	$(BUILD_DIR)/02_build_suitesparse.def \
	$(BUILD_DIR)/03_build_arpack_ng.def \
	$(BUILD_DIR)/04_build_qrupdate.def \
	$(BUILD_DIR)/05_build_glpk.def \
	$(BUILD_DIR)/06_build_octave_$(OCTAVE_VER).def \
	$(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).def \
	| $(BUILD_DIR)
	head -n  2 $(BUILD_DIR)/00_build_ubuntu.def      >  $@
	echo -e "Stage: build\n\n%post\n"                >> $@
	tail -n +5 $(BUILD_DIR)/00_build_ubuntu.def      >> $@
	sed -i '$${s/$$/ \\/}' $@
	tail -n +5 $(BUILD_DIR)/01_build_openblas.def    >> $@
	sed -i '$${s/$$/ \\/}' $@
	tail -n +5 $(BUILD_DIR)/02_build_suitesparse.def >> $@
	sed -i '$${s/$$/ \\/}' $@
	tail -n +5 $(BUILD_DIR)/03_build_arpack_ng.def   >> $@
	sed -i '$${s/$$/ \\/}' $@
	tail -n +5 $(BUILD_DIR)/04_build_qrupdate.def    >> $@
	sed -i '$${s/$$/ \\/}' $@
	tail -n +5 $(BUILD_DIR)/05_build_glpk.def        >> $@
	sed -i '$${s/$$/ \\/}' $@
	tail -n +5 $(BUILD_DIR)/06_build_octave_$(OCTAVE_VER).def >> $@
	tail -n +9 $(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).def      >> $@
