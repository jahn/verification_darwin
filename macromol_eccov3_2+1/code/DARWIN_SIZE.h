#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for darwin model.

      integer nplank, nGroup, nopt
      integer nPhoto
      integer nPPplank
      integer nGRplank
      parameter(nplank=4)
      parameter(nGroup=9)
      parameter(nopt=12)
      parameter(nPhoto=2)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

#ifndef ALLOW_RADTRANS
      integer nlam
      parameter(nlam=13)
#endif

CEOP
#endif /* ALLOW_DARWIN */
