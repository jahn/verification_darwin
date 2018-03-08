#!/usr/bin/env python
'''
Usage: mkprofiles.py DIRPREFIX FILEPREFIX NTILE ITERSLICE

./mkprofilesdask.py r/run/mnc_ ptr 96 0:1
./mkprofilesdask.py r/run/ecco_gud_ 3d 96 240:28801:240
'''
import sys
from glob import glob
from os.path import split, join
from collections import OrderedDict
import numpy as np
from h5py import File
from netCDF4 import Dataset
from mncdask import mncdask

try:
    dirpfx, pfx, ntile, itslice = sys.argv[1:]
except IndexError:
    sys.exit(__doc__)

rdir, _ = split(dirpfx)

ntile = int(ntile)

iters = range(*map(int, itslice.split(':')))

with mncdask(dirpfx, 'grid', ntile) as g:
    dr = g['drF'][:]
    a = g['rA']
    h = g['HFacC']
    v = h*a
    w = v/v.sum((1, 2, 3), keepdims=True)
    w *= dr[:, None, None, None]
    nk = w.shape[0]
    with File(rdir+'/avhdr.h5', 'w') as out:
        t = 0
        for itfile in iters:
            with mncdask(dirpfx, pfx + '.{:010d}'.format(itfile), ntile) as d:
                if not 'ptracer_names' in out.attrs:
                    out.attrs['ptracer_names'] = map(str, d.ptracer_names)
                    T = d['T'][:]
                    it = d['iter'][:]
                    out['T'] = T
                    out['iter'] = it
                    out['DRF'] = dr
                    nt = len(T)
                    for k in d.ptracer_names:
                        out.create_dataset(k, (len(iters)*nt,) + d[k].shape[1:-3], d[k].dtype)

                for k in d.ptracer_names:
                    print itfile, k
                    a = (d[k][:]*w).sum((-3, -2, -1)).compute()
                    assert a.shape[0] == nt
                    out[k][t:t+nt] = a

            t += nt

