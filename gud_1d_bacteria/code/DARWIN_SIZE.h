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
      parameter(nopt=1)
      parameter(nplank=17)
      parameter(nGroup=12)
      parameter(nPhoto=6)
      parameter(nPPplank=12)
      parameter(nGRplank=0)

#ifndef ALLOW_RADTRANS
      integer nlam
      parameter(nlam=1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
