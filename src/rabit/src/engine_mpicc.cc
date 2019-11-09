/*!
 *  Copyright (c) 2014 by Contributors
 * \file engine_mpicc.cc
 * \brief this file gives an implementation of engine interface using MPI,
 *   this will allow rabit program to run with MPI, but do not comes with fault tolerant
 *
 * \author Tianqi Chen
 *
 *   Altered by Wei-Chen Chen 2019 to get rid of MPI C++ calls and and
 *   supports for R, pbdMPI, and windows.
 */
#define _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_DEPRECATE
#define NOMINMAX

#ifndef OMPI_SKIP_MPICXX
#define OMPI_SKIP_MPICXX
#endif

#ifndef MPICH_SKIP_MPICXX
#define MPICH_SKIP_MPICXX
#endif

#ifdef WIN
#include <_mingw.h>
#endif

#ifdef _WIN64
#include <stdint.h>
#endif

#include <mpi.h>

#include <cstdio>
#include "../include/rabit/internal/engine.h"
#include "../include/rabit/internal/utils.h"

#include <R.h>
#include <Rinternals.h>

/*!
 * \brief TODO:
 *   Initial a right comm and change MPI_COMM_WORLD to the right comm.
 *   Other necessary global variables/pointers to go with the right comm is
 *   needed to be initialized as well.
 *   See "pbdMPI/src/spmd.c", "cop/src/utils.h", and "cop/src/cop_allreduce.c"
 *   for the right way of using MPI.
 *   Note: The default MPI_COMM_WORLD or MPI::COMM_WORLD is a bad idea and is
 *         not portable with other APIs and for further developments.
 *
 * \brief TODO:
 *   To avoid memory leak, it may need to set and free the datatype and
 *   the op before and after calls clearly.
 */

namespace rabit {

namespace utils {
    bool STOP_PROCESS_ON_ERROR = true;
}

namespace engine {
/*! \brief implementation of engine using MPI */
class MPIEngine : public IEngine {
 public:
  MPIEngine(void) {
    version_number = 0;
  }
  virtual void Allreduce(void *sendrecvbuf_,
                         size_t type_nbytes,
                         size_t count,
                         ReduceFunction reducer,
                         PreprocFunction prepare_fun,
                         void *prepare_arg) {
    utils::Error("MPIEngine:: Allreduce is not supported,"\
                 "use Allreduce_ instead");
  }
  virtual void Broadcast(void *sendrecvbuf_, size_t size, int root) {
    MPI_Bcast(sendrecvbuf_, size, MPI_CHAR, root, MPI_COMM_WORLD);
  }
  virtual void InitAfterException(void) {
    utils::Error("MPI is not fault tolerant");
  }
  virtual int LoadCheckPoint(Serializable *global_model,
                             Serializable *local_model = NULL) {
    return 0;
  }
  virtual void CheckPoint(const Serializable *global_model,
                          const Serializable *local_model = NULL) {
    version_number += 1;
  }
  virtual void LazyCheckPoint(const Serializable *global_model) {
    version_number += 1;
  }
  virtual int VersionNumber(void) const {
    return version_number;
  }
  /*! \brief get rank of current node */
  virtual int GetRank(void) const {
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
    return world_rank;
  }
  /*! \brief get total number of */
  virtual int GetWorldSize(void) const {
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    return world_size;
  }
  /*! \brief whether it is distributed */
  virtual bool IsDistributed(void) const {
    return true;
  }
  /*! \brief get the host name of current node */
  virtual std::string GetHost(void) const {
    int len;
    char name[MPI_MAX_PROCESSOR_NAME];
    MPI_Get_processor_name(name, &len);
    name[len] = '\0';
    return std::string(name);
  }
  virtual void TrackerPrint(const std::string &msg) {
    // simply print information into the tracker
    if (GetRank() == 0) {
      utils::Printf("%s", msg.c_str());
    }
  }

 private:
  int version_number;
};

// singleton sync manager
MPIEngine manager;

/*! \brief initialize the synchronization module */
bool Init(int argc, char *argv[]) {
  try {
    MPI_Init(&argc, &argv);
    return true;
  } catch (const std::exception& e) {
    REprintf(" failed in MPI Init %s\n", e.what());
    return false;
  }
}
/*! \brief finalize syncrhonization module */
bool Finalize(void) {
  try {
    MPI_Finalize();
    return true;
  } catch (const std::exception& e) {
    REprintf("failed in MPI shutdown %s\n", e.what());
    return false;
  }
}

/*! \brief singleton method to get engine */
IEngine *GetEngine(void) {
  return &manager;
}
// transform enum to MPI data type
inline MPI_Datatype GetType(mpi::DataType dtype) {
  using namespace mpi;
  switch (dtype) {
    case kChar: return MPI_CHAR;
    case kUChar: return MPI_BYTE;
    case kInt: return MPI_INT;
    case kUInt: return MPI_UNSIGNED;
    case kLong: return MPI_LONG;
    case kULong: return MPI_UNSIGNED_LONG;
    case kFloat: return MPI_FLOAT;
    case kDouble: return MPI_DOUBLE;
    case kLongLong: return MPI_LONG_LONG;
    case kULongLong: return MPI_UNSIGNED_LONG_LONG;
  }
  utils::Error("unknown mpi::DataType");
  return MPI_CHAR;
}
// transform enum to MPI OP
inline MPI_Op GetOp(mpi::OpType otype) {
  using namespace mpi;
  switch (otype) {
    case kMax: return MPI_MAX;
    case kMin: return MPI_MIN;
    case kSum: return MPI_SUM;
    case kBitwiseOR: return MPI_BOR;
  }
  utils::Error("unknown mpi::OpType");
  return MPI_MAX;
}
// perform in-place allreduce, on sendrecvbuf
void Allreduce_(void *sendrecvbuf,
                size_t type_nbytes,
                size_t count,
                IEngine::ReduceFunction red,
                mpi::DataType dtype,
                mpi::OpType op,
                IEngine::PreprocFunction prepare_fun,
                void *prepare_arg) {
  if (prepare_fun != NULL) prepare_fun(prepare_arg);
  MPI_Allreduce(MPI_IN_PLACE, sendrecvbuf,
                count, GetType(dtype), GetOp(op), MPI_COMM_WORLD);
}

// code for reduce handle
ReduceHandle::ReduceHandle(void)
    : handle_(NULL), redfunc_(NULL), htype_(NULL) {
}
/*!
 * \brief Potential memory leaks may occur here.
 *   The incomplete solution below is one way to block error messages because
 *   MPI_Op_free() (i.e. op->Free()) and MPI_Type_free() (i.e. dtype->Free())
 *   are not allowed after MPI_Finalize().
 *   Note: The better solution is to call the destructor (or delete) for each
 *         reduce handler individually then call MPI_Finalize().
 */
ReduceHandle::~ReduceHandle(void) {
  int flag;
  MPI_Finalized(&flag);
  if (flag) {
    if (handle_ != NULL) {
      MPI_Op *op = reinterpret_cast<MPI_Op*>(handle_);
      // MPI_Op_free(op);  // This can not be called after MPI_FINALIZE.
    }
    if (htype_ != NULL) {
      MPI_Datatype *dtype = reinterpret_cast<MPI_Datatype*>(htype_);
      // MPI_Type_free(dtype);  // This can not be called after MPI_FINALIZE.
    }
  } else {
    // WCC: I doubt that this was ever safely called when MPI is not finalized.
    if (handle_ != NULL) {
      MPI_Op *op = reinterpret_cast<MPI_Op*>(handle_);
      MPI_Op_free(op);
    }
    if (htype_ != NULL) {
      MPI_Datatype *dtype = reinterpret_cast<MPI_Datatype*>(htype_);
      MPI_Type_free(dtype);
    }
  }
}
int ReduceHandle::TypeSize(const MPI_Datatype &dtype) {
  int size;
  MPI_Type_size(dtype, &size);
  return size;
}
void ReduceHandle::Init(IEngine::ReduceFunction redfunc, size_t type_nbytes) {
  utils::Assert(handle_ == NULL, "cannot initialize reduce handle twice");
  if (type_nbytes != 0) {
    MPI_Datatype dtype;
    if (type_nbytes % 8 == 0) {
      MPI_Type_contiguous(type_nbytes / sizeof(long), MPI_LONG, &dtype);
    } else if (type_nbytes % 4 == 0) {
      MPI_Type_contiguous(type_nbytes / sizeof(int), MPI_INT, &dtype);
    } else {
      MPI_Type_contiguous(type_nbytes, MPI_CHAR, &dtype);
    }
    MPI_Type_commit(&dtype);
    created_type_nbytes_ = type_nbytes;
    htype_ = &dtype;  // This is global.
  }
  MPI_Op op;
  MPI_Op_create((MPI_User_function*) redfunc, true, &op);
  handle_ = &op;
}
void ReduceHandle::Allreduce(void *sendrecvbuf,
                             size_t type_nbytes, size_t count,
                             IEngine::PreprocFunction prepare_fun,
                             void *prepare_arg) {
  utils::Assert(handle_ != NULL, "must initialize handle to call AllReduce");
  MPI_Op *op = (MPI_Op*) handle_;
  MPI_Datatype *dtype = (MPI_Datatype*) htype_;
  /*!
   * \brief I am not really sure why or when htype_ can be NULL and it is not
   *   clear if type_nbytes can not be as in the call "the ReduceHandle::Init()".
   *   Note: htype_ here can be NULL not "MPI_DATATYPE_NULL".
   *
   *   Further, when "created_type_nbytes_ != type_nbytes", it seems to be a
   *   new "MPI_Datatype" is requested somewhere, so the original "MPI_Datatype"
   *   where dtype points need to be free and/or reset to "MPI_DATATYPE_NULL"
   *   by default. However, the dtype can be repointed/updated
   *   to a new type later via MPI_Type_contiguous().
   *
   *   Note: I am also not sure that type_nbytes must be not 0 in this call(?)
   */
  if (created_type_nbytes_ != type_nbytes || htype_ == NULL || *dtype == MPI_DATATYPE_NULL) {
    if (htype_ != NULL || *dtype != MPI_DATATYPE_NULL) {
      MPI_Type_free(dtype);
    }
    if (type_nbytes % 8 == 0) {
      MPI_Type_contiguous(type_nbytes / sizeof(long), MPI_LONG, dtype);
    } else if (type_nbytes % 4 == 0) {
      MPI_Type_contiguous(type_nbytes / sizeof(int), MPI_INT, dtype);
    } else {
      MPI_Type_contiguous(type_nbytes, MPI_CHAR, dtype);
    }
    MPI_Type_commit(dtype);
    created_type_nbytes_ = type_nbytes;
  }
  if (prepare_fun != NULL) prepare_fun(prepare_arg);
  MPI_Allreduce(MPI_IN_PLACE, sendrecvbuf, count, *dtype, *op, MPI_COMM_WORLD);
}
}  // namespace engine
}  // namespace rabit
