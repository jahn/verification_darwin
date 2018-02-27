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
      parameter(darwin_nlam=13)
      parameter(nopt=12)
      parameter(nplank=51)
      parameter(nGroup=9)
      parameter(nPhoto=35)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

CEOP
#endif /* ALLOW_DARWIN */
