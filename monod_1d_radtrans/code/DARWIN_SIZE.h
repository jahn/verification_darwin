#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for cell model.

      integer nplank, nGroup, nopt, darwin_nlam
      integer nPhoto
      integer nPPplank
      integer nGRplank
      parameter(nopt=4)
      parameter(darwin_nlam=13)
      parameter(nplank=80)
      parameter(nGroup=5)
      parameter(nPhoto=78)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

CEOP
#endif /* ALLOW_DARWIN */
