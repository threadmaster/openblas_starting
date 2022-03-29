# Makefile to build OpenBLAS Tester  
#
# Andrew J. Pounds, Ph.D.
# Departments of Chemistry and Computer Science
# Mercer University
# Spring 2018 
#

F95 = gfortran   
CC = gcc 
FFLAGS =  -O3  
CFLAGS = -O3 -Wall  
LIBS = -L/usr/lib64  -lopenblaso -lgomp 

OBJS = array.o walltime.o cputime.o tprod.o 

all: mdriver ldriver bldriver 

mdriver : mdriver.o $(OBJS)    
	$(F95) -o mdriver mdriver.o $(OBJS) $(LIBS)  

mdriver.o : mdriver.f90 array.o   
	$(F95) $(FFLAGS) -c mdriver.f90  

ldriver : ldriver.o $(OBJS)    
	$(F95) -o ldriver ldriver.o $(OBJS) $(LIBS)  

ldriver.o : ldriver.f90 array.o   
	$(F95) $(FFLAGS) -cpp -c ldriver.f90  

bldriver : bldriver.o $(OBJS)    
	$(F95) -o bldriver bldriver.o $(OBJS) $(LIBS)  

bldriver.o : bldriver.f90 array.o   
	$(F95) $(FFLAGS) -cpp -c bldriver.f90  

walltime.o : walltime.c
	$(CC) $(CFLAGS) -c walltime.c

cputime.o : cputime.c
	$(CC) $(CFLAGS) -c cputime.c

array.o : array.f90
	$(F95) -c array.f90

tprod.o : tprod.c
	$(CC) $(CFLAGS)-c tprod.c

# Default Targets for Cleaning up the Environment
clean :
	rm *.o
	rm *.vect

pristine :
	rm *.o
	touch *.cc *.c *.f *.f90 
	rm *.mod
	rm ldriver mdriver bldriver

ctags :
	ctags *.f90 *.c

