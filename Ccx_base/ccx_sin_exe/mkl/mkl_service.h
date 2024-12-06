/* Minimal mkl_service.h for CCX to compile and work correctly */

#ifndef _MKL_SERVICE_H_
#define _MKL_SERVICE_H_

#define MKL_DOMAIN_PARDISO  4

int     MKL_Domain_Set_Num_Threads(int nth, int MKL_DOMAIN);
#define mkl_domain_set_num_threads  MKL_Domain_Set_Num_Threads

#endif
