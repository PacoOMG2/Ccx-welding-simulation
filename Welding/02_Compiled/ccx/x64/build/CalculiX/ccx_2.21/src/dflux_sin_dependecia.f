!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2023 Guido Dhondt
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation(version 2);
!     
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!
!     You should have received a copy of the GNU General Public License
!     along with this program; if not, write to the Free Software
!     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
!
      subroutine dflux(flux,sol,kstep,kinc,time,noel,npt,coords,
     &     jltyp,temp,press,loadtype,area,vold,co,lakonl,konl,
     &     ipompc,nodempc,coefmpc,nmpc,ikmpc,ilmpc,iscale,mi,
     &     sti,xstateini,xstate,nstate_,dtime)
!
!     user subroutine dflux
!
!
!     INPUT:
!
!     sol                current temperature value
!     kstep              step number
!     kinc               increment number
!     time(1)            current step time
!     time(2)            current total time
!     noel               element number
!     npt                integration point number
!     coords(1..3)       global coordinates of the integration point
!     jltyp              loading face kode:
!                        1  = body flux
!                        11 = face 1 
!                        12 = face 2 
!                        13 = face 3 
!                        14 = face 4 
!                        15 = face 5 
!                        16 = face 6
!     temp               currently not used
!     press              currently not used
!     loadtype           load type label
!     area               for surface flux: area covered by the
!                            integration point
!                        for body flux: volume covered by the
!                            integration point
!     vold(0..4,1..nk)   solution field in all nodes
!                        0: temperature
!                        1: displacement in global x-direction
!                        2: displacement in global y-direction
!                        3: displacement in global z-direction
!                        4: static pressure
!     co(3,1..nk)        coordinates of all nodes
!                        1: coordinate in global x-direction
!                        2: coordinate in global y-direction
!                        3: coordinate in global z-direction
!     lakonl             element label
!     konl(1..20)        nodes belonging to the element
!     ipompc(1..nmpc))   ipompc(i) points to the first term of
!                        MPC i in field nodempc
!     nodempc(1,*)       node number of a MPC term
!     nodempc(2,*)       coordinate direction of a MPC term
!     nodempc(3,*)       if not 0: points towards the next term
!                                  of the MPC in field nodempc
!                        if 0: MPC definition is finished
!     coefmpc(*)         coefficient of a MPC term
!     nmpc               number of MPC's
!     ikmpc(1..nmpc)     ordered global degrees of freedom of the MPC's
!                        the global degree of freedom is
!                        8*(node-1)+direction of the dependent term of
!                        the MPC (direction = 0: temperature;
!                        1-3: displacements; 4: static pressure;
!                        5-7: rotations)
!     ilmpc(1..nmpc)     ilmpc(i) is the MPC number corresponding
!                        to the reference number in ikmpc(i)   
!     mi(1)              max # of integration points per element (max
!                        over all elements)
!     mi(2)              max degree of freedomm per node (max over all
!                        nodes) in fields like v(0:mi(2))...
!     sti(i,j,k)         actual Cauchy stress component i at integration
!                        point j in element k. The components are
!                        in the order xx,yy,zz,xy,xz,yz
!     xstateini(i,j,k)   value of the state variable i at integration
!                        point j in element k at the beginning of the
!                        present increment
!     xstate(i,j,k)   value of the state variable i at integration
!                        point j in element k at the end of the
!                        present increment
!     nstate_            number of state variables
!     dtime              time length of the increment
!
!
!     OUTPUT:
!
!     flux(1)            magnitude of the flux
!     flux(2)            not used; please do NOT assign any value
!     iscale             determines whether the flux has to be
!                        scaled for increments smaller than the 
!                        step time in static calculations
!                        0: no scaling
!                        1: scaling (default)
!           
      implicit none
!
      character*8 lakonl
      character*20 loadtype
!
      integer kstep,kinc,noel,npt,jltyp,konl(20),ipompc(*),nstate_,i,
     &  nodempc(3,*),nmpc,ikmpc(*),ilmpc(*),node,idof,id,iscale,mi(*)
!
      real*8 flux(2),time(2),coords(3),sol,temp,press,vold(0:mi(2),*),
     &  area,co(3,*),coefmpc(*),sti(6,mi(1),*),xstate(nstate_,mi(1),*),
     &  xstateini(nstate_,mi(1),*),dtime
!
!
!
!     Start of your own code.
!
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
! This version of DFLUX was made by Ossama Dreibati
!Ingenieurbeüro Dreibati
!Further Information at 
!https://www.researchgate.net/publication/309385851_Low_cost
!_welding_simulation_with_open_source_codes_Crash_course-_CalculiX
!
!     This Subroutine is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
!/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
      integer M1
      real*8 Q0,RE,RI,ZE,ZI,X0,Y0,Z0,VY,AY,PIDEG,XD,YD,
     &  ZD,SA,CA,A1,A2,A3,AF,XL,YL,ZL,DE,DI,R0,R02,XX,YY,ZZ,TT,R2,
     &   XL0,YL0,ZL0,cox,coy,coz,X_,Y_,Z_,dist
!
      character*50 textt,textt1 
      character*2 textt2
      character*1 ctext
      real*8 effi,power,speed, overall_dist,weld_loc,weld_dist,
     & dist_x, dist_y, dist_z,weld_time, alpha, beta,gama,
     & sub_dist,start_time,y_degree,z_degree,part_dist(1000),d,
     & angle(3)
      integer j,jj,ii,n,k, io_r,method, t_node,r_node,iso_10,
     & ierror, node_temp
      integer node_trj(1000), node_ref(1000)
C
      real*8 COND,QC,QR,QF,AC, AR,V1,V2,V3,B,C,FL_MZ,RL_MZ,
     &  H_BW,P_B,T_R, L_R,P_D
C
C
!  INITIALIZATION
      io_r = 0
      i = 1
      j = 1
      jj = 1
      textt = ''
      t_node = 2
      r_node = 2 
      sub_dist = 0.0
      overall_dist = 0.0
      start_time = 0.025
      weld_time = time(2) - start_time
      if(weld_time .lt. 0.0) return
C==========WELD PARAMETER WHICH MUST BE INPUT BY THE USER
      speed = 60 !WELDING SPEED bajar a 30 y luego 70
      method = 1 ! 1 LASER (Goldak) 2 ARC (DOUBLE ELLIPSOIDAL)
      power = 3500.0!  LASER POWER or I x U
      effi = 0.225 ! EFFECIENCY
C----PARAMETER FOR ARC WELDING --> DOUBLE ELLIPSOIDAL
      FL_MZ = 1.2	! Front length of the molten zone
      RL_MZ = 1.7	! Rear length of the molten zone
C
C Width and depth
C
      H_BW = 1.900    ! Half of the width of the bead
      P_B  = 2.700    ! Penetration of the bead
C-----PARAMETER FOR LASER WELDING --> Goldak HEAT SOURCE WITH LINEAR DECREASE OF 
C HEAT INPUT WITH PENETRATION DEPTH
       T_R = 0.857 ! Top RADIO
       L_R = 0.738 ! LOWER RADIUS
       P_D = -2.25 ! PENETRATION DEPTH. NOTE THAT UPPER LIMITE OF THE HEAT SOURCE IS ZERO
C==========TRAJECTORY NODES // NUMBER of NODES = t_node
C       node_trj(number) = node number of the centre of the weld trajectory in successive order
C       node_trj(first node)=number of first node of the trajectory = welding start point
C       node_trj(second node)=number of second node of the trajectory
C       ....
C       node_trj(nth node)=number of nth node of the trajectory
C       node_trj(last node)=number of last node of the trajectory = welding end point
C      hereafter the trajectory is a line and therefor only the start and end point are necessary
        node_trj(1)=2
        node_trj(2)=222
C==========END TRAJECTORY
C==========REFERENCE NODES// NUMBER of NODES = r_node
C same as for the trajectory
        node_ref(1)=493
        node_ref(2)=2968
C==========END REFERENCE
C=========CONDITIONS FOR TRAJECTORY 
       if(t_node .ne. r_node) then
        write(*,*) ' the number of nodes in the trajectory and
     &reference groups must be the same'
        call exit(201)
        endif
C==========END CONDITIONS
C==========WELDED DISTANCE
C========== LENGTH OF WELD TRAJECTORY
            sub_dist = 0.0 ! Inicializa la distancia acumulada
      do ii= 1, t_node - 1
        dist_x = co(1,node_trj(ii+1)) - co(1,node_trj(ii))
        dist_x = dist_x * dist_x
        dist_y = co(2,node_trj(ii+1)) - co(2,node_trj(ii))
        dist_y = dist_y * dist_y
        dist_z = co(3,node_trj(ii+1)) - co(3,node_trj(ii))
        dist_z = dist_z * dist_z
C
        dist = sqrt(dist_x + dist_y + dist_z)
        part_dist(ii) = dist
        overall_dist = overall_dist + dist
      end do
      if((kstep .eq. 1) .and. (kinc .eq. 1)) then
         write(*,*) 'Length of weld trajectory:',overall_dist
      end if
C==========DECIDING WETHER THE WELD IS COMPLETLY PERFORMED
      if(sub_dist .ge. overall_dist) return  ! Cambiado						
C========== LOCAL COORDINATE SYSTEM (X0,Y0,Z0)
       X0 = co(1,node_trj(1))
       Y0 = co(2,node_trj(1))
       Z0 = co(3,node_trj(1))
      do ii= 1, t_node - 1
C---- Calculate the distace between two adjecent nodes
C
       sub_dist = sub_dist + part_dist(ii)
C
       if(sub_dist .lt. overall_dist) then  ! Cambiado
         X0 = co(1,node_trj(ii+1))
         Y0 = co(2,node_trj(ii+1))
         Z0 = co(3,node_trj(ii+1))
C         write(*,*) 'ii', ii
       else
C-------gama rotation about z axis
         if(co(2,node_trj(ii+1)) .eq. co(2,node_trj(ii))) then
           gama = 1.570796327
         else if(co(1,node_trj(ii+1)) .eq. co(1,node_trj(ii))) then
           gama = 0.d0
         else
           gama = atan((co(2,node_trj(ii+1))-co(2,node_trj(ii)))/
     &      (co(1,node_trj(ii+1)) - co(1,node_trj(ii))))
           gama= 1.570796327-gama
         endif
C-------beta rotation about y axis
         if(co(3,node_trj(ii+1)) .eq. co(3,node_trj(ii))) then
           beta = 1.570796327
         else if(co(1,node_trj(ii+1)) .eq. co(1,node_trj(ii))) then
           beta = 0.d0
         else
           beta = atan((co(3,node_trj(ii+1)) - co(3,node_trj(ii)))/
     &      (co(1,node_trj(ii+1)) - co(1,node_trj(ii))))
           beta= 1.570796327-beta
         endif
C-------alpha rotation about x axis
         if(co(2,node_trj(ii+1)) .eq. co(2,node_trj(ii))) then
           alpha = 1.570796327
         else if(co(3,node_trj(ii+1)) .eq. co(3,node_trj(ii))) then
           alpha = 0.d0
         else
           alpha = atan((co(3,node_trj(ii+1)) - co(3,node_trj(ii)))/
     &      (co(2,node_trj(ii+1)) - co(2,node_trj(ii))))
           alpha= 1.570796327-alpha
         endif
!      end do
      if(abs(gama) .lt. 0.001) gama = 0.0
      if(abs(beta) .lt. 0.001) beta = 0.0
      if(abs(alpha) .lt. 0.001) alpha = 0.0
!      gama = -gama
!      beta = -beta
!      alpha = -alpha
!............TRANSLATION
       cox=co(1,node_trj(ii+1))-(co(1,node_trj(ii)))
       coy=co(2,node_trj(ii+1))-(co(2,node_trj(ii)))
       coz=co(3,node_trj(ii+1))-(co(3,node_trj(ii)))
!............ROTATION ABOUT Z
       cox=(cox*cos(gama))+(coy*sin(gama))
       coy=(-1*cox*sin(gama))+(coy*cos(gama))
       if(coy.lt. 0d0) gama=3.1415d0 + gama
!............ROTATION ABOUT Y
!       cox = (cox*cos(beta))+(coz*sin(beta))
!       coz = (-1 *cox*sin(beta))+(xoz*cos(beta))
!       if(coz.lt. 0d0) beta=-beta
!...........ROTATION ABOUT X
       coy=(coy*cos(alpha))+(coz*sin(alpha))
       coz= (-1 *coy*sin(alpha))+(coz*cos(alpha))
       if(coy.ne.(co(2,node_trj(ii+1))-(co(2,node_trj(ii)))))
     &   alpha=-alpha
!
      gama = -gama
      beta = -beta
      alpha = -alpha
       exit
       endif
      end do
C=========END LOCAL COORDINATE SYSTEM (X0,Y0,Z0)
C
C=========TRANSFORMATION FROM GLOBAL TO LOCAL COORDINATE SYSTEM
C
       XX = coords(1)   
       YY = coords(2)   
       ZZ = coords(3)   
C
       X_ = XX - X0
       Y_ = YY - Y0
       Z_ = ZZ - Z0
!............ROTATION ABOUT Z
       XX = (X_ * cos(gama)) + (Y_ * sin(gama))
       YY = (-1 * X_ * sin(gama)) + (Y_ * cos(gama))
       ZZ = Z_
!............ROTATION ABOUT Y
!       XX = (XX * cos(beta)) + (ZZ * sin(beta))
!       ZZ = (-1 * XX * sin(beta)) + (ZZ * cos(beta))
!...........ROTATION ABOUT X
!       YY = (YY * cos(alpha)) + (ZZ * sin(alpha))
!       ZZ = (-1 * YY * sin(alpha)) + (ZZ * cos(alpha))
C=========END TRANSFORMATION FROM GLOBAL TO LOCAL COORDINATE SYSTEM
C
C  122 continue
C
C==========WELD LOCATION
       d = 0.0
       do ii = 1, t_node - 1
          d = d + part_dist(ii)
          if(weld_dist .lt. d) then
             if(ii .eq. 1) then
               d = 0.0
               exit
             endif
             d = d - part_dist(ii)
             exit
          endif
       end do
       TT = weld_time - (d / speed)
C==========WELDING ANGLE
       do ii = 1, t_node - 1
          if(X0.eq.co(1,node_trj(ii))) then
           if(Y0.eq.co(2,node_trj(ii))) then
            if(Z0 .eq. co(3,node_trj(ii))) then
             if(co(1,node_trj(ii)).eq.co(1,node_ref(ii))) then
               angle(1) = 1.570796327
             else
               angle(1) = co(3,node_trj(ii))-co(3,node_ref(ii))
               angle(1) = angle(1)/
     &         (co(1,node_trj(ii))-co(1,node_ref(ii)))
               angle(1) = atan(angle(1))
             end if
             if(co(1,node_trj(ii+1)).eq.co(1,node_ref(ii+1))) then
               angle(1) = 1.570796327
             else
               angle(2) = co(3,node_trj(ii+1))-co(3,node_ref(ii+1))
               angle(2) = angle(2)/
     &         (co(1,node_trj(ii+1))-co(1,node_ref(ii+1)))
               angle(1) = atan(angle(1))
             endif
            endif
           endif
          endif
         angle(3) = part_dist(ii)-d
         angle(3) = angle(3) * (angle(1)-angle(2))
         angle(3) = angle(3) / part_dist(ii)
         angle(3) = angle(3) + angle(2)
       end do
C========== END WELDING ANGLE
C==========END WELD LOCATION
C=========LASER WELDING
       if(method.eq. 1) then  
C 
C
C   FLUX   = Q0 * exp( - R^2 / R0^2 ) with
C   R^2 = ( XX-X0 )^2 + ( YY-Y0-VY*T )^2
C   R0  = RE - ( RE-RI )*( ZE-ZZ+Z0 )/( ZE-ZI )
C   IF R0 < RI , R0 = 0. and return
C   IF R0 > RE , R0 = 0. and return
C Variables
C 
       Q0 = power * effi * 1000.0
       RE = T_R ! Top RADIO
       RI = L_R ! LOWER RADIUS
       ZE = ZL0 - ZL0 ! UPPER LIMIT OF THE SOURCE
       ZI = P_D ! PENETRATION DEPTH
       X0 = 0.0
       Y0 = 0.0
       Z0 = 0.0
       VY = speed
       AY = -angle(3) * 180 / 3.141592654
C
C Constant
C
       M1 = -1
       PIDEG = ATAN(1.)
       PIDEG = PIDEG / 45.0
       AY = AY*PIDEG
C
C Transformation of global to local coordinates
C
       XD = XX - X0
       YD = VY * TT
       YD = YD + Y0
       ZD = ZZ - Z0
C Source rotation about Y axis
C
       SA = SIN(AY)
       SA = - SA
       CA = COS(AY)
       A1 = XD * CA
       A2 = ZD * SA
       XL = A1 + A2
       YL = YY - YD
       A1 = ZD * CA
       A2 = XD * SA
       ZL = A1 - A2
C       write(*,*)'Xl Yl Zl', XL, YL, ZL
C
C Deciding whether the point is out of source's volume
C
       DE = ZL - ZE
       DI = ZL - ZI
       IF( DE .GT. 0.00001 ) RETURN
       A1 = DI + RI
C       write(*,*) 'LASER',A1
       IF( A1 .LT. 0.00001 ) RETURN
C
C       write(*,*) 'LASER'
C R^2 computation
C
       A1 = XL * XL
       A2 = YL * YL
       R2 = A1 + A2
       A3 = DI * DI
       IF( ZL .LE. ZI ) R2 = R2 + A3 + A3
C
C R0^2 computation
C
       A1 = RE - RI
       A2 = ZE - ZI
       A3 = ZE - ZL
       R0 = A3 / A2
       R0 = R0 * A1
       R0 = RE - R0
       IF( ZL .LE. ZI ) R0 = RI
       R02   = R0 * R0
C
C F computation
C
C       write(*,*) 'R',R2,R02
       IF( R2 .GT. R02 ) RETURN      
       A1 = R2 / R02
       A2 = M1 * A1                   
       A2 = EXP( A2 )                 
C
C F computation
C
        FLUX(1) = Q0 * A2
C
      return
      end if
C===========================================END LASER
C===========================================ARC WELDING
C Standard ARC Power source
C Power source dimensions see variables below
C
       if(method.eq. 2) then ! 2 for arc welding
C
C
C Coordinates of the gauss point treated and time
C
C Parameters of the Goldak power source
C
C The absorbed power is defined within an ellipsoid
C
C Definition of the maximum front and rear power intensity
C
         QF = 1.0 * power * effi * 1000.0     ! Normalized maximum front power source intensity
         QR = 0.833 * power * effi * 1000.0   ! Normalized maximum rear power source intensity
C
C Definition of the measures of the Goldak ellipsoid
C They should be inside the molten zone
C
         AF = FL_MZ ! Front length of the molten zone
         AR = RL_MZ ! Rear length of the molten zone
C
C Width and depth
C
         B  = H_BW ! Half of the width of the bead
         C  = P_B  ! Penetration of the bead
C
C                       Position in space - completely handled by
C                       the welding wizzard - weldline
C
         X0 = 0.000    ! X initial location of source center
         Y0 = 0.000    ! Y initial location of source center
         Z0 = 0.000    ! Z initial location of source center
         VY = speed      ! Source displacement velocity
         AY = -angle(3) * 180 / 3.141592654 !0.000 Angle of torch [deg.]
C
C Computation of the absorbed power
C
C F = QC * V1 * V2 * V3 with
C V1 = exp( -( YY-Y0-VY*TT )^2/AC^2 )
C V2 = exp( -( XX-X0 )^2/B^2 )
C V3 = exp( -( ZZ-Z0 )^2/C^2 )
C if ( -YY + Y0 +VY*TT ) greater than 0
C   QC = QF et AC = AF
C else
C   QC = QR et AC = AR
C
C Constant
C
         M1 = -1
         PIDEG = ATAN(1.)
         PIDEG = PIDEG / 45.
         AY = AY * PIDEG 
C
C Transformation of global to local coordinates
C
         XD = XX - X0
         YD = VY * TT
         YD = YD + Y0
         ZD = ZZ - Z0
C
C Source rotation about Y axis
C
         SA = SIN(AY)
         SA = - SA
         CA = COS(AY)
         A1 = XD * CA
         A2 = ZD * SA
         XL = A1 + A2
         YL = YY - YD
         A1 = ZD * CA
         A2 = XD * SA
         ZL = A1 - A2
C
C Condition computation, QC and AC initialisation
C
         COND = VY * YL
         IF (VY .EQ. 0.) COND = YL
         QC = QR
         AC = AR
         IF(COND .GT. 0. ) QC = QF
         IF(COND .GT. 0. ) AC = AF
C
C Vi computation
C
         A1 = YL * YL
         A2 = AC * AC
         A2 = A1 / A2
         A2 = M1 * A2
         V1 = EXP(A2)
C
C V2 computation
C
         A1 = XL * XL
         A2 = B * B
         A2 = A1 / A2
         A2 = M1 * A2
         V2 = EXP(A2)
C
C V3 computation
C
         A1 = ZL * ZL
         A2 = C * C
         A2 = A1 / A2
         A2 = M1 * A2
         V3 = EXP(A2)
C
C F computation
C
         flux(1) = QC * V1 * V2 * V3
C
        RETURN
        endif
        END
C===========================================END ARC
C