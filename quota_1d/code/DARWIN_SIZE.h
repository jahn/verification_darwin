#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for cell model.

      integer nplank, nGroup, darwin_nlam, nopt
      integer nPhoto
      integer nPPplank
      integer nGRplank
      parameter(nplank=16)
      parameter(nGroup=5)
      parameter(darwin_nlam=1)
      parameter(nopt=1)
      parameter(nPhoto=15)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

CEOP
#endif /* ALLOW_DARWIN */
