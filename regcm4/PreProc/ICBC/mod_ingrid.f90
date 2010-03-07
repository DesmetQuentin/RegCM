      module mod_ingrid

      use mod_param

      implicit none

      integer :: jx_in , iy_in , kz_in
      real :: ptop_in
      real :: clat_in , clon_in , plat_in , plon_in
      real :: delx_in , grdfac_in
      real :: truelath_in , truelatl_in

      character(6) :: cgtype_in

      integer :: igrads_in , ibigend_in

      contains

      subroutine gridml
      use mod_grid
      implicit none
!
! Local variables
!
      integer :: ierr , k
!
!     THIS SUBROUTINE CALLS ROUTINES TO PRODUCE THE MAP FACTORS
!     IT ALSO READS A FILE OF TOPOGRAPHY AND LANDUSE APPROPRIATE FOR
!     GRID FOR EXPLANATION OF VARIABLES SEE SUBROUTINE MAPRON.
!
!     READ APPROPRIATE FILE OF TERRAIN AND LANDUSE FOR THIS GRID
!
      open (10,file='../../Input/DOMAIN.INFO',form='unformatted',       &
          & recl=jx*iy*ibyte,access='direct')
      if ( dattyp=='FVGCM' .or. dattyp=='NRP2W' .or.                    &
         & dattyp=='GFS11' .or. dattyp=='EH5OM' ) then
        read (10,rec=1,iostat=ierr) iy_in , jx_in , kz_in , delx_in ,   &
                                  & clat_in , clon_in , plat_in ,       &
                                  & plon_in , grdfac_in , cgtype_in ,   &
                                  & (sigmaf(k),k=1,kz+1) , ptop_in ,    &
                                  & igrads_in , ibigend_in ,            &
                                  & truelatl_in , truelath_in ,         &
                                  & lon0 , lon1 , lat0 , lat1
      else
        read (10,rec=1,iostat=ierr) iy_in , jx_in , kz_in , delx_in ,   &
                                  & clat_in , clon_in , plat_in ,       &
                                  & plon_in , grdfac_in , cgtype_in ,   &
                                  & (sigmaf(k),k=1,kz+1) , ptop_in ,    &
                                  & igrads_in , ibigend_in ,            &
                                  & truelatl_in , truelath_in
      end if
      if ( iy_in/=iy .or. jx_in/=jx .or. kz_in/=kz ) then
        print * , 'IMPROPER DIMENSION SPECIFICATION (ICBC.f)'
        print * , '  icbc.param: ' , iy , jx , kz
        print * , '  DOMAIN.INFO: ' , iy_in , jx_in , kz_in
        print * , '  Also check ibyte in icbc.param: ibyte= ' , ibyte
        stop 'Dimensions (subroutine gridml)'
      end if
      read (10,rec=2,iostat=ierr) zs
      read (10,rec=3,iostat=ierr) zssd
      read (10,rec=4,iostat=ierr) xlandu
      read (10,rec=5,iostat=ierr) xlat
      read (10,rec=6,iostat=ierr) xlon
      read (10,rec=7,iostat=ierr) dlat
      read (10,rec=8,iostat=ierr) dlon
      read (10,rec=9,iostat=ierr) msfx
      close (10)
      if ( ierr/=0 ) then
        print * , 'END OF FILE REACHED (ICBC.f)'
        print * , '  Check ibyte in icbc.param: ibyte= ' , ibyte
        stop 'EOF (subroutine gridml)'
      end if
!
      end subroutine gridml

      subroutine commhead
      use mod_grid
      implicit none
!
! Local variables
!
      integer :: k
!
      call gridml
!
      do k = 1 , kz
        sigma2(k) = 0.5*(sigmaf(k+1)+sigmaf(k))
        dsigma(k) = sigmaf(k+1) - sigmaf(k)
      end do
      end subroutine commhead

      end module mod_ingrid