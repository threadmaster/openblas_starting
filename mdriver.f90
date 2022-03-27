program adriver 

use array

real (kind=8) :: wall_start, wall_end
real (kind=8) :: trace, ONE, ZERO

integer :: nthreads 
real (kind=8) :: walltime
real (kind=8) :: cputime 
real (kind=8) :: mflops 
external walltime, cputime

character (len=8) :: carg1

call get_command_argument(1, carg1)

! Use Fortran internal files to convert command line arguments to ints

read (carg1,'(i8)') nthreads 

N = 10000 

ONE = 1.0D0
ZERO = 0.0D0

allocate ( veca(N), stat=ierr)
allocate ( vecb(N), stat=ierr)
allocate ( matrixa(N,N), stat=ierr)
allocate ( matrixb(N,N), stat=ierr)
allocate ( matrixc(N,N), stat=ierr)

do i = 1, N 
     veca(i) = 1.0
     vecb(i) = 1.0 / sqrt( dble(N))
enddo

mattrixa = 0.0D0
mattrixc = 0.0D0
mattrixd = 0.0D0

call tprod(veca, N, vecb, N, matrixa, N);
call tprod(veca, N, vecb, N, matrixb, N);

call set_omp_num_threads(nthreads)

wall_start = walltime()
cpu_start = cputime()

call dgemm('N','N',N,N,N,ONE,matrixa,N,matrixb,N,ZERO,matrixc,N)

cpu_end = cputime()
wall_end = walltime()

trace = 0.0;

do i=1, N 
     trace = trace + matrixc(i,i)
enddo

!print *,  "The trace is ", trace

mflops = 2.0D0 * dble(N)**3 / (wall_end-wall_start)/ 1.0D6
 
print *, nthreads, N, trace,  wall_end-wall_start,  mflops

if (allocated(matrixa) ) deallocate(matrixa)
if (allocated(matrixb) ) deallocate(matrixb)
if (allocated(matrixc) ) deallocate(matrixc)
if (allocated(veca)    ) deallocate(veca)
if (allocated(vecb)    ) deallocate(vecb)


end program adriver 
 
