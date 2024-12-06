!	
! Heat source for Laser welds 
!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2015 Guido Dhondt
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
      subroutine weld_deposit(ttime,coords,cogauss,co,nope,fa)
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
!
      integer nope
!
      real*8 ttime,coords(3,20),co(3,*),cogauss(3),fa
      integer M1
      real*8 Q0,RE,RI,ZE,ZI,X0,Y0,Z0,VY,AY,PIDEG,XD,YD,
     &  ZD,SA,CA,A1,A2,A3,XL,YL,ZL,DE,DI,R0,R02,XX,YY,ZZ,TT,R2,
     &   XL0,YL0,ZL0,cox,coy,coz,X_,Y_,Z_
!
      character*50 textt,textt1 
      character*2 textt2
      character*1 ctext
      real*8 effi,power,speed, overall_dist,weld_loc,weld_dist,
     & dist_x, dist_y, dist_z,weld_time, alpha, beta,gama,
     & sub_dist,start_time,y_degree,z_degree,part_dist(5000),d,
     & angle(3),dist,T_R, L_R,P_D
      integer i, j,jj,ii,n,k, io_r,method, t_node,r_node,iso_10,
     & ierror, node_temp,start_node,lo,cinteg
      integer node_trj(5000), node_ref(5000)
      real*8 length, width,hight, resu,layer_th, cot(3,5000),
     & cor(3,5000),timeoflayer
      integer layer, right, pass
C
C
C
!  INITIALIZATION
      io_r = 0
      i = 1
      j = 1
      jj = 0
      textt = ''
      sub_dist = 0.0
      overall_dist = 0.0
      start_time = 1.d-2 !0.025
C timeoflayer 
      timeoflayer= 16.395d0
      weld_time=ttime-start_time !+(8*timeoflayer) !+timeoflayer for layers more the 1
      fa=1.d-6
      layer_th = 0.5
      hight = 5.
      cinteg = 3
C==========WELD PARAMETER WHICH MUST BE INPUT BY THE USER
      speed = 100. !WELDING SPEED
       T_R = 0.25 ! Top RADIO
       L_R = 0.25 ! LOWER RADIUS
       P_D = -0.35 ! PENETRATION DEPTH. NOTE THAT UPPER LIMITE OF THE HEAT SOURCE IS ZERO
C-----PARAMETER FOR LASER WELDING --> Goldak HEAT SOURCE WITH LINEAR DECREASE OF 
C HEAT INPUT WITH PENETRATION DEPTH
C==========TRAJECTORY NODES // NUMBER of NODES = t_node
C       node_trj(number) = node number of the centre of the weld trajectory in successive order
      length = 20.
      width = 40.
      hight = 5.
      resu = 0.5
      layer = 1 ! number of layers = hight * 2
      layer_th = 0.5
      t_node = width * 2 / resu 
      r_node = width * 2 / resu !160
      right = 1
      pass = width/resu ! 42/0,5
C
      do ii= 1, (hight/layer_th)-1
         if(weld_time.gt.(ii*timeoflayer)) then 
          layer = ii+1
  !      write(*,*) ii,layer, weld_time
         else
           exit
         end if
      end do
 !         layer = 9
      weld_time=weld_time-((layer-1)*timeoflayer)
!        write(*,*) layer, weld_time
 !     layer = layer
      cot(1,1) = 0.
      cot(2,1) = 0.25
      cot(3,1) = layer_th*layer !
      node_trj(1) = 1
      Do ii = 2, t_node,2
         if(right.gt. 0) then
            cot(1,ii) = length
            cot(2,ii) = cot(2,ii-1)
            cot(3,ii) = layer*layer_th
            cot(1,ii+1) = cot(1,ii)
            cot(2,ii+1) = cot(2,ii)+resu
C            if(ii.eq. pass*layer) then
C              cot(2,ii+1) = cot(2,1)
C              layer = layer +1
C            end if
            cot(3,ii+1) = cot(3,ii)
            right = 0
!        write(*,*) ii, cot(1,ii),cot(2,ii),cot(3,ii)
         else
            cot(1,ii) = 0.d0
            cot(2,ii) = cot(2,ii-1)
            cot(3,ii) = layer*layer_th
            cot(1,ii+1) = cot(1,ii)
            cot(2,ii+1) = cot(2,ii)+resu
            cot(3,ii+1) =   cot(3,ii)
            right = 1
!        write(*,*) ii,cot(1,ii),cot(2,ii),cot(3,ii)
         end if
C
      node_trj(ii) = ii
      node_trj(ii+1) = ii + 1
!      ii= ii +2
!      if(ii.gt. pass*layer) layer = layer +1
      end do
C==========WELDED DISTANCE
C
C      weld_dist =speed*(weld_time-((layer-1)*timeoflayer))
      weld_dist =speed*(weld_time) !-((layer-1)*timeoflayer))
C
C========== LENGTH OF WELD TRAJECTORY
      do ii= 1, (width * 2 / resu) - 1 ! width * 2 / resu 
        dist_x = cot(1,node_trj(ii+1)) - cot(1,node_trj(ii))
        dist_x = dist_x * dist_x
        dist_y = cot(2,node_trj(ii+1)) - cot(2,node_trj(ii))
        dist_y = dist_y * dist_y
        dist_z = cot(3,node_trj(ii+1)) - cot(3,node_trj(ii))
        dist_z = dist_z * dist_z
C
        dist = sqrt(dist_x + dist_y + dist_z)
        part_dist(ii) = dist
        overall_dist = overall_dist + dist
!      write(*,*) ii,'overall_dist',overall_dist
      end do
C==========DECIDING WETHER THE WELD IS COMPLETLY PERFORMED
!      if(weld_dist .gt. overall_dist) return
      dist = 0.0
C========== LOCAL COORDINATE SYSTEM (X0,Y0,Z0)
       X0 = cot(1,1)
       Y0 = cot(2,1)
       Z0 = cot(3,1)
      do ii= 1, (width * 2 / resu) - 1
C---- Calculate the distace between two adjecent nodes
C
       sub_dist = sub_dist + part_dist(ii)
C
       if(sub_dist .lt. weld_dist) then
         X0 = cot(1,node_trj(ii+1))
         Y0 = cot(2,node_trj(ii+1))
         Z0 = cot(3,node_trj(ii+1))
C         write(*,*) 'ii', ii
       else
C-------gama rotation about z axis
         if(cot(2,node_trj(ii+1)) .eq. cot(2,node_trj(ii))) then
           gama = 1.570796327
         else if(cot(1,node_trj(ii+1)) .eq. cot(1,node_trj(ii))) then
           gama = 0.d0
         else
           gama = atan((cot(2,node_trj(ii+1))-cot(2,node_trj(ii)))/
     &      (cot(1,node_trj(ii+1)) - cot(1,node_trj(ii))))
           gama= 1.570796327-gama
         endif
C-------beta rotation about y axis
         if(cot(3,node_trj(ii+1)) .eq. cot(3,node_trj(ii))) then
           beta = 1.570796327
         else if(cot(1,node_trj(ii+1)) .eq. cot(1,node_trj(ii))) then
           beta = 0.d0
         else
           beta = atan((cot(3,node_trj(ii+1)) - cot(3,node_trj(ii)))/
     &      (cot(1,node_trj(ii+1)) - cot(1,node_trj(ii))))
           beta= 1.570796327-beta
         endif
C-------alpha rotation about x axis
         if(cot(2,node_trj(ii+1)) .eq. cot(2,node_trj(ii))) then
           alpha = 1.570796327
         else if(cot(3,node_trj(ii+1)) .eq. cot(3,node_trj(ii))) then
           alpha = 0.d0
         else
           alpha = atan((cot(3,node_trj(ii+1)) - cot(3,node_trj(ii)))/
     &      (cot(2,node_trj(ii+1)) - cot(2,node_trj(ii))))
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
       cox=cot(1,node_trj(ii+1))-(cot(1,node_trj(ii)))
       coy=cot(2,node_trj(ii+1))-(cot(2,node_trj(ii)))
       coz=cot(3,node_trj(ii+1))-(cot(3,node_trj(ii)))
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
       if(coy.ne.(cot(2,node_trj(ii+1))-(cot(2,node_trj(ii)))))
     &   alpha=-alpha
!
      gama = -gama
      beta = -beta
      alpha = -alpha
       exit
       endif
      end do
!         write(*,*)'xyz', X0,Y0,Z0
C=========END LOCAL COORDINATE SYSTEM (X0,Y0,Z0)
C
C=========TRANSFORMATION FROM GLOBAL TO LOCAL COORDINATE SYSTEM
C
       jj=0
C
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
C
C
       do n=1,nope ! FOR ELEMENT NODES
       XX = coords(1,n)   
       YY = coords(2,n)   
       ZZ = coords(3,n)  
C       FOR INTEGRATION POINTS
!        XX=cogauss(1)
!        YY=cogauss(2)
!        ZZ=cogauss(3)
!         write(*,*)'xyz1', XX,YY,ZZ
!       X0 = (X0 * cos(gama)) + (Y0 * sin(gama))
!       Y0 = (-1 * X0 * sin(gama)) + (Y0 * cos(gama))
C
       X_ = XX - X0
       Y_ = YY - Y0
       Z_ = ZZ - Z0
!............ROTATION ABOUT Z
       XX = (X_ * cos(gama)) + (Y_ * sin(gama))
       YY = (-1 * X_ * sin(gama)) + (Y_ * cos(gama))
       ZZ = Z_
!      write(*,*)'xyz',XX,YY,ZZ
!............ROTATION ABOUT Y
!       XX = (XX * cos(beta)) + (ZZ * sin(beta))
!       ZZ = (-1 * XX * sin(beta)) + (ZZ * cos(beta))
!...........ROTATION ABOUT X
!       YY = (YY * cos(alpha)) + (ZZ * sin(alpha))
!       ZZ = (-1 * YY * sin(alpha)) + (ZZ * cos(alpha))
C       write(*,*) 'after',XX, YY,ZZ
C       write(*,*) 'y_degreez_degree',y_degree, z_degree
C       write(*,*) 'gama alpha',gama, alpha
C
C=========END TRANSFORMATION FROM GLOBAL TO LOCAL COORDINATE SYSTEM
C
C  122 continue
C
C==========WELD LOCATION
C
       TT = weld_time-(d/speed) !-((layer-1)*timeoflayer)
C==========END WELD LOCATION
C
       YY= YY -(speed*TT)
!       if((YY*YY + XX*XX + ZZ*ZZ).lt. 8.d0) then
       if(ZZ .gt. 0.)  then
          fa=1.d-6
          return
       end if
       if(ZZ.lt. ((layer_th*(layer-1))-Z0)) then
          fa=1.d0
          return
       end if
       if(YY.gt. 0.25) then
          fa=1.d-6
          return
       end if
       if(XX*XX.gt. 1.0d0) then
          fa=1.d-6
          return
       else
           jj=jj+1
       fa= 1.d0
       end if
      end do 
 !     if(jj .ge.cinteg) then
    ! 
 !     else
    ! 
 !    end if
        RETURN
        END

