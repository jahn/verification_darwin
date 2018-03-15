C $Header$
C $Name$

#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for darwin model.
C
C right now, some bits of code assume that
C
C   iMinPhoto = 1
C   iMinPrey = 1
C   iMaxPred = nplank
C   nChl = iMaxPhoto

      integer nplank, nGroup, nlam, nopt
      integer iMinPhoto, iMaxPhoto, nPhoto
      integer iMinPrey, iMaxPrey
      integer iMinPred, iMaxPred
      integer nChl
      integer nPPplank
      integer nGRplank
      parameter(nplank=51)
      parameter(nGroup=9)
      parameter(nlam=13)
      parameter(nopt=12)
      parameter(iMinPhoto=1, iMaxPhoto=35)
      parameter(iMinPrey=1, iMaxPrey=nplank)
      parameter(iMinPred=26, iMaxPred=nplank)
      parameter(nPhoto=iMaxPhoto+1-iMinPhoto)
      parameter(nChl=iMaxPhoto)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

CEOP
#endif /* ALLOW_DARWIN */
