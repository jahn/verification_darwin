#!/bin/sh
#SBATCH -J macro
#SBATCH -p sched_mit_darwin2
#SBATCH -x node[650]
#SBATCH -n 144
#SBATCH --mem-per-cpu 4000
#SBATCH --exclusive

. /etc/profile.d/modules.sh
module rm gcc
module load gcc/6.2.0
module load jahn/mvapich2/2.3.2_gcc-6.2.0
module load jahn/hdf5/1.10.6_gcc-6.2.0
module load jahn/netcdf-c/4.7.3_gcc-6.2.0_hdf-1.10.6
module load jahn/netcdf-fortran/4.5.2_gcc-6.2.0_hdf-1.10.6

mpirun -n 144 ./mitgcmuv

tail STDOUT.0000 | grep -q "Execution ended Normally" || exit 1

ckpt="$( grep ' %CHECKPOINT' STDOUT.0000 | tail -n 1 )"
if [ -n "$ckpt" ]; then
    echo "Last checkpoint: $ckpt"
fi
