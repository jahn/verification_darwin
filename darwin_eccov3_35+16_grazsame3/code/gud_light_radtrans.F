C $Header$
C $Name$

#include "GUD_OPTIONS.h"

CBOP
C !ROUTINE: GUD_LIGHT_RADTRANS
C !INTERFACE: ==========================================================
      SUBROUTINE GUD_LIGHT_RADTRANS(
     O                         PAR,
     I                         solTime,
     I                         bi, bj,
     I                         myTime, myIter, myThid )

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
C#include "DYNVARS.h"
#include "FFIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_FIELDS.h"
#ifdef ALLOW_GUD
#include "GUD_SIZE.h"
#include "GUD_INDICES.h"
#include "GUD_EXF.h"
#include "GUD_PARAMS.h"
#include "GUD_GENPARAMS.h"
#include "GUD_TRAITS.h"
#include "GUD_FIELDS.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myTime :: time at end of (sub)timestep
C  myThid :: thread number
      _RL solTime
      _RL myTime
      INTEGER bi, bj, myIter, myThid

C !OUTPUT PARAMETERS: ==================================================
      _RL PAR(sNx, sNy, Nr, nlam)
CEOP

#ifdef ALLOW_GUD
#ifdef GUD_ALLOW_RADTRANS

C!LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
C  k                    :: vertical level
      CHARACTER*8 diagname
      INTEGER i,j,k,l,jp
      INTEGER iyr,imon,iday,isec,lp,wd,mydate(4)
      _RL solz(sNx,sNy)
      _RL rmud
      _RL part
      _RL aCDOM(Nr,nlam)
      _RL phychl(nPhoto)
      _RL plankcar(nPlank)
#ifdef GUD_ALLOW_CDOM
      _RL CDOM
#else
      _RL actotref, atotref
#endif
      _RL PAR_k(Nr, nlam)
      _RL dz_k(Nr)
      _RL actot, bctot, bbctot
C
      _RL a_k(Nr,nlam)
      _RL bt_k(Nr,nlam)
      _RL bb_k(Nr,nlam)
      _RL Edwsf(nlam),Eswsf(nlam)
      _RL Edbot(Nr,nlam),Esbot(Nr,nlam),Eubot(Nr,nlam)
      _RL Estop(Nr,nlam),Eutop(Nr,nlam)
      _RL amp1_k(Nr,nlam), amp2_k(Nr,nlam)
      _RL x_k(Nr,nlam), y_k(Nr,nlam)
      _RL r1_k(Nr,nlam), r2_k(Nr,nlam)
      _RL kappa1_k(Nr,nlam), kappa2_k(Nr,nlam)

      _RL solzlat(1-OLy:sNy+OLy)

#ifdef ALLOW_DIAGNOSTICS
      _RL Ed(sNx, sNy, Nr, nlam)
      _RL Es(sNx, sNy, Nr, nlam)
      _RL Eu(sNx, sNy, Nr, nlam)
#ifdef GUD_DIAG_RADTRANS_SOLUTION
      _RL Est(sNx, sNy, Nr, nlam)
      _RL Eub(sNx, sNy, Nr, nlam)
      _RL amp1(sNx, sNy, Nr, nlam)
      _RL amp2(sNx, sNy, Nr, nlam)
      _RL x3d(sNx, sNy, Nr, nlam)
      _RL y3d(sNx, sNy, Nr, nlam)
      _RL r1(sNx, sNy, Nr, nlam)
      _RL r2(sNx, sNy, Nr, nlam)
      _RL kap1(sNx, sNy, Nr, nlam)
      _RL kap2(sNx, sNy, Nr, nlam)
#endif
#ifdef GUD_DIAG_IOP
      _RL a3d(sNx, sNy, Nr, nlam)
      _RL bt3d(sNx, sNy, Nr, nlam)
      _RL bb3d(sNx, sNy, Nr, nlam)
      _RL aCDOM3d(sNx, sNy, Nr, nlam)
#endif
#endif

C ======================================================================
C get current date and time of day: iyr/imon/iday+isec
      CALL CAL_GETDATE( myIter, mytime, mydate, mythid )
      CALL CAL_CONVDATE( mydate,iyr,imon,iday,isec,lp,wd,mythid )

      IF (gud_useModelCalendar) THEN
       CALL GUD_INSOL(solTime, solzlat, bj, .TRUE.)
      ENDIF

      DO j=1,sNy
       DO i=1,sNx
        IF (gud_useModelCalendar) THEN
         solz(i,j) = solzlat(j)
        ELSE
C oj: average light effective at noon?
         isec = 12*3600
         CALL SUN_SFCSOLZ(rad2deg, iyr, imon, iday, isec,
     I                    XC(i,j,bi,bj), YC(i,j,bi,bj),
     O                    solz(i,j))
        ENDIF

c compute 1/cos(zenith) for direct light below surface
        CALL SUN_SFCRMUD(rad2deg, solz(i,j),
     O                   rmud)

C ======================================================================
        DO k=1,Nr

         dz_k(k) = drF(k)*HFacC(i,j,k,bi,bj)
         part = MAX(Ptracer(i,j,k,bi,bj,iPOP), 0. _d 0)
         DO jp=1,nPhoto
#ifdef GUD_ALLOW_CHLQUOTA
          phychl(jp)=MAX(Ptracer(i,j,k,bi,bj,iChl+jp-1),0.)
#else
          phychl(jp)=MAX(chlPrev(i,j,k,bi,bj,jp), 0.)
#endif
         ENDDO
         DO jp=1,nPlank
          plankcar(jp)=MAX(Ptracer(i,j,k,bi,bj,ic+jp-1),0.)
         ENDDO

#ifdef GUD_ALLOW_CDOM
c use cdom-like tracer
         CDOM = MAX(Ptracer(i,j,k,bi,bj,iCDOM), 0.0 _d 0)
         DO l = 1,nlam
          aCDOM(k,l) = CDOMcoeff*CDOM*exCDOM(l)
         ENDDO
#else
         actotref = 0.0 _d 0
         atotref = 0.0 _d 0
         DO jp = 1,nPhoto
c         nb. n,k swapped from WG
          actotref = actotref +
     &          phychl(jp)*aphy_chl(iMinPhoto+jp-1,laCDOM)
         ENDDO
         atotref = aw(laCDOM) + actotref
         DO l = 1,nlam
          aCDOM(k,l) = gud_aCDOM_fac*atotref*exCDOM(l)
         ENDDO
#endif

         DO l = 1,nlam
c         absorption by phyto
          actot = 0.0
          bctot = 0.0
          bbctot = 0.0
          DO jp = 1, nPhoto
           actot  = actot  + phychl(jp)*aphy_chl(iMinPhoto+jp-1,l)
c          bctot  = bctot  + phychl(jp)*bphy_chl(iMinPhoto+jp-1,l)
c          bbctot = bbctot + phychl(jp)*bbphy_chl(iMinPhoto+jp-1,l)
c convert to using bphy_chl/bbphy_chl in carbon units m2/mgC not chl
            bctot = bctot  +
     &              plankcar(jp)*bphy_chl(iMinPhoto+jp-1,l)*12. _d 0
            bbctot = bbctot +
     &              plankcar(jp)*bbphy_chl(iMinPhoto+jp-1,l)*12. _d 0
          ENDDO
          DO jp = nPhoto+1, nPlank
c convert to using bphy_chl/bbphy_chl in carbon units m2/mgC not chl
            bctot = bctot  +
     &              plankcar(jp)*bphy_chl(iMinPhoto+jp-1,l)*12. _d 0
            bbctot = bbctot +
     &              plankcar(jp)*bbphy_chl(iMinPhoto+jp-1,l)*12. _d 0
          ENDDO
c         add water and CDOM
          a_k(k,l)  = aw(l) + aCDOM(k,l) + actot  + part*apart_P(l)
          bt_k(k,l) = bw(l)              + bctot  + part*bpart_P(l)
          bb_k(k,l) = gud_bbw*bw(l)      + bbctot + part*bbpart_P(l)
          bb_k(k,l) = MAX(gud_bbmin, bb_k(k,l))
         ENDDO

C       k
        ENDDO
C ======================================================================

        Edwsf(:) = OASIM_Ed(i,j,bi,bj,:)
        Eswsf(:) = OASIM_Es(i,j,bi,bj,:)

        CALL GUD_RADTRANS_DIRECT(
     I                dz_k,rmud,Edwsf,Eswsf,a_k,bt_k,bb_k,
     I                gud_radtrans_kmax,
     O                Edbot,Esbot,Eubot,Estop,Eutop,
     O                PAR_k,
     O                amp1_k,amp2_k, x_k, y_k,
     O                r1_k,r2_k,kappa1_k,kappa2_k,
     I                myThid)

        DO l = 1,nlam
         DO k = 1,Nr
          PAR(i,j,k,l) = PAR_k(k,l)
         ENDDO
        ENDDO

#ifdef ALLOW_DIAGNOSTICS
        DO l = 1,nlam
         Ed(i,j,1,l) = Edwsf(l)
         Es(i,j,1,l) = Eswsf(l)
#ifdef GUD_DIAG_RADTRANS_SOLUTION
         Eub(i,j,1,l) = 0.0 _d 0
#endif
         DO k = 1,Nr-1
          Ed(i,j,k+1,l) = Edbot(k,l)
          Es(i,j,k+1,l) = Esbot(k,l)
#ifdef GUD_DIAG_RADTRANS_SOLUTION
          Eub(i,j,k+1,l) = Eubot(k,l)
#endif
         ENDDO
         DO k = 1,Nr
          Eu(i,j,k,l) = Eutop(k,l)
#ifdef GUD_DIAG_IOP
          a3d(i,j,k,l) = a_k(k,l)
          bt3d(i,j,k,l) = bt_k(k,l)
          bb3d(i,j,k,l) = bb_k(k,l)
          aCDOM3d(i,j,k,l) = aCDOM(k,l)
#endif
#ifdef GUD_DIAG_RADTRANS_SOLUTION
          Est(i,j,k,l) = Estop(k,l)
          amp1(i,j,k,l) = amp1_k(k,l)
          amp2(i,j,k,l) = amp2_k(k,l)
          x3d(i,j,k,l) = x_k(k,l)
          y3d(i,j,k,l) = y_k(k,l)
          r1(i,j,k,l) = r1_k(k,l)
          r2(i,j,k,l) = r2_k(k,l)
          kap1(i,j,k,l) = kappa1_k(k,l)
          kap2(i,j,k,l) = kappa2_k(k,l)
#endif
         ENDDO
        ENDDO
#endif

C      i,j
       ENDDO
      ENDDO
C ======================================================================

#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS .AND. myIter .GE.0) THEN
      DO l = 1, nlam
       WRITE(diagname, '(A,I3.3)') 'Ed', l
       CALL DIAGNOSTICS_FILL(Ed(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'Es', l
       CALL DIAGNOSTICS_FILL(Es(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'Eu', l
       CALL DIAGNOSTICS_FILL(Eu(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
#ifdef GUD_DIAG_RADTRANS_SOLUTION
       WRITE(diagname, '(A,I3.3)') 'Estop', l
       CALL DIAGNOSTICS_FILL(Est(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'Eubot', l
       CALL DIAGNOSTICS_FILL(Eub(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'amp1_', l
       CALL DIAGNOSTICS_FILL(amp1(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'amp2_', l
       CALL DIAGNOSTICS_FILL(amp2(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'x_', l
       CALL DIAGNOSTICS_FILL(x3d(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'y_', l
       CALL DIAGNOSTICS_FILL(y3d(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'r1_', l
       CALL DIAGNOSTICS_FILL(r1(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'r2_', l
       CALL DIAGNOSTICS_FILL(r2(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'att1_', l
       CALL DIAGNOSTICS_FILL(kap1(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'att2_', l
       CALL DIAGNOSTICS_FILL(kap2(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
#endif
#ifdef GUD_DIAG_IOP
       WRITE(diagname, '(A,I3.3)') 'a', l
       CALL DIAGNOSTICS_FILL(a3d(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'bt', l
       CALL DIAGNOSTICS_FILL(bt3d(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'bb', l
       CALL DIAGNOSTICS_FILL(bb3d(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'aCDOM', l
       CALL DIAGNOSTICS_FILL(
     &                    aCDOM3d(1,1,1,l),diagname,0,Nr,3,bi,bj,myThid)
#endif
      ENDDO
      ENDIF
#endif

#endif /* GUD_ALLOW_RADTRANS */
#endif /* ALLOW_GUD */

      RETURN
      END
