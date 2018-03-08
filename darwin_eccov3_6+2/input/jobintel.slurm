#!/bin/sh
#SBATCH -J gev3                 # job name
#SBATCH -p sched_mit_darwin     # which queue ("partition")
#SBATCH -n 32                   # total number of cores to run on
#SBATCH --exclusive
#SBATCH --mem-per-cpu 4000      # memory per core needed (16-core nodes have 64GB)
#SBATCH --time 12:00:00         # run no longer than 16 hours
#SBATCH --no-requeue

module add slurm
module add engaging/intel/2013.1.046
module add hdf5/1.8.14_intel-2013.1.046
module add netcdf/4.3.3.1_intel-2013.1.046
module add engaging/git

mpirun ./mitgcmuv

tail STDOUT.0000 | grep -q "Execution ended Normally" || exit 1

ckpt="$( grep ' %CHECKPOINT' STDOUT.0000 | tail -n 1 )"
if [ -n "$ckpt" ]; then
    echo "Last checkpoint: $ckpt"
fi

