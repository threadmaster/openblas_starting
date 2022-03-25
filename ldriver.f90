program driver 

integer :: NDIM

real (kind=8) :: wall_start, wall_end
real (kind=8) :: cpu_start, cpu_end
real (kind=8) :: trace


integer :: startval, stopval, stepval, nthreads
real (kind=8) :: walltime
real (kind=8) :: cputime 
external walltime, cputime

real (kind=8), dimension(:), allocatable :: veca, vecb, vecx
real (kind=8), dimension(:,:), allocatable :: matrixa, matrixb, matrixc
real (kind=8) :: residual
integer, dimension(:), allocatable :: ipiv

NDIM = 100 
nthreads = 2

print *, "Performing Direct Solver Accuracy Test"

!This portion of code is ONLY used for verifying the accuracy of the code using
!the matrix, vector b, and solution vector x stored on the class website.

!Download the files from theochem using curl (don't store these on anvil!)
!NOTE: for strictly diagonally dominant systems append _dd to last file name, e.g. -- linsolve_a_dd.dat
#ifdef DIAGDOM
call system("curl -s -o linsolve_a.dat --url http://theochem.mercer.edu/csc435/data/linsolve_a_dd.dat")
call system("curl -s -o linsolve_b.dat --url http://theochem.mercer.edu/csc435/data/linsolve_b_dd.dat")
call system("curl -s -o linsolve_x.dat --url http://theochem.mercer.edu/csc435/data/linsolve_x_dd.dat")
#elif defined( BIGSYS )
NDIM = 10000
print *, "Loading Files from Theochem"
call system("curl -s -o linsolve_a.dat.gz --url http://theochem.mercer.edu/csc435/data/biglinsolve_a.dat.gz")
call system("curl -s -o linsolve_b.dat.gz --url http://theochem.mercer.edu/csc435/data/biglinsolve_b.dat.gz")
call system("curl -s -o linsolve_x.dat.gz --url http://theochem.mercer.edu/csc435/data/biglinsolve_x.dat.gz")
print *, "Uncompressing files"
call system("gunzip linsolve_a.dat.gz")
call system("gunzip linsolve_b.dat.gz")
call system("gunzip linsolve_x.dat.gz")
#else
call system("curl -s -o linsolve_a.dat --url http://theochem.mercer.edu/csc435/data/linsolve_a.dat")
call system("curl -s -o linsolve_b.dat --url http://theochem.mercer.edu/csc435/data/linsolve_b.dat")
call system("curl -s -o linsolve_x.dat --url http://theochem.mercer.edu/csc435/data/linsolve_x.dat")
#endif

print *, "Files loaded from theochem.mercer.edu"

allocate ( matrixa(NDIM,NDIM), stat=ierr)
allocate ( veca(NDIM), stat=ierr)
allocate ( vecb(NDIM), stat=ierr)
allocate ( vecx(NDIM), stat=ierr)

open (unit=5,file="linsolve_a.dat",status="old")
do i = 1, NDIM
  do j = 1, NDIM
     read(5,*) matrixa(j,i)
  enddo
enddo
close(5)
open (unit=5,file="linsolve_b.dat",status="old")
do i = 1, NDIM
   read(5,*) vecb(i)
enddo
close(5)
open (unit=5,file="linsolve_x.dat",status="old")
do i = 1, NDIM
   read(5,*) veca(i)
enddo
close(5)

print *, "Files read into program"

! Delete the files from disk
call system("rm linsolve_a.dat linsolve_b.dat linsolve_x.dat")

print *, "Files deleted from disk."

! Done with accuracy checking initializations



wall_start = walltime()
cpu_start = cputime()

 allocate ( ipiv(NDIM), stat=ierr ) 
 call dgetrf(NDIM,NDIM,matrixa,NDIM,ipiv,info)
 call dgetrs('T',NDIM,1,matrixa,NDIM,ipiv,vecb,NDIM,info)
 vecx = vecb
 if (allocated(ipiv)) deallocate(ipiv)

cpu_end = cputime()
wall_end = walltime()

trace = 0.0;

residual = 0.0
do i=1, NDIM 
   print *, vecx(i), veca(i)
   residual = max(residual, abs(vecx(i)-veca(i)))
enddo

! Calculate megaflops based on CPU time and Walltime

! NOTE -- these need to be replaced with PAPI calls to correctly work
! for iterative linear solve
!
! Matrix multiplication is 2*N**3 flops
! Gaussian Elimination with Partial Pivoting is approximately 2*N**2+(2/3)*N**3
! flops and and LU decomposition is approximately (2/3)*N**3 flops

! For direct linear solver only, add option for iterative linear solver
mflops  = (2.0/3.0)*dble(NDIM)**3/ (cpu_end-cpu_start) / 1.0e6
mflops2 = (2.0/3.0)*dble(NDIM)**3/ (wall_end-wall_start)/ 1.0e6
 
print *, NDIM, residual, cpu_end-cpu_start, wall_end-wall_start,  mflops, mflops2

! Free the memory that was allocated based on which version of the program was
! run.

if (allocated(matrixa)) deallocate(matrixa)
if (allocated(matrixb)) deallocate(matrixb)
if (allocated(matrixc)) deallocate(matrixc)
if (allocated(veca)) deallocate(veca)
if (allocated(vecb)) deallocate(vecb)
if (allocated(vecx)) deallocate(vecx)

end program driver 


 
