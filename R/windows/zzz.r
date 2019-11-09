### Lastest load into a package.

## Export Namespace does not use .First.lib() and .Last.lib(), but use
## .onLoad() and .onUnload().

## See "pbdBASE/R/zzz.r" and "pbdMPI/R/zzz.r.in" for details.

.onLoad <- function(libname, pkgname){
  if(! is.loaded("spmd_initialize", PACKAGE = "pbdMPI")){
    library.dynam("pbdMPI", "pbdMPI", libname)
    if(pbdMPI::comm.is.null(0L) == -1){
      pbdMPI::init()
    }
  }

  library.dynam("pbdXGB", pkgname, libname)
  invisible()
} # End of .onLoad().

.onUnload <- function(libpath){
  library.dynam.unload("pbdXGB", libpath)
  invisible()
} # End of .onUnload().

