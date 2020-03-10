################################################################################
##
##  Building a GNU Octave singularity image using 64 bit libraries.
##
################################################################################

# Define the default Octave version OCTAVE_VER which must be available at
# https://ftpmirror.gnu.org/octave.

OCTAVE_VER ?= 5.2.0

# Set the default build and log path.

BUILD_DIR ?= $(shell pwd)/build
LOG_DIR   ?= $(shell pwd)/log

# Default target is to build the GNU Octave singularity image step by step to
# decrease the build time in case of changes.

all: $(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).sif

################################################################################
# Directory creation rules.
################################################################################

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(LOG_DIR):
	mkdir -p $(LOG_DIR)

################################################################################
# Singularity definition file rules and dependencies.
################################################################################

# Generic pattern rule for definition files, just copy them to the build
# directory.

$(BUILD_DIR)/%.def: src/%.def | $(BUILD_DIR)
	cp $< $@

# Specialization for the Octave build, insert the desired version and changes
# the download URL for the latest stable release tarball.

$(BUILD_DIR)/07_build_octave_$(OCTAVE_VER).def: \
	src/07_build_octave_VERSION.def | $(BUILD_DIR)
	cp $< $@
	sed -i -e 's/VERSION/$(OCTAVE_VER)/g' $@

# Specialization for the final Octave deployment, insert the desired version.

$(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).def: \
	src/gnu_octave_VERSION.def | $(BUILD_DIR)
	cp $< $@
	sed -i -e 's/VERSION/$(OCTAVE_VER)/g' $@

################################################################################
# Singularity image file (sif) rules and dependencies.
################################################################################

# Generic pattern rule for images.

$(BUILD_DIR)/%.sif: $(BUILD_DIR)/%.def | $(BUILD_DIR) $(LOG_DIR)
	cd $(BUILD_DIR) \
	  && singularity build  $(notdir $@) $(notdir $<) \
	  2>&1 | tee $(LOG_DIR)/$(notdir $@)-$(shell date +%F_%H-%M-%S).log.txt

# Define dependencies for the Octave build preparation images.

$(BUILD_DIR)/01_build_openblas.sif:    $(BUILD_DIR)/00_build_ubuntu.sif
$(BUILD_DIR)/02_build_suitesparse.sif: $(BUILD_DIR)/01_build_openblas.sif
$(BUILD_DIR)/03_build_arpack_ng.sif:   $(BUILD_DIR)/02_build_suitesparse.sif
$(BUILD_DIR)/04_build_qrupdate.sif:    $(BUILD_DIR)/03_build_arpack_ng.sif
$(BUILD_DIR)/05_build_glpk.sif:        $(BUILD_DIR)/04_build_qrupdate.sif
$(BUILD_DIR)/06_build_sundials.sif:    $(BUILD_DIR)/05_build_glpk.sif
$(BUILD_DIR)/07_build_octave_$(OCTAVE_VER).sif: \
	                               $(BUILD_DIR)/06_build_sundials.sif
$(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).sif: \
	                               $(BUILD_DIR)/07_build_octave_$(OCTAVE_VER).sif

clean:
	mv $(LOG_DIR)/* $(LOG_DIR).old
	$(RM) -R $(BUILD_DIR) $(LOG_DIR)

