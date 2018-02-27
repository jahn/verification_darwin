#!/bin/bash
#SBATCH -J ev3                  # job name
#SBATCH -p sched_mit_darwin     # which queue ("partition")
#SBATCH -N 6                    # number of nodes to use (each has 16 cores)
#SBATCH -n 96                   # total number of cores to run on
#SBATCH --mem-per-cpu 4000      # memory per core needed (16-core nodes have 64GB)
#SBATCH --time 12:00:00         # run no longer than 16 hours
#
# jobintel.slurm
# jobintel.slurm <nIter0>
# jobintel.slurm <nIter0> <nEndIter>
# jobintel.slurm <nIter0> +<nTimeSteps>
#
# All but the first form modify the file "data" to start (and optionally end)
# at the specified iterations (or run for the specified number of iterations).

module add slurm
module add engaging/intel/2013.1.046
module add hdf5/1.8.14_intel-2013.1.046
module add netcdf/4.3.3.1_intel-2013.1.046
#module add engaging/git
module add git

# log git info
echo "================================================================================"
cd ../src
pwd
echo "--------------------------------------------------------------------------------"
if git rev-parse 2>/dev/null; then
    git log -n 1
    echo
    git status
    git diff
else
    echo "Not in a git repository"
fi
echo "================================================================================"
cd -
echo

# adjust run start
if [ -n "$1" ]; then
    # replace nIter0 or starttime (can only have one of these)
    # and get rid of any pickup suffix
    sed -i -e 's/^ *niter0 *=.*$/ nIter0='$1',/I' \
           -e 's/^ *starttime *=.*$/ nIter0='$1',/I' \
           -e 's/ *pickupsuff *=.*$/#&/I' data
    if ! grep -q "^ nIter0=$1," data; then
        echo "Could not set nIter0"
        exit 1
    fi
    echo "Starting run at iteration $1"
fi

# adjust run end
if [ -n "$2" ]; then
    nenditer="$2"
    if [ ${nenditer::1} = '+' ]; then
        ntimesteps=${nenditer:1}
        endspec=" nTimeSteps=$ntimesteps,"
    else
        endspec=" nEndIter=$nenditer,"
    fi
    sed -i -e "s/^ *ntimesteps *=.*\$/$endspec/I" \
           -e "s/^ *nenditer *=.*\$/$endspec/I" \
           -e "s/^ *endtime *=.*\$/$endspec/I" data
    if ! grep -q "^$endspec$" data; then
        echo "Could not set run end"
        exit 1
    fi
    echo "Setting run end to $endspec"
fi

# move previous output out of the way
if [ -f STDOUT.0000 ] ||
   [ -f w2_tile_topology.0000.log ] ||
   [ -f darwin_params.nml ] ||
   [ -f p-ini-char-aptype.dat ]
then
    dir=output-$(date +%Y%m%d%H%M%S)
    if [ -f STDOUT.0000 ]; then
        prev="$( grep -A1 '(PID.TID ....\.....) nIter0 =' STDOUT.0000 |
                 tail -n 1 |
                 sed 's/(PID.TID ....\.....) *//' )"
        if [ -n "$prev" ]; then
            dir=$( printf 'output.%010d' $prev )
        fi
    fi
    if [ -e "$dir" ]; then
        dir=dir-$(date +%Y%m%d%H%M%S)
    fi

    mkdir $dir || echo "$dir already exists"
    if [ -f STDOUT.0000 ]; then
        mv -f STD* $dir/
    fi
    if [ -f w2_tile_topology.0000.log ]; then
        mv -f w2_* $dir/
    fi
    if [ -f darwin_params.nml ]; then
        mv -f darwin_*.nml $dir/
    fi
    if [ -f p-ini-char-aptype.dat ]; then
        mv -f p-* p_* pwaves* $dir/
    fi
    rmdir $dir || echo "Previous output moved to $dir"
fi

mpirun ./mitgcmuv || exit 1
tail STDOUT.0000 | grep -q "Execution ended Normally" || exit 1

ckpt="$( grep ' %CHECKPOINT' STDOUT.0000 | tail -n 1 )"
if [ -n "$ckpt" ]; then
    echo "Last checkpoint: $ckpt"
fi

if [ -n "$1" ]; then
  dir=$( printf 'output.%010d' $1 )
  if [ -e $dir ]; then
    dir=$dir-$(date +%Y%m%d%H%M%S)
  fi
  echo "Moving output to $dir"
  mkdir $dir
  mv -f STD* darwin_*.nml p-* p_* pwaves* $dir/
fi

