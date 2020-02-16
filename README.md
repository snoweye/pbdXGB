# pbdXGB

* **License:** [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Apache-2.0)
* **Download:** [![Download](http://cranlogs.r-pkg.org/badges/pbdXGB)](https://cran.r-project.org/package=pbdXGB)
* **Status:** [![Build Status](https://travis-ci.org/snoweye/pbdXGB.png)](https://travis-ci.org/snoweye/pbdXGB) [![Appveyor Build status](https://ci.appveyor.com/api/projects/status/32r7s2skrgm9ubva?svg=true)](https://ci.appveyor.com/project/snoweye/pbdXGB)
* **Author:** See section below.

In pbdXGB, we write programs in the "Single Program/Multiple Data" or SPMD
style, typically executed via pbdMPI and MPI. Each process (MPI rank) gets
runs the same copy of the program as every other process, but operates
on its own data. The results will be collected, compared, and distributed to
each process via MPI allreduce-like calls.


## Usage

Below is a basic program siminar to the original "xgboost" example, but
in SPMD concepts using MPI or pbdMPI:

```r
suppressMessages(library(pbdMPI, quietly = TRUE))
suppressMessages(library(pbdXGB, quietly = TRUE))
init()

### Commonly owned all data
data(agaricus.train, package = "xgboost")
train.all <- agaricus.train
train.mat.all <- as.matrix(train.all$data)
label.all <- train.all$label
comm.print(nrow(train.mat.all))

### Locally owned distributed data
rows <- get.jid(nrow(train.mat.all))
train.mat <- train.mat.all[rows, ]
label <- label.all[rows]
comm.print(nrow(train.mat), all.rank = TRUE)

### Get the model from distributed data
mdl <- pbdXGB::xgboost(data = train.mat, label = label,
                       max.depth = 2, eta = 1, nthread = 1,
                       nrounds = 10, objective = "binary:logistic",
                       verbose = 0)
comm.print(mdl$evaluation_log$train_error)

### Check with xgboost::xgboost on all data
if (comm.rank() == 0){
  mdl.all <- xgboost::xgboost(data = train.mat.all, label = label.all,
                              max.depth = 2, eta = 1, nthread = 2,
                              nrounds = 10, objective = "binary:logistic",
                              verbose = 0)
  print(mdl.all$evaluation_log$train_error)
}

finalize()
```

Save the code in a file, say, `mpi_xgb.r` and run it in 4 processes via:

```
mpirun -np 4 Rscript mpi_xgb.r
```



## Installation

pbdXGB requires
* R version 3.0.0 or higher
* A system installation of MPI:
  - SUN HPC 8.2.1 (OpenMPI) for Solaris
  - OpenMPI for Linux
  - OpenMPI for Mac OS X
  - MS-MPI for Windows
* pbdR/R packages:
  - pbdMPI
  - xgboost and its dependent R packages



## Authors

pbdXGB is authored and maintained by the pbdR core team:
* Wei-Chen Chen
* Drew Schmidt

With additional contributions from:
* Tianqi Chen (xgboost R and C++ implementation)
* xgboost R authors and contributors (some functions are modified from xgboost R package)
* XGBoost contributors (base XGBoost implementation)
* The R Core team (some functions are modified from the base packages)

