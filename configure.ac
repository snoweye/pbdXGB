### configure.ac					-*- Autoconf -*-

AC_PREREQ(2.62)

AC_INIT([xgboost],[0.6-3],[],[xgboost],[])

OPENMP_CXXFLAGS=""

if test `uname -s` = "Linux"
then
  OPENMP_CXXFLAGS="\$(SHLIB_OPENMP_CXXFLAGS)"
fi

if test `uname -s` = "Darwin"
then
  OPENMP_CXXFLAGS="\$(SHLIB_OPENMP_CXXFLAGS)"
  ac_pkg_openmp=no
  AC_MSG_CHECKING([whether OpenMP will work in a package])
  AC_LANG_CONFTEST(
  [AC_LANG_PROGRAM([[#include <omp.h>]], [[ return omp_get_num_threads (); ]])])
  PKG_CFLAGS="${OPENMP_CFLAGS}" PKG_LIBS="${OPENMP_CFLAGS}" "$RBIN" CMD SHLIB conftest.c 1>&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD && "$RBIN" --vanilla -q -e "dyn.load(paste('conftest',.Platform\$dynlib.ext,sep=''))" 1>&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD && ac_pkg_openmp=yes
  AC_MSG_RESULT([${ac_pkg_openmp}])
  if test "${ac_pkg_openmp}" = no; then
    OPENMP_CXXFLAGS=''
  fi
fi

dnl MPI C library related
R_SCMD="${R_HOME}/bin/Rscript -e"
MPI_CPPFLAGS=`${R_SCMD} "pbdMPI::get.conf('PKG_CPPFLAGS','"${R_ARCH}"','pbdMPI')"`
MPI_LDFLAGS=`${R_SCMD} "pbdMPI::get.conf('PKG_LIBS','"${R_ARCH}"','pbdMPI')"`
PBDR_MPICXX="PBDR_SKIP_MPICXX"
RABIT_ENGINE="engine_mpicc"

dnl MPI C++ library related
AC_ARG_ENABLE(mpi-cxx,
  AC_HELP_STRING([--enable-mpi-cxx], [Enable MPI C++ library, default no.]),
                 [ENABLE_MPI_CXX="yes"], [ENABLE_MPI_CXX="no"])
if test "X$ENABLE_MPI_CXX" = "Xyes" ; then
  AC_CHECK_PROG(SED, sed, sed, "F")
  MPITYPE=`${R_SCMD} "pbdMPI::get.conf('MPITYPE','"${R_ARCH}"','pbdMPI')"`
  MPI_LIBPATH=`${R_SCMD} "pbdMPI::get.conf('MPI_LIBPATH','"${R_ARCH}"','pbdMPI')"`

  if test "$MPITYPE" = "OPENMPI" ; then
    MPI_LDFLAGS=`echo ${MPI_LDFLAGS} | sed -e "s/ -lmpi / -lmpi_cxx -lmpi /"`
    MPI_LIBNAME_CXX="libmpi_cxx.so"
  elif test "$MPITYPE" = "MPICH2" -o "$MPITYPE" = "MPICH" -o "$MPITYPE" = "MPICH3" ; then
    MPI_LDFLAGS="${MPI_LIBPATH}/libmpicxx.a ${MPI_LDFLAGS}"
    MPI_LIBNAME_CXX="libmpicxx.a"
  else
    AC_MSG_ERROR([Unknown type of MPI])
  fi

  if test ! -f "${MPI_LIBPATH}/${MPI_LIBNAME_CXX}" ; then
    echo "Found no ${MPI_LIBPATH}/${MPI_LIBNAME_CXX} ..."
    AC_MSG_ERROR([File is not found.])
  fi

  PBDR_MPICXX="PBDR_USE_MPICXX"
  RABIT_ENGINE="engine_mpi"
fi

echo " "
echo "************ Results of MPI C and CXX configure ***************************"
echo " "
echo ">> MPI_CPPFLAGS = ${MPI_CPPFLAGS}"
echo ">> MPI_LDFLAGS = ${MPI_LDFLAGS}"
echo " "
echo ">> ENABLE_MPI_CXX = ${ENABLE_MPI_CXX}"
echo ">> MPITYPE = ${MPITYPE}"
echo ">> MPI_LIBPATH = ${MPI_LIBPATH}"
echo ">> MPI_LIBNAME_CXX = ${MPI_LIBNAME_CXX}"
echo " "
echo ">> PBDR_MPICXX = ${PBDR_MPICXX}"
echo ">> RABIT_ENGINE = ${RABIT_ENGINE}"
echo " "
echo "*********************************************************************"
echo " "

AC_SUBST(MPI_CPPFLAGS)
AC_SUBST(MPI_LDFLAGS)
AC_SUBST(ENABLE_MPI_CXX)
AC_SUBST(MPI_LIBPATH)
AC_SUBST(MPI_LIBNAME_CXX)
AC_SUBST(PBDR_MPICXX)
AC_SUBST(RABIT_ENGINE)
AC_OUTPUT(R/zzz.r)

AC_SUBST(OPENMP_CXXFLAGS)
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT

