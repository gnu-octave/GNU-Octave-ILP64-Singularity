# GNU Octave ILP64 Singularity

This projects purpose is to create a [Singularity][] image of [GNU Octave][]
for high-performance computing.  [GNU Octave][] and all of it's dependent
libraries are compiled to support [ILP64][].  That means the data types
`int`, `long`, and pointers are assured to have the same size of 64-bit.
This enables computations with matrices and vectors with more than 2^31
elements.

[Singularity]: https://sylabs.io/singularity/
[GNU Octave]: https://www.octave.org/
[ILP64]: https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models

The resulting [GNU Octave][] image has a **size of about 800 MB** are available
from the [Singularity Library][].  It can be pulled (downloaded) from any system
having [Singularity][] installed using the command:

[Singularity Library]: https://cloud.sylabs.io/library/siko1056

    singularity pull library://siko1056/default/gnu_octave:5.2.0

To execute [GNU Octave][] from this image, run from the same directory:

    singularity run gnu_octave_5.2.0.sif

or

    singularity run gnu_octave_5.2.0.sif --gui

to start the graphical user interface (GUI).

All currently available [GNU Octave][] versions are:

- `singularity pull library://siko1056/default/gnu_octave:5.2.0` (2020-01-31)
- `singularity pull library://siko1056/default/gnu_octave:5.1.0` (2019-02-23)
- `singularity pull library://siko1056/default/gnu_octave:4.4.1` (2018-08-09)
