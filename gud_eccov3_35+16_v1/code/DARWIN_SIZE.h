#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for cell model.

      integer nplank, nGroup, nopt
      integer nPhoto
      parameter(nopt=12)
      parameter(nplank=51)
      parameter(nGroup=9)
      parameter(nPhoto=35)

#ifndef ALLOW_RADTRANS
      integer nlam
      parameter(nlam=1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
