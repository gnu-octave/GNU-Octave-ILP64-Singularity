# GNU Octave 64 Singularity

This projects purpose is to create a [GNU Octave][] [Singularity][] image
for high-performance computing.  The GNU Octave version is compiled using
64-bit indices consistently for all of the library dependencies to support
computations with matrices and vectors with more than 2^31 elements.

[GNU Octave]: https://www.gnu.org/software/octave/
[Singularity]: https://sylabs.io/singularity/

The resulting GNU Octave image are available from the [Singularity Library][]
and can be pulled (downloaded) from any system having [Singularity][] installed
via:

[Singularity Library]: https://cloud.sylabs.io/library/siko1056

    singularity pull library://siko1056/gnu_octave:stable

To execute GNU Octave from this image, just run from the same directory:

    singularity run gnu_octave_stable.sif

The author of this project has created a [similar project][] for native
compilation on **Linux systems**.  There one can find more details about the
large data limitation of GNU Octave.

[similar project]: https://github.com/octave-de/GNU-Octave-enable-64
