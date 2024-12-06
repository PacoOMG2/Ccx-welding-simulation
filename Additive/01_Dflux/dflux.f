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
      real*8 length, width,hight, resu,layer_th, cot(3,5000),
     & cor(3,5000),timeoflayer
      integer layer, right, pass
C
C
!  INITIALIZATION
      io_r = 0
      i = 1
      j = 1
      jj = 1
      textt = ''
      sub_dist = 0.0
      timeoflayer=16.395d0
      overall_dist = 0.0
      start_time = 1.d-2 !0.025 1x10-2
      weld_time = time(2) - start_time !+(3*timeoflayer)
	
	 

C==========WELD PARAMETER WHICH MUST BE INPUT BY THE USER
      speed = 100 !WELDING SPEED
      method = 1 ! 1 LASER (Goldak) 2 ARC (DOUBLE ELLIPSOIDAL)
      power = 1500.0!  LASER POWER or I x U
 !     if(weld_time.lt.0.5) power=power+(power*(0.5-weld_time))
      effi = 0.725 ! EFFECIENCY
C-----PARAMETER FOR LASER WELDING --> Goldak HEAT SOURCE WITH LINEAR DECREASE OF 
C HEAT INPUT WITH PENETRATION DEPTH
       T_R = 0.75 ! Top RADIO
       L_R = 0.65 ! LOWER RADIUS
       P_D = -0.4 ! PENETRATION DEPTH. NOTE THAT UPPER LIMITE OF THE HEAT SOURCE IS ZERO
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
		  pass = width/resu ! 40/0,5
	C
		  do ii= 1, (hight/layer_th)-1
	!        write(*,*) ii,weld_time
			 if(weld_time.gt.(ii*timeoflayer)) then 
			   layer = layer+1
			 else
			   exit !goto 10
			 end if
		  end do
	 !          layer =5
		  weld_time=weld_time-((layer-1)*timeoflayer)
	 !
		  cot(1,1) = 0.
		  cot(2,1) = 0.25
		  cot(3,1) = layer_th*layer
		  node_trj(1) = 1
		  Do ii = 2, t_node,2
			 if(right.gt. 0) then
				cot(1,ii) = length
				cot(2,ii) = cot(2,ii-1)
				cot(3,ii) = layer*layer_th
				cot(1,ii+1) = cot(1,ii)
				cot(2,ii+1) = cot(2,ii)+resu
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
	C==========END TRAJECTORY
C==========REFERENCE NODES// NUMBER of NODES = r_node
C==========END REFERENCE
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
      end do
C      write(*,*) 'overall_dist',overall_dist
      overall_dist = overall_dist*(hight/layer_th)
      if((kstep .eq. 1).and. (kinc .eq. 1))
     &  write(*,*) 'length of weld trajectory:',overall_dist
      if(weld_time .lt. 0.0) return
C==========DECIDING WETHER THE WELD IS COMPLETLY PERFORMED
      if(weld_dist .gt. overall_dist) return
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
       do ii = 1, (width * 2 / resu) - 1
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
C       TT = (weld_time-((layer-1)*timeoflayer))-(d/speed)
       TT = weld_time-(d/speed) !-((layer-1)*timeoflayer)
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
       AY = 0.d0 !-angle(3) * 180 / 3.141592654
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
        IF((XX*XX).gt. 1.) then
          FLUX(1)=0.d0
          return
        end if
C
C      write(*,*) XL,YL,ZL,FLUX(1)
      return
      end if
C===========================================END LASER
        END
C

