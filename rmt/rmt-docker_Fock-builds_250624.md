# RMT Docker Fock builds
25/06/24

## Build tests


### 1. from UB-latest base, ePS container


steacie@fock:/software/docker/rmt$ docker build -t fock:5000/rmt:v250624 -f Dockerfile.UB24 .

WORKING AFTER SOME MODS/DEBUGS!!!

Note current build from existing cached source image, so actually UB22:

    cat /etc/issue
    Ubuntu 22.04.2 LTS \n \l



#### 1(b): add python (miniconda?) and install also python wrappers & tools...


steacie@fock:/software/docker/rmt$ docker build -t fock:5000/rmtpython:v250624 -f Dockerfile.UB24.python .


Build OK, note didn't respec env details, but picks up from previous cmake config?

Includes docs build with Sphinx.

    root@1a7f09864bac:/opt# which mpicc
    /usr/bin/mpicc
    root@1a7f09864bac:/opt# which mpicxx
    /usr/bin/mpicxx
    root@1a7f09864bac:/opt# which mpif90
    /usr/bin/mpif90
    root@1a7f09864bac:/opt# mpicc --version
    gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
    Copyright (C) 2021 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    root@1a7f09864bac:/opt# mpicxx --version
    g++ (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
    Copyright (C) 2021 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    root@1a7f09864bac:/opt# mpif90 --version
    GNU Fortran (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
    Copyright (C) 2021 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.




### (2) R-matrix I/II, UKRMOL+

Ah, ALSO NEED THESE for the basics it seems, RMT uses these output files.

For inputs, see e.g. https://gitlab.com/Uk-amor/RMT/rmatrixII/-/blob/master/inputs/annot.inp?ref_type=heads


Current repos:

- R-mat II: https://gitlab.com/Uk-amor/RMT/rmatrixII/-/tree/master?ref_type=heads
    26/06/24: added to base Docker build

- UKrmol: https://gitlab.com/Uk-amor/UKRMol
        BUT repo empty? May need to ask for access?
        v3.2 (Dec 2020) on Zenodo: https://zenodo.org/records/5799134

        ALSO NEED "GBTOlib library (see https://gitlab.com/UK-AMOR/UKRMol/GBTOlib),"

        >>> ACTUALLY, use https://zenodo.org/search?q=GBTOlib&l=list&p=1&s=10&sort=bestmatch - versions from 2021 by Jakub et. al.
        GBTOlib: https://zenodo.org/records/5798035

        >>> NOW SCRIPTING THIS, see http://jake/jupyter/user/paul/doc/tree/fock-docker/rmt/build_ukrmol.sh

- New scripts for automation: https://data.mendeley.com/datasets/cpvc2473pt/1


#### (2b) R-matrix II

- Added to Docker build OK. Lots of warnings at compilation (used gfortran), but otherwise seems OK.

- Test run per (very limited) docs:

>> cd rmatrixII
>> ls
    build   docs   inputs   source
>> mkdir helium
>> cd helium
>> cp ../inputs/helium.inp .
>> ../build/bin/ang.x < helium.inp > ang.out
>> ../build/bin/rad.x < helium.inp > rad.out
>> ../build/bin/ham.x < helium.inp > ham.out

Ran, although did get floating point warning...


#### (2c) Other components and build script testing

Building components in current rmt container, and script dev...

GBTOLib build OK, running tests (takes hours, runs 4 cores only?)

    root@91ecf705c9c5:/opt/GBTOLib-3.0.3/build# make test > tests_260624.out &
    [1] 1985
    root@91ecf705c9c5:/opt/GBTOLib-3.0.3/build# date
    Wed Jun 26 20:36:09 UTC 2024

Still running 02:21, may need to run detatched next time.
Also set TZ


2nd go 27/06/24, running in rebuild base container.


GBTOLib tests:

    96% tests passed, 5 tests failed out of 134

    Total Test time (real) = 41614.37 sec

    The following tests FAILED:
             55 - integrals_C2v_target_CAS1_serial (Failed)
            114 - integrals_C2v_photoionization_PCCHF_A_parallel (Failed)
            121 - integrals_D2h_photoionization_CC_serial (Failed)
            122 - integrals_D2h_photoionization_CC_parallel (Failed)
            126 - integrals_D2h_rmt_data_CC_parallel (Failed)



#### (3) Tidy up and further testing

- `Dockerfile.UB-gfort`, tidy version and more scripted.
    Build:
        docker build -f Dockerfile.UB-gfort -t fock:5000/rmt:v280624 .



----------

https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6.tar.gz



RMT tested Ne4 OK, see https://gitlab.com/Uk-amor/RMT/rmt#run-rmt

Run 1 liner:

    cd /opt/rmt/tests/atomic_tests/small_tests/Ne_4cores && mkdir test && cd test && ln -s ../inputs/* . && mpiexec -n 4 /opt/rmt/build/bin/rmt.x > log.out


NOTE: need python for more tools!



----

UNIT TESTS (in build + python tools version) 26/06/24

    root@1a7f09864bac:/opt# rmt/build/bin/RMT-tester
    # Testing: hamiltonian_input_file::read_H_file2
      Starting atomic::small::Ne_4cores ... (1/5)
      Starting atomic::small::iodine ... (5/5)
      Starting atomic::small::ar+ ... (2/5)
                             1 e
    Ground state symmetry is  S
                              +0

      Starting atomic::small::argon ... (3/5)
           ... atomic::small::Ne_4cores [PASSED]
      Starting atomic::small::helium ... (4/5)
                                    o
    Ground state symmetry is (J=3/2)
                                   +3/2

           ... atomic::small::iodine [PASSED]
                             2 o
    Ground state symmetry is  P
                              +0

           ... atomic::small::ar+ [PASSED]
                             1 e
    Ground state symmetry is  S
                              +0

           ... atomic::small::helium [PASSED]
                             1 e
    Ground state symmetry is  S
                              +0

           ... atomic::small::argon [PASSED]
    # Testing: hamiltonian_input_file::read_H_parameters2
      Starting RMatrixI::example ... (6/6)
      Starting atomic::small::ar+ ... (2/6)
      Starting atomic::small::helium ... (4/6)
      Starting atomic::small::Ne_4cores ... (1/6)
      Starting atomic::small::iodine ... (5/6)
      Starting atomic::small::argon ... (3/6)
           ... atomic::small::ar+ [PASSED]
           ... atomic::small::argon [PASSED]
           ... RMatrixI::example [PASSED]
           ... atomic::small::helium [PASSED]
           ... atomic::small::Ne_4cores [PASSED]
           ... atomic::small::iodine [PASSED]
    # Testing: hamiltonian_input_file::parse_H_file
      Starting atomic::small::Ne_4cores ... (1/6)
      Starting RMatrixI::example ... (6/6)
      Starting atomic::small::ar+ ... (2/6)
      Starting atomic::small::argon ... (3/6)
      Starting atomic::small::helium ... (4/6)
      Starting atomic::small::iodine ... (5/6)
           ... atomic::small::Ne_4cores [PASSED]
           ... RMatrixI::example [PASSED]
           ... atomic::small::ar+ [PASSED]
           ... atomic::small::argon [PASSED]
           ... atomic::small::helium [PASSED]
           ... atomic::small::iodine [PASSED]
    # Testing: utilities
      Starting int-to-char::one-digit ... (2/7)
      Starting int-to-char::zero ... (1/7)
      Starting int-to-char::ten-digits ... (6/7)
      Starting int-to-char::two-digits-negative ... (5/7)
      Starting int-to-char::two-digits ... (4/7)
      Starting int-to-char::one-digit-negative ... (3/7)
           ... int-to-char::zero [PASSED]
           ... int-to-char::one-digit [PASSED]
      Starting int-to-char::ten-digits-negative ... (7/7)
           ... int-to-char::ten-digits-negative [PASSED]
           ... int-to-char::ten-digits [PASSED]
           ... int-to-char::two-digits-negative [PASSED]
           ... int-to-char::one-digit-negative [PASSED]
           ... int-to-char::two-digits [PASSED]
    # Testing: dipole_input_file::parse_D_file
      Starting atomic::small::Ne_4cores ... (1/4)
      Starting atomic::small:argon ... (3/4)
      Starting atomic::small::ar+ ... (2/4)
      Starting atomic::small:helium ... (4/4)
           ... atomic::small:helium [PASSED]
           ... atomic::small::ar+ [PASSED]
           ... atomic::small::Ne_4cores [PASSED]
           ... atomic::small:argon [PASSED]
    # Testing: dipole_input_file::read_D_file2
      Starting atomic::small::Ne_4cores ... (1/4)
      Starting atomic::small::argon ... (3/4)
      Starting atomic::small::ar+ ... (2/4)
      Starting atomic::small::helium ... (4/4)
           ... atomic::small::helium [PASSED]
           ... atomic::small::ar+ [PASSED]
           ... atomic::small::Ne_4cores [PASSED]
           ... atomic::small::argon [PASSED]



FULL (FINAL) BUILD 25/06/24


teacie@fock:/software/docker/rmt$ docker build -t fock:5000/rmt:v250624 -f Dockerfile.UB24 .
Sending build context to Docker daemon  14.85kB
Step 1/25 : ARG IMAGE_VERSION=${IMAGE_VERSION:-latest}
Step 2/25 : FROM ubuntu:$IMAGE_VERSION
 ---> 3b418d7b466a
Step 3/25 : WORKDIR /opt
 ---> Using cache
 ---> 85c214d5e6ab
Step 4/25 : ENV NCPUS=24
 ---> Using cache
 ---> a65f8c2f41a9
Step 5/25 : ARG SOURCEDIR=./source
 ---> Using cache
 ---> 9c1c92c95c52
Step 6/25 : ARG ePS_TAR=${ePS_TAR:-ePolyScatDistVer3885d87.tgz}
 ---> Using cache
 ---> bf4253ec55b0
Step 7/25 : ARG INSTALL_DIR=${INSTALL_DIR:-/opt/ePolyScat.3885d87}
 ---> Using cache
 ---> 52aa9f26b0f3
Step 8/25 : ENV MACH=ubuntu_gfortran
 ---> Using cache
 ---> c1003cb7f153
Step 9/25 : ENV TMPDIR=/tmp
 ---> Using cache
 ---> e4c3a4014c66
Step 10/25 : ENV pe=${INSTALL_DIR}
 ---> Using cache
 ---> 0e8247917e2c
Step 11/25 : ENV epsBinDir=${pe}/bin/${MACH}
 ---> Using cache
 ---> f804daf1aa01
Step 12/25 : ENV DEBIAN_FRONTEND noninteractive
 ---> Using cache
 ---> eb31e3cf7296
Step 13/25 : ARG BLAS=${BLAS:-atlas}
 ---> Using cache
 ---> 62b2fb711699
Step 14/25 : ARG BLAS_DIR=${BLAS_DIR:-/usr/lib/atlas-base}
 ---> Using cache
 ---> 6e4a8cf0539c
Step 15/25 : ARG MPI=${MPI:-openmpi}
 ---> Using cache
 ---> f63191d884b5
Step 16/25 : ARG MPI_DIR=${MPI_DIR:-/usr/lib/openmpi}
 ---> Using cache
 ---> 4e60faa5fe11
Step 17/25 : RUN apt-get update     && apt-get install -y nano make     && apt-get install -y openmpi-bin openmpi-common libopenmpi-dev     && apt-get install -y libblas-dev liblapack-dev     && apt-get install -y libatlas-base-dev libatlas3-base     && apt-get install -y numdiff wget git     && apt-get clean autoclean     && apt-get autoremove -y
 ---> Using cache
 ---> 1184890b9083
Step 18/25 : ENV LD_LIBRARY_PATH=${BLAS_DIR}:$LD_LIBRARY_PATH
 ---> Using cache
 ---> e2f53c2bd420
Step 19/25 : ENV LD_LIBRARY_PATH=${MPI_DIR}:$LD_LIBRARY_PATH
 ---> Using cache
 ---> 2654dd7b23bc
Step 20/25 : RUN mkdir -p /usr/lib64 &&     ln -s ${BLAS_DIR} /usr/lib64/atlas &&     ln -s ${MPI_DIR} /usr/lib64/openmpi &&     ln -s ${MPI_DIR} /opt/openmpi
 ---> Using cache
 ---> dce056dfda86
Step 21/25 : ARG CMAKE_VERSION=3.29.6
 ---> Using cache
 ---> 6f9431ffdb3e
Step 22/25 : RUN wget -q --no-check-certificate https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz     && tar -xzf cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz        --exclude=bin/cmake-gui        --exclude=doc/cmake        --exclude=share/cmake-${CMAKE_VERSION}/Help        --exclude=share/vim        --exclude=share/vim     && cp -fR cmake-${CMAKE_VERSION}-linux-x86_64/* /usr     && rm -rf cmake-${CMAKE_VERSION}-linux-x86_64     && rm cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz
 ---> Using cache
 ---> 5ff231430bf1
Step 23/25 : RUN git clone https://gitlab.com/Uk-amor/RMT/rmt
 ---> Using cache
 ---> 13bdf5d22e08
Step 24/25 : RUN export CC=$(which mpicc) &&     export CXX=$(which mpicxx) &&     export FC=$(which mpif90) &&     cd rmt && mkdir build && cd build &&     cmake ../source && make
 ---> Running in 9b6340eb41e5
-- The Fortran compiler identification is GNU 11.4.0
-- Detecting Fortran compiler ABI info
-- Detecting Fortran compiler ABI info - done
-- Check for working Fortran compiler: /usr/bin/mpif90 - skipped
-- Found OpenMP_Fortran: -fopenmp (found version "4.5")
-- Found OpenMP: TRUE (found version "4.5")
-- The C compiler identification is GNU 11.4.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/mpicc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Looking for Fortran sgemm
-- Looking for Fortran sgemm - not found
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD - Success
-- Found Threads: TRUE
-- Looking for Fortran dgemm
-- Looking for Fortran dgemm - found
-- Found BLAS: /usr/lib/x86_64-linux-gnu/libblas.so;/usr/lib/x86_64-linux-gnu/libf77blas.so;/usr/lib/x86_64-linux-gnu/libatlas.so
-- Looking for Fortran cheev
-- Looking for Fortran cheev - not found
-- Looking for Fortran cheev
-- Looking for Fortran cheev - found
-- Found LAPACK: /usr/lib/x86_64-linux-gnu/liblapack.so;/usr/lib/x86_64-linux-gnu/libblas.so;/usr/lib/x86_64-linux-gnu/libf77blas.so;/usr/lib/x86_64-linux-gnu/libatlas.so
-- Could NOT find Doxygen (missing: DOXYGEN_EXECUTABLE)
Doxygen needs to be installed to generate the doxygen documentation
CMake Deprecation Warning at modules/CMakeLists.txt:1 (cmake_minimum_required):
  Compatibility with CMake < 3.5 will be removed from a future version of
  CMake.

  Update the VERSION argument <min> value or use a ...<max> suffix to tell
  CMake that the project does not need compatibility with older versions.


-- Found Git: /usr/bin/git (found version "2.34.1")
-- Last commit author: "Andrew Brown"
-- Last commit hash: "9b56df1"
-- Last commit date: "Fri Jun 21 08:53:34 2024 +0000"
CMake Deprecation Warning at programs/CMakeLists.txt:1 (cmake_minimum_required):
  Compatibility with CMake < 3.5 will be removed from a future version of
  CMake.

  Update the VERSION argument <min> value or use a ...<max> suffix to tell
  CMake that the project does not need compatibility with older versions.


-- Configuring done (2.6s)
-- Generating done (0.0s)
-- Build files have been written to: /opt/rmt/build
[  1%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/precisn.f90.o
[  2%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/global_data.f90.o
[  4%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/angular_momentum.f90.o
/opt/rmt/source/modules/angular_momentum.f90:674:14:

  674 |         Plm = (2*l + 1) / (4 * pi)
      |              1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/angular_momentum.f90:514:21:

  514 |     SUBROUTINE shriek(nfact)
      |                     ^
Warning: 'shriek' defined but not used [-Wunused-function]
[  5%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/rmt_assert.f90.o
[  6%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/initial_conditions.f90.o
/opt/rmt/source/modules/initial_conditions.f90:792:22:

  792 |         CALL assert( (final_t /= -1) , &
      |                      1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/initial_conditions.f90:808:38:

  808 |         field_period_XUV(1:numsols) = 2.0*pi/frequency_XUV(1:numsols)
      |                                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/initial_conditions.f90:809:39:

  809 |         ceo_phase_rad_xuv(1:numsols) = pi*ceo_phase_deg_xuv(1:numsols)/180.0_wp
      |                                       1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/initial_conditions.f90:810:35:

  810 |         ceo_phase_rad(1:numsols) = pi*ceo_phase_deg(1:numsols)/180.0_wp
      |                                   1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/initial_conditions.f90:811:34:

  811 |         field_period(1:numsols) = 2.0*pi/frequency(1:numsols)
      |                                  1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/initial_conditions.f90:819:16:

  819 |                 ((time_between_IR_and_XUV_peaks(1:numsols)/(2.0_wp*pi)) + &
      |                1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/initial_conditions.f90:823:47:

  823 |         polarization_offset_angle(1:numsols) = angle_between_pulses_in_deg(1:numsols)*pi/180.0_wp
      |                                               1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
[  8%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/calculation_parameters.f90.o
/opt/rmt/source/modules/calculation_parameters.f90:259:35:

  259 |             steps_per_run_approx = final_t/delta_t
      |                                   1
Warning: Possible change of value in conversion from REAL(8) to INTEGER(4) at (1) [-Wconversion]
[  9%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/channels.f90.o
/opt/rmt/source/modules/channels.f90:92:10:

   92 |       USE initial_conditions, ONLY: jK_coupling_id, LS_coupling_id, Mol_coupling_id
      |          1
Warning: Unused parameter 'ls_coupling_id' which has been explicitly imported at (1) [-Wunused-parameter]
/opt/rmt/source/modules/channels.f90:92:10:

   92 |       USE initial_conditions, ONLY: jK_coupling_id, LS_coupling_id, Mol_coupling_id
      |          1
Warning: Unused parameter 'mol_coupling_id' which has been explicitly imported at (1) [-Wunused-parameter]
[ 11%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/communications_parameters.f90.o
[ 12%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/grid_parameters.f90.o
[ 13%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/mpi_communications.F90.o
/opt/rmt/source/modules/mpi_communications.F90:2893:31:

 2893 |         first_field_zero = all(current_field_strength == 0.0_wp, 1)
      |                               1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/mpi_communications.F90:595:12:

  595 |         USE grid_parameters, ONLY: x_1st, &
      |            1
Warning: Unused parameter 'channel_id_1st' which has been explicitly imported at (1) [-Wunused-parameter]
/opt/rmt/source/modules/mpi_communications.F90:595:12:

  595 |         USE grid_parameters, ONLY: x_1st, &
      |            1
Warning: Unused module variable 'channel_id_last' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_communications.F90:610:41:

  610 |         INTEGER :: x_size, no_of_channels
      |                                         1
Warning: Unused variable 'no_of_channels' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_communications.F90:143:100:

  143 |         INTEGER :: status_array(MPI_STATUS_SIZE), my_send, my_recv, send_tag, recv_tag, pe_num, ierr
      |                                                                                                    1
Warning: Unused variable 'ierr' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_communications.F90:143:48:

  143 |         INTEGER :: status_array(MPI_STATUS_SIZE), my_send, my_recv, send_tag, recv_tag, pe_num, ierr
      |                                                1
Warning: Unused variable 'status_array' declared at (1) [-Wunused-variable]
[ 15%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/io_parameters.f90.o
[ 16%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/wall_clock.f90.o
[ 18%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/dipole_input_file.f90.o
[ 19%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/coordinate_system.f90.o
/opt/rmt/source/modules/coordinate_system.f90:142:16:

  142 |         alpha = euler_alpha(i)*pi/180
      |                1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/coordinate_system.f90:143:15:

  143 |         beta = euler_beta(i)*pi/180
      |               1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/coordinate_system.f90:144:16:

  144 |         gamma = euler_gamma(i)*pi/180
      |                1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
[ 20%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/electric_field.f90.o
/opt/rmt/source/modules/electric_field.f90:785:25:

  785 |                 prefac = ABS(time - midtime) - nosc*pi/frequency
      |                         1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:756:21:

  756 |             prefac = ABS(time - midtime) - nosc*pi/frequency
      |                     1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:334:22:

  334 |             midtime = (-1.0_wp*delay_XUV_in_IR_periods + 0.5_wp*(nosc + 2.0_wp*periods_of_ramp_on))*2.0_wp*pi/frequency
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:336:22:

  336 |             midtime = (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:345:16:

  345 |         phase = phase - pi*0.5_wp
      |                1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:469:22:

  469 |             midtime = (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:472:22:

  472 |             midtime = (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency + delay_XUV_in_IR_periods*2.0_wp*pi/frequency
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:424:22:

  424 |             midtime = (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:426:22:

  426 |             midtime = (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency + delay_XUV_in_IR_periods*2.0_wp*pi/frequency_IR
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:443:20:

  443 |             phase = phase - pi*0.5_wp
      |                    1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:374:22:

  374 |             midtime = (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:376:22:

  376 |             midtime = (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency + delay_XUV_in_IR_periods*2.0_wp*pi/frequency_IR
      |                      1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:393:20:

  393 |             phase = phase - pi*0.5_wp
      |                    1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:302:18:

  302 |         midtime = 0.0_wp + (nosc + 2.0_wp*periods_of_ramp_on)*pi/frequency
      |                  1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:308:16:

  308 |         phase = phase - pi*0.5_wp
      |                1
Warning: Possible change of value in conversion from REAL(16) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/electric_field.f90:259:22:

  259 |             linear = (ellipticity(isol) == 0)
      |                      1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/electric_field.f90:261:39:

  261 |                 linear = linear .AND. (ellipticity_XUV(isol) == 0) .AND. .NOT. cross_polarized(isol)
      |                                       1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
[ 22%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/file_num.f90.o
[ 23%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/hamiltonian_input_file.f90.o
[ 25%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/readhd.f90.o
/opt/rmt/source/modules/readhd.f90:2681:50:

 2681 |     SUBROUTINE deallocate_region_iii_angmom_arrays
      |                                                  ^
Warning: 'deallocate_region_iii_angmom_arrays' defined but not used [-Wunused-function]
[ 26%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/mpi_layer_lblocks.f90.o
/opt/rmt/source/modules/mpi_layer_lblocks.f90:236:56:

  236 |              .AND. REAL(SUM(euler_beta(:))) == 0.0 .AND. REAL(SUM(euler_gamma(:))) == 0.0) &
      |                                                        1
Warning: Equality comparison for REAL(4) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:236:18:

  236 |              .AND. REAL(SUM(euler_beta(:))) == 0.0 .AND. REAL(SUM(euler_gamma(:))) == 0.0) &
      |                  1
Warning: Equality comparison for REAL(4) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:235:61:

  235 |              .AND. REAL(SUM(ellipticity_xuv(:))) == 0.0 .AND. REAL(SUM(euler_alpha(:))) == 0.0 &
      |                                                             1
Warning: Equality comparison for REAL(4) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:235:18:

  235 |              .AND. REAL(SUM(ellipticity_xuv(:))) == 0.0 .AND. REAL(SUM(euler_alpha(:))) == 0.0 &
      |                  1
Warning: Equality comparison for REAL(4) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:232:12:

  232 |         if (REAL(SUM(ellipticity(:))) == 0.0 .and. .NOT.(molecular_target) &
      |            1
Warning: Equality comparison for REAL(4) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:268:38:

  268 |               biased_tot_pe(pe_num) = temp_sum
      |                                      1
Warning: Possible change of value in conversion from REAL(4) to INTEGER(4) at (1) [-Wconversion]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:288:35:

  288 |            biased_tot_pe(pe_num) = temp_sum
      |                                   1
Warning: Possible change of value in conversion from REAL(4) to INTEGER(4) at (1) [-Wconversion]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:296:35:

  296 |            biased_tot_pe(pe_num) = temp_sum
      |                                   1
Warning: Possible change of value in conversion from REAL(4) to INTEGER(4) at (1) [-Wconversion]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:304:35:

  304 |            biased_tot_pe(pe_num) = biased_tot_pe(pe_num) + temp_sum
      |                                   1
Warning: Possible change of value in conversion from REAL(4) to INTEGER(4) at (1) [-Wconversion]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:974:29:

  974 |         INTEGER :: rsum, i, j, err, Lb_m_size, sum_rows, LML_block_count
      |                             1
Warning: Unused variable 'j' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:974:23:

  974 |         INTEGER :: rsum, i, j, err, Lb_m_size, sum_rows, LML_block_count
      |                       1
Warning: Unused variable 'rsum' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:551:37:

  551 |                    biased_tot_average
      |                                     1
Warning: Unused variable 'biased_tot_average' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:550:77:

  550 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum, num_sum, &
      |                                                                             1
Warning: Unused variable 'diff_above' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:550:65:

  550 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum, num_sum, &
      |                                                                 1
Warning: Unused variable 'diff_below' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:552:80:

  552 |         INTEGER :: lml, i, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                                                                                1
Warning: Unused variable 'i_last' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:546:37:

  546 |         INTEGER :: err, L, Iterations
      |                                     1
Warning: Unused variable 'iterations' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:552:22:

  552 |         INTEGER :: lml, i, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                      1
Warning: Unused variable 'lml' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:552:72:

  552 |         INTEGER :: lml, i, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                                                                        1
Warning: Unused variable 'lml_multi' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:552:61:

  552 |         INTEGER :: lml, i, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                                                             1
Warning: Unused variable 'lml_temp' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:549:39:

  549 |         INTEGER :: max_sub_block_LML(1), no_of_remaining_pes
      |                                       1
Warning: Unused variable 'max_sub_block_lml' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:550:96:

  550 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum, num_sum, &
      |                                                                                                1
Warning: Unused variable 'num_sum' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:552:42:

  552 |         INTEGER :: lml, i, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                                          1
Warning: Unused variable 'pe_num' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:552:51:

  552 |         INTEGER :: lml, i, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                                                   1
Warning: Unused variable 'pe_numm' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:547:57:

  547 |         INTEGER :: states_per_sub_block(no_of_LML_blocks)
      |                                                         1
Warning: Unused variable 'states_per_sub_block' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:552:34:

  552 |         INTEGER :: lml, i, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                                  1
Warning: Unused variable 'sum_num' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:550:87:

  550 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum, num_sum, &
      |                                                                                       1
Warning: Unused variable 'temp_sum' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:550:39:

  550 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum, num_sum, &
      |                                       1
Warning: Unused variable 'test' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:550:46:

  550 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum, num_sum, &
      |                                              1
Warning: Unused variable 'test2' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:550:53:

  550 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum, num_sum, &
      |                                                     1
Warning: Unused variable 'test3' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:199:37:

  199 |         INTEGER :: err, L, Iterations
      |                                     1
Warning: Unused variable 'iterations' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:202:39:

  202 |         INTEGER :: max_sub_block_LML(1), no_of_remaining_pes
      |                                       1
Warning: Unused variable 'max_sub_block_lml' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:202:60:

  202 |         INTEGER :: max_sub_block_LML(1), no_of_remaining_pes
      |                                                            1
Warning: Unused variable 'no_of_remaining_pes' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:204:54:

  204 |         INTEGER :: lml, i, j, sum_num, pe_num, pe_numm, lml_temp, lml_multi, i_last, my_starting_block
      |                                                      1
Warning: Unused variable 'pe_numm' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:203:39:

  203 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum
      |                                       1
Warning: Unused variable 'test' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:203:46:

  203 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum
      |                                              1
Warning: Unused variable 'test2' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/mpi_layer_lblocks.f90:203:53:

  203 |         REAL    :: biased_average, test, test2, test3, diff_below, diff_above, temp_sum
      |                                                     1
Warning: Unused variable 'test3' declared at (1) [-Wunused-variable]
[ 27%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/distribute_hd_blocks.f90.o
/opt/rmt/source/modules/distribute_hd_blocks.f90:530:31:

  530 |         integer   :: i_array(3), i_temp, num
      |                               1
Warning: Unused variable 'i_array' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/distribute_hd_blocks.f90:504:12:

  504 |         USE global_data, ONLY: im
      |            1
Warning: Unused parameter 'im' which has been explicitly imported at (1) [-Wunused-parameter]
/opt/rmt/source/modules/distribute_hd_blocks.f90:438:12:

  438 |         USE mpi_layer_lblocks,  ONLY: my_LML_block_id, my_num_LML_blocks
      |            1
Warning: Unused module variable 'my_lml_block_id' which has been explicitly imported at (1) [-Wunused-variable]
[ 29%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/distribute_hd_blocks2.f90.o
/opt/rmt/source/modules/distribute_hd_blocks2.f90:272:12:

  272 |         USE mpi_layer_lblocks, ONLY: inner_region_rank, &
      |            1
Warning: Unused module variable 'lml_pe_method' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/distribute_hd_blocks2.f90:92:12:

   92 |         USE mpi_layer_lblocks,    ONLY: Lb_comm, Lb_size, i_am_block_master, my_LML_block_id, &
      |            1
Warning: Unused module variable 'inner_region_rank' which has been explicitly imported at (1) [-Wunused-variable]
[ 30%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/distribute_wv_data.f90.o
/opt/rmt/source/modules/distribute_wv_data.f90:309:47:

  309 |         integer                   :: sum_blocks, i_blend, i_typ
      |                                               1
Warning: Unused variable 'sum_blocks' declared at (1) [-Wunused-variable]
[ 31%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/inner_to_outer_interface.f90.o
/opt/rmt/source/modules/inner_to_outer_interface.f90:269:12:

  269 |         USE communications_parameters, ONLY: id_of_1st_pe_outer, pe_id_1st
      |            1
Warning: Unused module variable 'id_of_1st_pe_outer' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:288:25:

  288 |         INTEGER :: ierror, My_rank, length_of_array, send_pe, number_of_pes, isol
      |                         1
Warning: Unused variable 'ierror' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:270:12:

  270 |         USE grid_parameters,           ONLY: my_num_channels, my_channel_id_1st, my_channel_id_last
      |            1
Warning: Unused module variable 'my_channel_id_1st' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:270:12:

  270 |         USE grid_parameters,           ONLY: my_num_channels, my_channel_id_1st, my_channel_id_last
      |            1
Warning: Unused module variable 'my_channel_id_last' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:241:60:

  241 |         INTEGER :: ierror, My_rank, length_of_array, send_pe
      |                                                            1
Warning: Unused variable 'send_pe' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:157:12:

  157 |         USE readhd,                ONLY: max_L_block_size
      |            1
Warning: Unused module variable 'max_l_block_size' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:153:69:

  153 |     SUBROUTINE get_outer_initial_state_at_b(psi_outer_at_b, psi_inner, simple_start)
      |                                                                     1
Warning: Unused dummy argument 'psi_inner' at (1) [-Wunused-dummy-argument]
/opt/rmt/source/modules/inner_to_outer_interface.f90:65:95:

   65 |         INTEGER                     :: i, ierr, j, jj, isol, j_cumul, j2, my_nchan_sum, i_dummy, j_dummy
      |                                                                                               1
Warning: Unused variable 'i_dummy' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:53:12:

   53 |         USE mpi_layer_lblocks,     ONLY: i_am_block_master, Lb_m_comm, Lb_comm, lb_size, lb_m_rank
      |            1
Warning: Unused module variable 'inner_region_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:65:104:

   65 |         INTEGER                     :: i, ierr, j, jj, isol, j_cumul, j2, my_nchan_sum, i_dummy, j_dummy
      |                                                                                                        1
Warning: Unused variable 'j_dummy' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:53:12:

   53 |         USE mpi_layer_lblocks,     ONLY: i_am_block_master, Lb_m_comm, Lb_comm, lb_size, lb_m_rank
      |            1
Warning: Unused module variable 'lb_m_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_to_outer_interface.f90:55:12:

   55 |         USE readhd,                ONLY: max_L_block_size
      |            1
Warning: Unused module variable 'max_l_block_size' which has been explicitly imported at (1) [-Wunused-variable]
[ 33%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/lrpots.f90.o
/opt/rmt/source/modules/lrpots.f90:805:37:

  805 |         REAL(wp), parameter :: norm = -SQRT(4.0_wp*pi/3.0_wp)
      |                                     1
Warning: Change of value in conversion from 'REAL(16)' to 'REAL(8)' at (1) [-Wconversion]
/opt/rmt/source/modules/lrpots.f90:1042:44:

 1042 |                                         IF (pmtrxel2 /= (0.0_wp, 0.0_wp)) THEN
      |                                            1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/lrpots.f90:1045:44:

 1045 |                                         IF (pmtrxel1 /= (0.0_wp, 0.0_wp)) THEN
      |                                            1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/lrpots.f90:715:44:

  715 |                                         IF (pmtrxel1 /= (0.0_wp, 0.0_wp)) THEN
      |                                            1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/lrpots.f90:472:54:

  472 |                                     IF (li == lj .AND. ABS(crlv_v(targ1, targ2)) &
      |                                                      1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/lrpots.f90:374:62:

  374 |                         IF (li == lj .AND. mi == mj .AND. any(tmom /= 0)) THEN
      |                                                              1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/lrpots.f90:255:54:

  255 |                                     IF (li == lj .AND. ABS(crlv(targ1, targ2)) &
      |                                                      1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
[ 34%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/coupling_rules.f90.o
[ 36%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/live_communications.f90.o
/opt/rmt/source/modules/live_communications.f90:804:60:

  804 |                 IF ( (IAND(cnt, upcoupling) /= 0) .AND. ANY(fieldfactor(1, :) /= zero) ) THEN
      |                                                            1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/live_communications.f90:817:62:

  817 |                 IF ( (IAND(cnt, downcoupling) /= 0) .AND. ANY(fieldfactor(2, :) /= zero) ) THEN
      |                                                              1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/live_communications.f90:830:62:

  830 |                 IF ( (IAND(cnt, samecoupling) /= 0) .AND. ANY(fieldfactor(3, :) /= zero) ) THEN
      |                                                              1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/live_communications.f90:774:49:

  774 |         INTEGER                  :: tmp_req, ierr, isol, i_yes
      |                                                 1
Warning: Unused variable 'ierr' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:742:12:

  742 |         USE mpi_layer_lblocks,  ONLY: Lb_m_rank, my_num_LML_blocks, my_LML_block_id
      |            1
Warning: Unused module variable 'lb_m_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:742:12:

  742 |         USE mpi_layer_lblocks,  ONLY: Lb_m_rank, my_num_LML_blocks, my_LML_block_id
      |            1
Warning: Unused module variable 'my_lml_block_id' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:637:12:

  637 |         USE mpi_layer_lblocks, ONLY: Lb_m_rank, &
      |            1
Warning: Unused module variable 'istep_v' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:637:12:

  637 |         USE mpi_layer_lblocks, ONLY: Lb_m_rank, &
      |            1
Warning: Unused module variable 'lb_m_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:633:82:

  633 |     SUBROUTINE send_recv_master_vecs_ptp_cmpt(my_i_block, my_LML_block, my_numrows, field, i, j, my_vec,&
      |                                                                                  1
Warning: Unused dummy argument 'my_numrows' at (1) [-Wunused-dummy-argument]
/opt/rmt/source/modules/live_communications.f90:634:94:

  634 |                                               vecin, numstart, n, my_vecs, my_blocksizes, nvec, req, &
      |                                                                                              1
Warning: Unused dummy argument 'nvec' at (1) [-Wunused-dummy-argument]
/opt/rmt/source/modules/live_communications.f90:659:52:

  659 |         INTEGER     :: status_array(MPI_STATUS_SIZE)
      |                                                    1
Warning: Unused variable 'status_array' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:489:12:

  489 |         USE mpi_layer_lblocks, ONLY: my_num_lml_blocks
      |            1
Warning: Unused module variable 'my_num_lml_blocks' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:182:55:

  182 |         integer                              :: i_temp1, i_temp2, numstart(my_num_LML_blocks)
      |                                                       1
Warning: Unused variable 'i_temp1' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:182:64:

  182 |         integer                              :: i_temp1, i_temp2, numstart(my_num_LML_blocks)
      |                                                                1
Warning: Unused variable 'i_temp2' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:150:12:

  150 |         USE mpi_layer_lblocks,     ONLY: Lb_m_rank, my_num_LML_blocks, my_LML_block_id, &
      |            1
Warning: Unused module variable 'istep_v' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:150:12:

  150 |         USE mpi_layer_lblocks,     ONLY: Lb_m_rank, my_num_LML_blocks, my_LML_block_id, &
      |            1
Warning: Unused module variable 'lb_m_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/live_communications.f90:149:12:

  149 |         USE global_data,           ONLY: one
      |            1
Warning: Unused parameter 'one' which has been explicitly imported at (1) [-Wunused-parameter]
[ 37%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/outer_to_inner_interface.f90.o
/opt/rmt/source/modules/outer_to_inner_interface.f90:205:12:

  205 |         USE distribute_hd_blocks2, ONLY: numrows_sum, numrows_m, re_surf_amps
      |            1
Warning: Unused module variable 'numrows_m' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_to_inner_interface.f90:118:61:

  118 |         INTEGER :: send_length_of_array, my_block_group_pe_id, recv_pe, length_of_array, isol, number_of_pes
      |                                                             1
Warning: Unused variable 'my_block_group_pe_id' declared at (1) [-Wunused-variable]
[ 38%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/serial_matrix_algebra.f90.o
/opt/rmt/source/modules/serial_matrix_algebra.f90:360:12:

  360 |         IF (hnorm .EQ. 0.0_wp) STOP 'Error - null H in input of ZGPADM. Try a smaller delta_t'
      |            1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/serial_matrix_algebra.f90:88:43:

   88 |         INTEGER                     :: i, j
      |                                           1
Warning: Unused variable 'j' declared at (1) [-Wunused-variable]
[ 40%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/inner_propagators.f90.o
/opt/rmt/source/modules/inner_propagators.f90:495:23:

  495 |         field_on = ANY(field_strength /= 0.0_wp)
      |                       1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/inner_propagators.f90:372:28:

  372 |                     IF (ANY(field /= 0.0_wp)) THEN
      |                            1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/inner_propagators.f90:637:12:

  637 |         USE mpi_layer_lblocks,   ONLY: inner_region_rank
      |            1
Warning: Unused module variable 'inner_region_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_propagators.f90:465:12:

  465 |         USE global_data,              ONLY: im, zero
      |            1
Warning: Unused parameter 'zero' which has been explicitly imported at (1) [-Wunused-parameter]
/opt/rmt/source/modules/inner_propagators.f90:251:12:

  251 |         USE mpi_layer_lblocks,       ONLY : inner_region_rank, my_num_LML_blocks
      |            1
Warning: Unused module variable 'my_num_lml_blocks' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_propagators.f90:187:12:

  187 |         USE mpi_layer_lblocks,  ONLY: inner_region_rank, istep_v
      |            1
Warning: Unused module variable 'inner_region_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/inner_propagators.f90:102:104:

  102 |     SUBROUTINE setup_propagation_data(krydim, krytech, exptech, t, krylov_hdt_desired, my_num_LML_blocks)
      |                                                                                                        1
Warning: Unused dummy argument 'my_num_lml_blocks' at (1) [-Wunused-dummy-argument]
/opt/rmt/source/modules/inner_propagators.f90:872:41:

  872 |     SUBROUTINE reset_powers_of_H_array_in
      |                                         ^
Warning: 'reset_powers_of_h_array_in' defined but not used [-Wunused-function]
[ 41%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/io_routines.f90.o
/opt/rmt/source/modules/io_routines.f90:752:55:

  752 |         INTEGER                    :: i, sum, num, numb
      |                                                       1
Warning: Unused variable 'numb' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/io_routines.f90:708:55:

  708 |         integer                    :: my_pe_id, i_write
      |                                                       1
Warning: Unused variable 'i_write' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/io_routines.f90:708:46:

  708 |         integer                    :: my_pe_id, i_write
      |                                              1
Warning: Unused variable 'my_pe_id' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/io_routines.f90:348:55:

  348 |         integer                    :: i, sum, num, numb
      |                                                       1
Warning: Unused variable 'numb' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/io_routines.f90:95:45:

   95 |     SUBROUTINE binary_write_arrays(time_array,&
      |                                             1
Warning: Unused dummy argument 'time_array' at (1) [-Wunused-dummy-argument]
[ 43%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/ql_eigendecomposition.f90.o
/opt/rmt/source/modules/ql_eigendecomposition.f90:161:20:

  161 |                 IF (tst2 .EQ. tst1) GO TO 120
      |                    1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/ql_eigendecomposition.f90:44:12:

   44 |         IF (p == 0.0_wp) THEN
      |            1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/ql_eigendecomposition.f90:55:16:

   55 |             IF (t == 4.0_wp) THEN
      |                1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
[ 44%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/eigenstates_in_kryspace.f90.o
[ 45%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/local_ham_matrix.f90.o
/opt/rmt/source/modules/local_ham_matrix.f90:458:33:

  458 |                 D1(0)*psi_near_b(x_1st) + &
      |                                 1
Warning: Array reference at (1) is out of bounds (1 < 2) in dimension 1
/opt/rmt/source/modules/local_ham_matrix.f90:84:12:

   84 |         USE communications_parameters, ONLY: id_of_last_pe_outer
      |            1
Warning: Unused module variable 'id_of_last_pe_outer' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/local_ham_matrix.f90:85:12:

   85 |         USE grid_parameters,           ONLY: channel_id_1st, &
      |            1
Warning: Unused parameter 'channel_id_1st' which has been explicitly imported at (1) [-Wunused-parameter]
/opt/rmt/source/modules/local_ham_matrix.f90:85:12:

   85 |         USE grid_parameters,           ONLY: channel_id_1st, &
      |            1
Warning: Unused module variable 'channel_id_last' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/local_ham_matrix.f90:78:61:

   78 |                                             i_am_outer_master, i_am_in_first_outer_block, i_am_in_last_outer_block)
      |                                                             1
Warning: Unused dummy argument 'i_am_outer_master' at (1) [-Wunused-dummy-argument]
/opt/rmt/source/modules/local_ham_matrix.f90:85:12:

   85 |         USE grid_parameters,           ONLY: channel_id_1st, &
      |            1
Warning: Unused module variable 'my_num_channels' which has been explicitly imported at (1) [-Wunused-variable]
[ 47%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/global_linear_algebra.f90.o
/opt/rmt/source/modules/global_linear_algebra.f90:133:18:

  133 |             sum = sum + CONJG(X(i))*Y(i)*rweight(i)
      |                  1
Warning: Possible change of value in conversion from COMPLEX(8) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/global_linear_algebra.f90:88:18:

   88 |             sum = sum + CONJG(Y(i))*Y(i)*rweight(i)
      |                  1
Warning: Possible change of value in conversion from COMPLEX(8) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/global_linear_algebra.f90:258:31:

  258 |         INTEGER    :: i, j, err, ierr
      |                               1
Warning: Unused variable 'err' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/global_linear_algebra.f90:244:12:

  244 |         USE mpi_communications, ONLY: mpi_comm_region, mpi_comm_inter_block
      |            1
Warning: Unused module variable 'mpi_comm_inter_block' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/global_linear_algebra.f90:100:12:

  100 |         USE global_data, ONLY: one
      |            1
Warning: Unused parameter 'one' which has been explicitly imported at (1) [-Wunused-parameter]
/opt/rmt/source/modules/global_linear_algebra.f90:55:12:

   55 |         USE global_data, ONLY: one
      |            1
Warning: Unused parameter 'one' which has been explicitly imported at (1) [-Wunused-parameter]
[ 48%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/kryspace_taylor_sums.f90.o
[ 50%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/potentials.f90.o
/opt/rmt/source/modules/potentials.f90:96:20:

   96 |            we_sum = we_sum + region_three_wemat(ich - jch, jch, lambda)*x
      |                    1
Warning: Possible change of value in conversion from COMPLEX(8) to REAL(8) at (1) [-Wconversion]
[ 51%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/outer_hamiltonian.f90.o
/opt/rmt/source/modules/outer_hamiltonian.f90:944:16:

  944 |             IF (wp_ham2_coeff /= 0) THEN
      |                1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:956:18:

  956 |               IF (wp_ham2_coeff /= 0) THEN
      |                  1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:747:16:

  747 |             IF (wd_ham_coeff /= 0) THEN
      |                1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:759:18:

  759 |               IF (wd_ham_coeff /= 0) THEN
      |                  1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:871:44:

  871 |             IF ( (wp_ham_coeff1 /= 0) .OR. (wp_ham_coeff2 /=0) ) THEN
      |                                            1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:871:18:

  871 |             IF ( (wp_ham_coeff1 /= 0) .OR. (wp_ham_coeff2 /=0) ) THEN
      |                  1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:887:46:

  887 |               IF ( (wp_ham_coeff1 /= 0) .OR. (wp_ham_coeff2 /=0) ) THEN
      |                                              1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:887:20:

  887 |               IF ( (wp_ham_coeff1 /= 0) .OR. (wp_ham_coeff2 /=0) ) THEN
      |                    1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:812:16:

  812 |             IF (wd_ham_coeff /= 0) THEN
      |                1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:824:18:

  824 |               IF (wd_ham_coeff /= 0) THEN
      |                  1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:264:16:

  264 |         IF (ALL(field_strength == 0.0_wp)) THEN
      |                1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/outer_hamiltonian.f90:668:82:

  668 |     SUBROUTINE incr_w_we_ham_x_vector_outer(psi, H_psi, WE_store, ic_me, channel_i,number_grid_points)
      |                                                                                  1
Warning: Unused dummy argument 'channel_i' at (1) [-Wunused-dummy-argument]
/opt/rmt/source/modules/outer_hamiltonian.f90:592:52:

  592 |         INTEGER                    :: my_group_pe_id, my_block_group_pe_id
      |                                                    1
Warning: Unused variable 'my_group_pe_id' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_hamiltonian.f90:521:58:

  521 |         INTEGER                    :: i, ierr, i_prev, i_c
      |                                                          1
Warning: Unused variable 'i_c' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_hamiltonian.f90:522:52:

  522 |         INTEGER                    :: my_group_pe_id, my_block_group_pe_id
      |                                                    1
Warning: Unused variable 'my_group_pe_id' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_hamiltonian.f90:146:12:

  146 |         USE communications_parameters, ONLY: pe_id_last_outer
      |            1
Warning: Unused module variable 'pe_id_last_outer' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_hamiltonian.f90:118:12:

  118 |         USE communications_parameters, ONLY: pe_id_last_outer
      |            1
Warning: Unused module variable 'pe_id_last_outer' which has been explicitly imported at (1) [-Wunused-variable]
[ 52%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/outer_hamiltonian_atrlessthanb.f90.o
/opt/rmt/source/modules/outer_hamiltonian_atrlessthanb.f90:86:16:

   86 |         IF (ALL(field_strength == 0.0_wp)) THEN
      |                1
Warning: Equality comparison for REAL(8) at (1) [-Wcompare-reals]
[ 54%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/outer_propagators.f90.o
/opt/rmt/source/modules/outer_propagators.f90:783:38:

  783 |                                 dhr = CONJG(h(m, k, isol))
      |                                      1
Warning: Possible change of value in conversion from COMPLEX(8) to REAL(8) at (1) [-Wconversion]
/opt/rmt/source/modules/outer_propagators.f90:1400:12:

 1400 |         USE mpi_communications,             ONLY: get_my_group_pe_id, i_am_in_first_outer_block
      |            1
Warning: Unused module variable 'i_am_in_first_outer_block' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_propagators.f90:1420:41:

 1420 |         integer   :: my_group_pe_id, isol
      |                                         1
Warning: Unused variable 'isol' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_propagators.f90:1154:34:

 1154 |          INTEGER     :: channel_id, idip, isol, order
      |                                  1
Warning: Unused variable 'channel_id' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_propagators.f90:1124:52:

 1124 |                                       i_am_pe0_outer, i_am_in_first_outer_block, &
      |                                                    1
Warning: Unused dummy argument 'i_am_pe0_outer' at (1) [-Wunused-dummy-argument]
/opt/rmt/source/modules/outer_propagators.f90:517:12:

  517 |         USE mpi_communications,       ONLY: get_my_group_pe_id, &
      |            1
Warning: Unused module variable 'timeindex_val' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/outer_propagators.f90:319:58:

  319 |                                             i_am_pe0_outer, i_am_in_first_outer_block)
      |                                                          1
Warning: Unused dummy argument 'i_am_pe0_outer' at (1) [-Wunused-dummy-argument]
[ 55%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/stages.f90.o
[ 56%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/io_files.f90.o
[ 58%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/work_at_intervals.f90.o
[ 59%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/wavefunction.f90.o
/opt/rmt/source/modules/wavefunction.f90:1016:58:

 1016 |         integer                :: my_pe_id, my_group_pe_id
      |                                                          1
Warning: Unused variable 'my_group_pe_id' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/wavefunction.f90:1016:42:

 1016 |         integer                :: my_pe_id, my_group_pe_id
      |                                          1
Warning: Unused variable 'my_pe_id' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/wavefunction.f90:351:12:

  351 |         USE communications_parameters, ONLY: inner_group_id, pe_id_1st_inner
      |            1
Warning: Unused parameter 'pe_id_1st_inner' which has been explicitly imported at (1) [-Wunused-parameter]
/opt/rmt/source/modules/wavefunction.f90:356:12:

  356 |         USE mpi_communications,        ONLY: get_my_pe_id, &
      |            1
Warning: Unused module variable 'i_am_in_0_plus_first_outer_block' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/wavefunction.f90:369:37:

  369 |         INTEGER             :: ierror
      |                                     1
Warning: Unused variable 'ierror' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/wavefunction.f90:371:46:

  371 |         INTEGER             :: length_of_array, send_pe, dim_first, pe_gs_id_val
      |                                              1
Warning: Unused variable 'length_of_array' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/wavefunction.f90:371:55:

  371 |         INTEGER             :: length_of_array, send_pe, dim_first, pe_gs_id_val
      |                                                       1
Warning: Unused variable 'send_pe' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/wavefunction.f90:265:12:

  265 |         USE readhd, ONLY: max_L_block_size
      |            1
Warning: Unused module variable 'max_l_block_size' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/wavefunction.f90:269:32:

  269 |         INTEGER :: err, my_pe_id
      |                                1
Warning: Unused variable 'my_pe_id' declared at (1) [-Wunused-variable]
[ 61%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/checkpoint.f90.o
[ 62%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/fftpack.f90.o
[ 63%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/inner_parallelisation.f90.o
[ 65%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/kernel.f90.o
/opt/rmt/source/modules/kernel.f90:48:12:

   48 |         USE mpi_communications,        ONLY: first_pes_share_cmplx2_from, &
      |            1
Warning: Unused module variable 'mpi_comm_block' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/kernel.f90:79:35:

   79 |         INTEGER  :: length_of_array, send_pe
      |                                   1
Warning: Unused variable 'length_of_array' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/kernel.f90:79:44:

   79 |         INTEGER  :: length_of_array, send_pe
      |                                            1
Warning: Unused variable 'send_pe' declared at (1) [-Wunused-variable]
[ 66%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/splines.f90.o
[ 68%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/setup_bspline_basis.f90.o
[ 69%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/setup_wv_data.f90.o
[ 70%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/finalise.f90.o
[ 72%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/two_electron_outer_hamiltonian.f90.o
/opt/rmt/source/modules/two_electron_outer_hamiltonian.f90:441:16:

  441 |             IF (wp_ham3_coeff /= zero) THEN
      |                1
Warning: Inequality comparison for COMPLEX(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/two_electron_outer_hamiltonian.f90:117:21:

  117 |       field_on = ANY(field_strength /= 0.0_wp)
      |                     1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
[ 73%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/version_control.F90.o
[ 75%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/initialise.f90.o
/opt/rmt/source/modules/initialise.f90:141:16:

  141 |             IF (deltar .NE. deltar_molecular) THEN
      |                1
Warning: Inequality comparison for REAL(8) at (1) [-Wcompare-reals]
/opt/rmt/source/modules/initialise.f90:414:12:

  414 |         USE mpi_layer_lblocks,        ONLY: i_am_block_master, inner_region_rank
      |            1
Warning: Unused module variable 'inner_region_rank' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/initialise.f90:286:12:

  286 |         USE mpi_communications, ONLY : get_my_block_group_pe_id, i_am_outer_master, &
      |            1
Warning: Unused module variable 'i_am_inner_master' which has been explicitly imported at (1) [-Wunused-variable]
[ 76%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/recoupling.f90.o
/opt/rmt/source/modules/recoupling.f90:36:12:

   36 |         USE modChannel, ONLY: Channel, &
      |            1
Warning: Unused parameter 'ls_channel_id' which has been explicitly imported at (1) [-Wunused-parameter]
[ 77%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/postprocessing.F90.o
/opt/rmt/source/modules/postprocessing.F90:1259:12:

 1259 |         USE readhd,             ONLY: LML_block_tot_nchan, &
      |            1
Warning: Unused module variable 'rmatr' which has been explicitly imported at (1) [-Wunused-variable]
/opt/rmt/source/modules/postprocessing.F90:1267:77:

 1267 |         INTEGER :: Nwave, nwv, jj, number_of_points, istep, ii, isol, unitnum
      |                                                                             1
Warning: Unused variable 'unitnum' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/postprocessing.F90:1266:51:

 1266 |         CHARACTER(LEN=:), ALLOCATABLE :: write_name
      |                                                   1
Warning: Unused variable 'write_name' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/postprocessing.F90:1033:37:

 1033 |     SUBROUTINE reform_write_vtk_ascii (rho, numpt, nth, R0, dR)
      |                                     ^
Warning: 'reform_write_vtk_ascii' defined but not used [-Wunused-function]
[ 79%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/utilities.f90.o
/opt/rmt/source/modules/utilities.f90:50:49:

   50 |         INTEGER :: str_width, i, remaining, digit
      |                                                 1
Warning: Unused variable 'digit' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/utilities.f90:50:31:

   50 |         INTEGER :: str_width, i, remaining, digit
      |                               1
Warning: Unused variable 'i' declared at (1) [-Wunused-variable]
/opt/rmt/source/modules/utilities.f90:50:42:

   50 |         INTEGER :: str_width, i, remaining, digit
      |                                          1
Warning: Unused variable 'remaining' declared at (1) [-Wunused-variable]
[ 80%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/serialiseHD.f90.o
[ 81%] Building Fortran object modules/CMakeFiles/RMTmodules.dir/tdse_dependencies.f90.o
[ 83%] Linking Fortran static library ../lib/libRMTmodules.a
[ 83%] Built target RMTmodules
[ 84%] Building Fortran object programs/CMakeFiles/rmt.x.dir/tdse.f90.o
[ 86%] Linking Fortran executable ../bin/rmt.x
[ 86%] Built target rmt.x
[ 87%] Building Fortran object programs/CMakeFiles/reform.dir/reform.f90.o
[ 88%] Linking Fortran executable ../bin/reform
[ 88%] Built target reform
[ 90%] Building Fortran object programs/CMakeFiles/field_check.dir/field_check.f90.o
[ 91%] Linking Fortran executable ../bin/field_check
[ 91%] Built target field_check
[ 93%] Building Fortran object programs/CMakeFiles/GetProcInfo.dir/GetProcInfo.f90.o
/opt/rmt/source/programs/GetProcInfo.f90:35:8:

   35 |     USE mpi_layer_lblocks,      ONLY: my_L_block_id => my_LML_block_id,Lb_rank, my_num_LML_blocks
      |        1
Warning: Unused module variable 'my_num_lml_blocks' which has been explicitly imported at (1) [-Wunused-variable]
[ 94%] Linking Fortran executable ../bin/GetProcInfo
[ 94%] Built target GetProcInfo
[ 95%] Building Fortran object programs/CMakeFiles/GetChannelInfo.dir/GetChannelInfo.f90.o
[ 97%] Linking Fortran executable ../bin/GetChannelInfo
[ 97%] Built target GetChannelInfo
[ 98%] Building Fortran object programs/CMakeFiles/convertHD.dir/convertHD.f90.o
[100%] Linking Fortran executable ../bin/convertHD
[100%] Built target convertHD
Removing intermediate container 9b6340eb41e5
 ---> 532b674e89cc
Step 25/25 : CMD [ "/bin/bash" ]
 ---> Running in 71b284fc57b5
Removing intermediate container 71b284fc57b5
 ---> a3509e634538
Successfully built a3509e634538
Successfully tagged fock:5000/rmt:v250624
steacie@fock:/software/docker/rmt$ docker run -l "user=$(whoami)" --name rmtTest --rm -it fock:5000/rmt:v250624 bash
