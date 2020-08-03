################################################################################
##
##  Building a GNU Octave singularity image using 64 bit libraries.
##
################################################################################

# Define the default Octave version OCTAVE_VER which must be available at
# https://ftpmirror.gnu.org/octave.

OCTAVE_VER ?= 5.2.0

################################################################################
# Directory creation rules.
################################################################################

BUILD_DIR ?= $(shell pwd)/build
LOG_DIR   ?= $(shell pwd)/log

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(LOG_DIR):
	mkdir -p $(LOG_DIR)

################################################################################
# Common build targets
################################################################################

# Default target is to build the GNU Octave singularity image step by step to
# decrease the build time in case of changes.

.DEFAULT_GOAL := default
default: $(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).sif

# Convenience target to recursively build the latest Octave releases.

all-recent:
	$(MAKE) OCTAVE_VER=5.2.0
	$(MAKE) OCTAVE_VER=5.1.0
	$(MAKE) OCTAVE_VER=4.4.1

clean:
	mkdir -p        $(LOG_DIR).old
	mv $(LOG_DIR)/* $(LOG_DIR).old
	$(RM) -R $(BUILD_DIR) $(LOG_DIR)

################################################################################
# Singularity container library https://cloud.sylabs.io/
################################################################################

SINGULARITY_USER ?= siko1056
SINGULARITY_COLLECTION ?= default
SINGULARITY_LIB = library://$(SINGULARITY_USER)/$(SINGULARITY_COLLECTION)

interactive-upload:
	# Check the signatures and sign if necessary
	singularity verify $(BUILD_DIR)/gnu_octave_build.sif || \
	singularity sign   $(BUILD_DIR)/gnu_octave_build.sif
	singularity verify $(BUILD_DIR)/gnu_octave_5.2.0.sif || \
	singularity sign   $(BUILD_DIR)/gnu_octave_5.2.0.sif
	singularity verify $(BUILD_DIR)/gnu_octave_5.1.0.sif || \
	singularity sign   $(BUILD_DIR)/gnu_octave_5.1.0.sif
	singularity verify $(BUILD_DIR)/gnu_octave_4.4.1.sif || \
	singularity sign   $(BUILD_DIR)/gnu_octave_4.4.1.sif
	# Display login token for interactive login
	touch token
	cat   token
	singularity remote login
	# Push all images in the cloud
	singularity push $(BUILD_DIR)/gnu_octave_build.sif \
	           $(SINGULARITY_LIB)/gnu_octave_build:latest
	singularity push $(BUILD_DIR)/gnu_octave_4.4.1.sif \
	           $(SINGULARITY_LIB)/gnu_octave:4.4.1
	singularity push $(BUILD_DIR)/gnu_octave_5.1.0.sif \
	           $(SINGULARITY_LIB)/gnu_octave:5.1.0
	singularity push $(BUILD_DIR)/gnu_octave_5.2.0.sif \
	           $(SINGULARITY_LIB)/gnu_octave:5.2.0

################################################################################
# Singularity definition file rules and dependencies.
################################################################################

# Generic pattern rule for definition files, just copy them to the build
# directory.

$(BUILD_DIR)/%.def: src/%.def | $(BUILD_DIR)
	cp $< $@

# Specialization for the Octave build, insert the desired version and changes
# the download URL for the latest stable release tarball.

$(BUILD_DIR)/gnu_octave_build_$(OCTAVE_VER).def: \
	src/gnu_octave_build_VERSION.def | $(BUILD_DIR)
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

# Specialization for GNU Octave build image.

$(BUILD_DIR)/gnu_octave_build.sif: $(BUILD_DIR)/06_build_sundials.def \
                                 | $(BUILD_DIR) $(LOG_DIR)
	cd $(BUILD_DIR) \
	  && singularity build  $(notdir $@) $(notdir $<) \
	  2>&1 | tee $(LOG_DIR)/$(notdir $@)-$(shell date +%F_%H-%M-%S).log.txt

# Define dependencies for the Octave build preparation images.

$(BUILD_DIR)/01_build_openblas.sif:    $(BUILD_DIR)/00_build_ubuntu.sif
$(BUILD_DIR)/02_build_suitesparse.sif: $(BUILD_DIR)/01_build_openblas.sif
$(BUILD_DIR)/03_build_arpack_ng.sif:   $(BUILD_DIR)/02_build_suitesparse.sif
$(BUILD_DIR)/04_build_qrupdate.sif:    $(BUILD_DIR)/03_build_arpack_ng.sif
$(BUILD_DIR)/05_build_glpk.sif:        $(BUILD_DIR)/04_build_qrupdate.sif
$(BUILD_DIR)/gnu_octave_build.sif:     $(BUILD_DIR)/05_build_glpk.sif

$(BUILD_DIR)/gnu_octave_build_$(OCTAVE_VER).sif: \
                                       $(BUILD_DIR)/gnu_octave_build.sif
$(BUILD_DIR)/gnu_octave_$(OCTAVE_VER).sif: \
                                       $(BUILD_DIR)/gnu_octave_build_$(OCTAVE_VER).sif
