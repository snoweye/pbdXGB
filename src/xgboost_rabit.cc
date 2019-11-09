#include <rabit/rabit.h>
#include <Rinternals.h>


extern "C" SEXP XGBoosterRabitInit_R(){
  SEXP ret;
  PROTECT(ret = allocVector(LGLSXP, 1));
  LOGICAL(ret)[0] = rabit::Init(0, NULL);
  UNPROTECT(1);
  return ret;
}

extern "C" SEXP XGBoosterRabitFinalize_R(){
  SEXP ret;
  PROTECT(ret = allocVector(LGLSXP, 1));
  LOGICAL(ret)[0] = rabit::Finalize();
  UNPROTECT(1);
  return ret;
}

extern "C" SEXP XGBoosterRabitGetWorldSize_R(){
  SEXP ret;
  PROTECT(ret = allocVector(INTSXP, 1));
  INTEGER(ret)[0] = rabit::GetWorldSize();
  UNPROTECT(1);
  return ret;
}

extern "C" SEXP XGBoosterRabitGetRank_R(){
  SEXP ret;
  PROTECT(ret = allocVector(INTSXP, 1));
  INTEGER(ret)[0] = rabit::GetRank();
  UNPROTECT(1);
  return ret;
}
