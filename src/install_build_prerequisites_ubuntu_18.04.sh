#/bin/sh

sudo apt-get update \
&& sudo apt-get --yes upgrade \
&& sudo apt-get --yes autoremove \
&& sudo apt-get --no-install-recommends --yes install \
  autoconf \
  automake \
  bison \
  build-essential \
  clang \
  cmake \
  epstool \
  flex \
  gfortran \
  git \
  gnuplot-x11 \
  gperf \
  gzip \
  icoutils \
  libblas-dev \
  libcurl4-gnutls-dev \
  liblapack-dev \
  libpcre3-dev \
  libfftw3-dev \
  libfltk1.3-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libgl1-mesa-dev \
  libgl2ps-dev \
  libgmp-dev \
  libgpgme11-dev \
  libgraphicsmagick++1-dev \
  libhdf5-serial-dev \
  libosmesa6-dev \
  libqhull-dev \
  libqscintilla2-qt5-dev \
  libqt5opengl5-dev \
  libreadline-dev \
  librsvg2-bin \
  libseccomp-dev \
  libssl-dev \
  libsndfile1-dev \
  libtool \
  libxft-dev \
  llvm-dev \
  lpr \
  mercurial \
  openjdk-8-jdk \
  perl \
  pkg-config \
  portaudio19-dev \
  pstoedit \
  qtbase5-dev \
  qttools5-dev \
  qttools5-dev-tools \
  rsync \
  squashfs-tools \
  tar \
  texinfo \
  texlive \
  texlive-generic-recommended \
  transfig \
  uuid-dev \
  wget \
  zlib1g-dev \
&& sudo snap install --classic go
