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
      parameter(nplank=11)
      parameter(nGroup=5)
      parameter(nPhoto=9)
      parameter(nPPplank=nPhoto)
      parameter(nGRplank=nPhoto)

#ifndef ALLOW_RADTRANS
      integer nlam
      parameter(nlam=1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
