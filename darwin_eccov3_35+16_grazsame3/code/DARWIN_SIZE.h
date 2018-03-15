#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_SIZE.h
C     !INTERFACE:
C #include DARWIN_SIZE.h

C     !DESCRIPTION:
C Contains dimensions for the darwin model.
C
C nplank   :: number of plankton types
C nGroup   :: number of plankton functional groups
C             (for allometric trait generation)
C darwin_nlam :: number of wavebands
C             (must match RT_nlam with radtrans, 1 without)
C nopt     :: number of optical types (spectra to read in)
C nPhoto   :: number of phototrophs
C             (will have Chl tracer if DARWIN_ALLOW_CHL is defined)
C nPPplank :: number of primary production diagnostics to collect
C nGRplank :: number of grazing loss diagnostics to collect

      integer darwin_nlam, nopt
      integer nplank, nGroup
      integer nPhoto
      integer nPPplank
      integer nGRplank
      parameter(darwin_nlam=13)
      parameter(nopt=12)
      parameter(nplank=51)
      parameter(nGroup=9)
      parameter(nPhoto=35)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

CEOP
#endif /* ALLOW_DARWIN */
