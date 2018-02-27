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
      parameter(darwin_nlam=1)
      parameter(nopt=1)
      parameter(nplank=11)
      parameter(nGroup=5)
      parameter(nPhoto=9)
      parameter(nPPplank=nPhoto)
      parameter(nGRplank=nPhoto)

CEOP
#endif /* ALLOW_DARWIN */
