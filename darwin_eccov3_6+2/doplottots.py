#!/usr/bin/env python
'''
doplottots.py <profilefile>

doplottots.py r/run/avhdr.h5
'''
from __future__ import division
import sys
import os
import numpy as np
import matplotlib.pyplot as plt
from h5py import File

nk = 6
indices = np.arange(34)  #np.r_[1:21, 21, 22, 23, 25, 30, 35, 57, 61, 72, 73, 74, 76, 81, 86] - 1
nflds = len(indices)

fname, = sys.argv[1:]
rdir, _ = os.path.split(fname)
pdir, rname = os.path.split(rdir)

plt.rc('axes', facecolor='w')

with File(fname, 'r') as h:
    names = h.attrs['ptracer_names']
    t = h['T'][:] / 31104000.
    depth = h['DRF'][:nk].sum()
    print 'surface to depth', depth

#    nflds = len(names)
    nrows = int(np.ceil(np.sqrt(nflds)*1.05))
    ncols = int(np.ceil(nflds/nrows))
    W = 23.95
    H = W/ncols*nrows*.4
    kw = dict(left=1./W, right=1-.6/W, top=1-.3/H, bottom=.3/H)
    plt.close(1)
    fig, axs = plt.subplots(nrows, ncols, True, False, gridspec_kw=kw, num=1, figsize=(W, H), dpi=80)

    for iax, i in enumerate(indices):
        ax = axs.ravel()[iax]
        fld = names[i]
        ax.set_title(fld)
        a = h[fld][:, :nk].sum(1)/depth
        lh, = ax.plot(t, a)

fig.savefig('top{:.0f}m_{}.png'.format(depth, rname))

