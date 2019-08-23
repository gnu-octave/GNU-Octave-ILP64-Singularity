################################################################################
#
# Build a GNU Octave singularity image.
#
################################################################################

.EXPORT_ALL_VARIABLES:

ROOT_DIR    ?= ${PWD}
SRC_CACHE   ?= $(ROOT_DIR)/source-cache
BUILD_DIR   ?= $(ROOT_DIR)/build

IGNORE := $(shell mkdir -p $(SRC_CACHE) $(BUILD_DIR))

all:

################################################################################
#
# Build rules for Ubuntu (https://ubuntu.com/).
#
################################################################################

UBUNTU_VER=18.04

$(BUILD_DIR)/system_up_to_date:
ifneq ($(shell lsb_release -si),Ubuntu)
	@echo "This project is unlikely to work on other systems than Ubuntu $(UBUNTU_VER)."
	exit 1
endif
ifneq ($(shell lsb_release -sr),$(UBUNTU_VER))
	@echo "This project is unlikely to work on other systems than Ubuntu $(UBUNTU_VER)."
	exit 1
endif
	./src/install_build_prerequisites_ubuntu_$(UBUNTU_VER).sh
	touch $(BUILD_DIR)/system_up_to_date


################################################################################
#
# Build rules for singularity (https://sylabs.io/).
#
################################################################################

SINGULARITY_VER=3.3.0

singularity: /usr/local/bin/singularity

$(SRC_CACHE)/singularity-${SINGULARITY_VER}.tar.gz:
	cd $(SRC_CACHE) && \
	wget https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VER}/singularity-${SINGULARITY_VER}.tar.gz

/usr/local/bin/singularity: \
	$(SRC_CACHE)/singularity-${SINGULARITY_VER}.tar.gz \
	$(BUILD_DIR)/system_up_to_date
	cd $(BUILD_DIR) && tar -xf $<
	cd $(BUILD_DIR)/singularity \
	&& ./mconfig --prefix=/usr/local \
	&& make -C ./builddir \
	&& sudo make -C ./builddir install


################################################################################
#
# Build rules for GNU Octave enable 64
# (https://github.com/octave-de/GNU-Octave-enable-64).
#
################################################################################

OCTAVE_VER=5.1.1

$(ROOT_DIR)/GNU-Octave-enable-64:
	git submodules init
	git submodules update

/usr/bin/octave-$(OCTAVE_VER): $(BUILD_DIR)/system_up_to_date \
	$(ROOT_DIR)/GNU-Octave-enable-64
	mkdir -p $(BUILD_DIR)/GNU-Octave-enable-64
	sudo ./GNU-Octave-enable-64/Makefile_log.sh -j2 \
	  SRC_CACHE=$(SRC_CACHE) \
	  BUILD_DIR=$(BUILD_DIR)/GNU-Octave-enable-64 \
	  INSTALL_DIR=/usr \
	  OCTAVE_VER=stable


################################################################################
#
# Build rules for the final singularity image.
#
################################################################################

singularity_image: /usr/local/bin/singularity \
	/usr/bin/octave-$(OCTAVE_VER)
