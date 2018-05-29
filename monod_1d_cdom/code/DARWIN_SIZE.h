#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for cell model.

      integer nplank, nGroup, nopt
      integer nPhoto
      integer nPPplank
      integer nGRplank
      parameter(nopt=4)
      parameter(nplank=80)
      parameter(nGroup=5)
      parameter(nPhoto=78)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

#ifndef ALLOW_RADTRANS
      integer nlam
      parameter(nlam=1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
