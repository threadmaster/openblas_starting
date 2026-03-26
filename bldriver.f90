program bldriver 

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

    character (len=8) :: carg

    call get_command_argument(1, carg)

! Use Fortran internal files to convert command line arguments to ints

    read (carg,'(i8)') nthreads 

    NDIM = 10000 

#ifdef DEBUG
    print *, "Performing Large Direct Solver Accuracy Test"
#endif

    !This portion of code is ONLY used for verifying the accuracy of the code using
    !the matrix, vector b, and solution vector x stored on the class website.

    !Download the files from theochem using curl at runtime (don't store these on anvil!)
    
    NDIM = 10000
#ifdef DEBUG
    print *, "Copying Files from Theochem"
#endif
    call system("curl -s -o binary_linsolve_a.dat --url http://theochem.mercer.edu/csc435/data/binary_linsolve_a.dat")
    call system("curl -s -o binary_linsolve_b.dat --url http://theochem.mercer.edu/csc435/data/binary_linsolve_b.dat")
    call system("curl -s -o binary_linsolve_x.dat --url http://theochem.mercer.edu/csc435/data/binary_linsolve_x.dat")

#ifdef DEBUG
    print *, "Loading files from theochem.mercer.edu into memory"
#endif

    allocate ( matrixa(NDIM,NDIM), stat=ierr)
    allocate ( veca(NDIM), stat=ierr)
    allocate ( vecb(NDIM), stat=ierr)
    allocate ( vecx(NDIM), stat=ierr)
    allocate ( ipiv(NDIM), stat=ierr ) 

    open(unit=5,file="binary_linsolve_a.dat", access="direct",&
                recl=NDIM*NDIM*8, form="unformatted" )
    read(5,rec=1) matrixa
    close(5)
    open(unit=5,file="binary_linsolve_b.dat", access="direct",&
                recl=NDIM*8, form="unformatted" )
    read(5,rec=1) vecb 
    close(5)
    open(unit=5,file="binary_linsolve_x.dat", access="direct",&
                recl=NDIM*8, form="unformatted" )
    read(5,rec=1) veca 
    close(5)

#ifdef DEBUG
    print *, "Files read into program"
#endif

    ! Delete the files from disk
    call system("rm binary_linsolve_a.dat binary_linsolve_b.dat binary_linsolve_x.dat")

#ifdef DEBUG
    print *, "Files deleted from disk."
#endif


    ! Done with accuracy checking initializations

    ! Since we are using the OpenMP version of the OpenBLAS, we should be 
    ! able to set the number of processors for the parallel work here.

    call omp_set_num_threads(nthreads)

    wall_start = walltime()
    cpu_start = cputime()

    call dgetrf(NDIM,NDIM,matrixa,NDIM,ipiv,info)
    call dgetrs('T',NDIM,1,matrixa,NDIM,ipiv,vecb,NDIM,info)
    vecx = vecb

    cpu_end = cputime()
    wall_end = walltime()

    residual = 0.0
    do i=1, NDIM 
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

    print *, nthreads, NDIM, residual,  wall_end-wall_start, mflops2

    ! Free the memory that was allocated based on which version of the program was
    ! run.

    if (allocated(matrixa)) deallocate(matrixa)
    if (allocated(matrixb)) deallocate(matrixb)
    if (allocated(matrixc)) deallocate(matrixc)
    if (allocated(veca)) deallocate(veca)
    if (allocated(vecb)) deallocate(vecb)
    if (allocated(vecx)) deallocate(vecx)
    if (allocated(ipiv)) deallocate(ipiv)

end program bldriver 



