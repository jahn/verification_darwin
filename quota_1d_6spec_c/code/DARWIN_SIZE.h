#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for cell model.

      integer nplank, nGroup, nopt
      integer nPhoto
      parameter(nopt=1)
      parameter(nplank=8)
      parameter(nGroup=8)
      parameter(nPhoto=6)

#ifndef ALLOW_RADTRANS
      integer nlam
      parameter(nlam=1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
