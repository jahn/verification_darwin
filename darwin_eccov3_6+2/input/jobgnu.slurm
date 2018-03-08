#!/bin/sh
#SBATCH -J gev3                 # job name
#SBATCH -p sched_mit_darwin     # which queue ("partition")
#SBATCH -n 32                   # total number of cores to run on
#SBATCH --exclusive
#SBATCH --mem-per-cpu 4000      # memory per core needed (16-core nodes have 64GB)
#SBATCH --time 12:00:00         # run no longer than 16 hours

module add gcc
module add mvapich2/gcc
module add slurm
module add harvard/centos6/hdf5-1.8.11_gcc-4.4.7
module add harvard/centos6/netcdf-4.3.0_gcc-4.4.7

mpirun ./mitgcmuv

tail STDOUT.0000 | grep -q "Execution ended Normally" || exit 1

