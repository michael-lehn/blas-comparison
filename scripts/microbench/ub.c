// ub.c - SME microbenchmarks on one P core. Build: clang -O2 -mcpu=apple-m4 ub.c -o bin/ub
#define _DARWIN_C_SOURCE
#include <arm_sme.h>
#include <pthread/qos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
static double now(void){struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return t.tv_sec+1e-9*t.tv_nsec;}
static int cmp(const void*a,const void*b){double x=*(double*)a,y=*(double*)b;return x<y?-1:x>y;}

// E1: FMOPA throughput by tile count, operands in registers (no memory)
#define REGLOOP(NAME,BODY) __arm_new("za") __arm_locally_streaming __attribute__((noinline)) \
 static void NAME(long it){svbool_t p=svptrue_b64();svfloat64_t a=svdup_f64(1e-9),b=svdup_f64(1e-9);svzero_za(); \
 for(long i=0;i<it;i+=8){BODY}}
#define M(t) svmopa_za64_f64_m(t,p,p,a,b);
REGLOOP(r1,M(0)M(0)M(0)M(0)M(0)M(0)M(0)M(0))
REGLOOP(r2,M(0)M(1)M(0)M(1)M(0)M(1)M(0)M(1))
REGLOOP(r3,M(0)M(1)M(2)M(0)M(1)M(2)M(0)M(1))
REGLOOP(r4,M(0)M(1)M(2)M(3)M(0)M(1)M(2)M(3))
REGLOOP(r8,M(0)M(1)M(2)M(3)M(4)M(5)M(6)M(7))

// E2: kernel k-loops (panel sizes as in gemm); no C traffic; report GFLOP/s
// 16x16, single vector loads (PureBLAS): 2A+2B per 4 FMOPA
__arm_new("za") __arm_locally_streaming __attribute__((noinline))
static void k16x16_single(long kc,const double*A,const double*B){svbool_t p=svptrue_b64();svzero_za();
 for(long l=0;l<kc;++l){svfloat64_t a0=svld1(p,A),a1=svld1(p,A+8),b0=svld1(p,B),b1=svld1(p,B+8);
  svmopa_za64_f64_m(0,p,p,a0,b0);svmopa_za64_f64_m(1,p,p,a0,b1);svmopa_za64_f64_m(2,p,p,a1,b0);svmopa_za64_f64_m(3,p,p,a1,b1);A+=16;B+=16;}}
// 16x16, multi vector loads
__arm_new("za") __arm_locally_streaming __attribute__((noinline))
static void k16x16_multi(long kc,const double*A,const double*B){svbool_t p=svptrue_b64();svcount_t c=svptrue_c64();svzero_za();
 for(long l=0;l<kc;++l){svfloat64x2_t a=svld1_f64_x2(c,A),b=svld1_f64_x2(c,B);
  svmopa_za64_f64_m(0,p,p,svget2(a,0),svget2(b,0));svmopa_za64_f64_m(1,p,p,svget2(a,0),svget2(b,1));svmopa_za64_f64_m(2,p,p,svget2(a,1),svget2(b,0));svmopa_za64_f64_m(3,p,p,svget2(a,1),svget2(b,1));A+=16;B+=16;}}
// 32x16, multi vector loads (ulmBLAS): 4A+2B per 8 FMOPA
__arm_new("za") __arm_locally_streaming __attribute__((noinline))
static void k32x16_multi(long kc,const double*A,const double*B){svbool_t p=svptrue_b64();svcount_t c=svptrue_c64();svzero_za();
 for(long l=0;l<kc;++l){svfloat64x4_t a=svld1_f64_x4(c,A);svfloat64x2_t b=svld1_f64_x2(c,B);
  for(int dummy=0;dummy<1;++dummy){
  svmopa_za64_f64_m(0,p,p,svget2(b,0),svget4(a,0));svmopa_za64_f64_m(1,p,p,svget2(b,0),svget4(a,1));svmopa_za64_f64_m(2,p,p,svget2(b,0),svget4(a,2));svmopa_za64_f64_m(3,p,p,svget2(b,0),svget4(a,3));
  svmopa_za64_f64_m(4,p,p,svget2(b,1),svget4(a,0));svmopa_za64_f64_m(5,p,p,svget2(b,1),svget4(a,1));svmopa_za64_f64_m(6,p,p,svget2(b,1),svget4(a,2));svmopa_za64_f64_m(7,p,p,svget2(b,1),svget4(a,3));}
  A+=32;B+=16;}}
// 32x16 single vector loads
__arm_new("za") __arm_locally_streaming __attribute__((noinline))
static void k32x16_single(long kc,const double*A,const double*B){svbool_t p=svptrue_b64();svzero_za();
 for(long l=0;l<kc;++l){svfloat64_t a0=svld1(p,A),a1=svld1(p,A+8),a2=svld1(p,A+16),a3=svld1(p,A+24),b0=svld1(p,B),b1=svld1(p,B+8);
  svmopa_za64_f64_m(0,p,p,b0,a0);svmopa_za64_f64_m(1,p,p,b0,a1);svmopa_za64_f64_m(2,p,p,b0,a2);svmopa_za64_f64_m(3,p,p,b0,a3);
  svmopa_za64_f64_m(4,p,p,b1,a0);svmopa_za64_f64_m(5,p,p,b1,a1);svmopa_za64_f64_m(6,p,p,b1,a2);svmopa_za64_f64_m(7,p,p,b1,a3);A+=32;B+=16;}}

// E3: session cost. Tile through ZA with session per tile vs one session around all tiles (16x16, kc small)
static inline void tile_body(long kc,const double*A,const double*B,double*C,long ld) __arm_streaming __arm_inout("za") {
 svbool_t p=svptrue_b64();
 for(int j=0;j<8;++j){svld1_ver_za64(0,j,p,C+j*ld);svld1_ver_za64(2,j,p,C+j*ld+8);svld1_ver_za64(1,j,p,C+(j+8)*ld);svld1_ver_za64(3,j,p,C+(j+8)*ld+8);}
 for(long l=0;l<kc;++l){svfloat64_t a0=svld1(p,A),a1=svld1(p,A+8),b0=svld1(p,B),b1=svld1(p,B+8);
  svmopa_za64_f64_m(0,p,p,a0,b0);svmopa_za64_f64_m(1,p,p,a0,b1);svmopa_za64_f64_m(2,p,p,a1,b0);svmopa_za64_f64_m(3,p,p,a1,b1);A+=16;B+=16;}
 for(int j=0;j<8;++j){svst1_ver_za64(0,j,p,C+j*ld);svst1_ver_za64(2,j,p,C+j*ld+8);svst1_ver_za64(1,j,p,C+(j+8)*ld);svst1_ver_za64(3,j,p,C+(j+8)*ld+8);}
}
__arm_new("za") __arm_locally_streaming __attribute__((noinline))
static void per_tile(long kc,const double*A,const double*B,double*C,long ld){tile_body(kc,A,B,C,ld);}
__arm_new("za") __arm_locally_streaming __attribute__((noinline))
static void one_session(long nt,long kc,const double*A,const double*B,double*C,long ld){for(long t=0;t<nt;++t)tile_body(kc,A,B,C,ld);}

// E4: SME vs NEON strided load: N lines spaced S bytes, repeated. ns per load
__arm_locally_streaming __attribute__((noinline))
static double sme_walk(const char*x,long S,long N,long reps){svbool_t p=svptrue_b64();svfloat64_t s=svdup_f64(0);
 for(long r=0;r<reps;++r){const char*q=x;for(long i=0;i<N;++i){s=svadd_x(p,s,svld1(p,(const double*)q));q+=S;}}
 return svaddv(p,s);}
__attribute__((noinline))
static double neon_walk(const char*x,long S,long N,long reps){double s=0;
 for(long r=0;r<reps;++r){const volatile char*q=x;for(long i=0;i<N;++i){s+=*(const volatile double*)q;q+=S;}}
 return s;}

// E5: kernel reading A in place at stride lda vs packed, MR rows per k (no C): shows the aliasing period
__arm_new("za") __arm_locally_streaming __attribute__((noinline))
static void k_lda(long nip,long kc,const double*A,long lda,const double*B){svbool_t p=svptrue_b64();svzero_za();
 for(long i=0;i<nip;++i){const double*a=A+i*16,*b=B;
 for(long l=0;l<kc;++l){svfloat64_t a0=svld1(p,a),a1=svld1(p,a+8),b0=svld1(p,b),b1=svld1(p,b+8);
  svmopa_za64_f64_m(0,p,p,a0,b0);svmopa_za64_f64_m(1,p,p,a0,b1);svmopa_za64_f64_m(2,p,p,a1,b0);svmopa_za64_f64_m(3,p,p,a1,b1);a+=lda;b+=16;}}}

#define MED(res,CODE) do{double t_[9];for(int s_=0;s_<9;++s_){double t0_=now();CODE;t_[s_]=now()-t0_;}qsort(t_,9,8,cmp);res=t_[4];}while(0)
int main(int argc,char**argv){pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE,0);
 double t;
 printf("# E1 FMOPA, register operands (GFLOP/s, Gfmopa/s)\n");
 long it=40000000;
 MED(t,r1(it));printf("tiles=1 %.1f %.2f\n",it*128e-9/t,it*1e-9/t);
 MED(t,r2(it));printf("tiles=2 %.1f %.2f\n",it*128e-9/t,it*1e-9/t);
 MED(t,r3(it));printf("tiles=3 %.1f %.2f\n",it*128e-9/t,it*1e-9/t);
 MED(t,r4(it));printf("tiles=4 %.1f %.2f\n",it*128e-9/t,it*1e-9/t);
 MED(t,r8(it));printf("tiles=8 %.1f %.2f\n",it*128e-9/t,it*1e-9/t);
 double *A,*B;posix_memalign((void**)&A,16384,64<<20);posix_memalign((void**)&B,16384,64<<20);
 for(long i=0;i<(64<<20)/8;++i){A[i]=1e-9;B[i]=1e-9;}
 printf("# E2 k-loop with packed panels: kc, kernel, GFLOP/s (no C traffic, ZA zero+no store)\n");
 long kcs[]={64,256,1024,2048,4096};
 for(int q=0;q<5;++q){long kc=kcs[q];long nr=200000/kc+1;
  MED(t,for(long r=0;r<nr;++r)k16x16_single(kc,A,B));printf("kc=%ld 16x16-single %.1f\n",kc,nr*kc*4*128e-9/t);
  MED(t,for(long r=0;r<nr;++r)k16x16_multi(kc,A,B));printf("kc=%ld 16x16-multi  %.1f\n",kc,nr*kc*4*128e-9/t);
  MED(t,for(long r=0;r<nr;++r)k32x16_single(kc,A,B));printf("kc=%ld 32x16-single %.1f\n",kc,nr*kc*8*128e-9/t);
  MED(t,for(long r=0;r<nr;++r)k32x16_multi(kc,A,B));printf("kc=%ld 32x16-multi  %.1f\n",kc,nr*kc*8*128e-9/t);
 }
 printf("# E3 session per tile vs one session: 16x16, C in memory, ns per tile\n");
 long kcs3[]={8,32,128,512,2048};double *C;posix_memalign((void**)&C,16384,1<<22);memset(C,0,1<<22);
 for(int q=0;q<5;++q){long kc=kcs3[q];long nt=2000;
  double a_,b_;MED(a_,for(long i=0;i<nt;++i)per_tile(kc,A,B,C,256));MED(b_,one_session(nt,kc,A,B,C,256));
  printf("kc=%ld per_tile %.1f one_session %.1f overhead %.1f ns (%.1f%%)\n",kc,a_/nt*1e9,b_/nt*1e9,(a_-b_)/nt*1e9,100*(a_-b_)/b_);
 }
 printf("# E4 strided load ns/load: stride N SME NEON\n");
 long Ss[]={16384,16384+128,8192,4096,1<<20};long Ns[]={4,8,12,16,32,64,128,256,512,1024,2048};
 char*X;size_t XS=1UL<<33;posix_memalign((void**)&X,1<<21,XS);memset(X,1,XS);
 for(int s=0;s<5;++s)for(int n=0;n<11;++n){long S=Ss[s],N=Ns[n];if(S*N+64>(long)XS)continue;long reps=4000000/N+1;double a_,b_;volatile double sink;
   MED(a_,sink=sme_walk(X,S,N,reps));MED(b_,sink=neon_walk(X,S,N,reps));(void)sink;
   printf("S=%ld N=%ld %.3f %.3f\n",S,N,a_/(reps*N)*1e9,b_/(reps*N)*1e9);}
 printf("# E5 in-place walk: lda (doubles), nip=4,kc=256 (A 64x256 re-read), GFLOP/s\n");
 long ldas[]={128,256,512,1024,1025,1040,2048,2049,2056,2064,4096,4097,8192};
 for(int q=0;q<13;++q){long lda=ldas[q],kc=256,nip=4,nr=400;
  MED(t,for(long r=0;r<nr;++r)k_lda(nip,kc,(double*)X,lda,B));printf("lda=%ld %.1f\n",lda,nr*nip*kc*4*128e-9/t);}
 return 0;}
