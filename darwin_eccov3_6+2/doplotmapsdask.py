#!/usr/bin/env python
'''
Usage:
  doplotmapsdask.py <dirprefix> <ptracerprefix> <ntile> <t>

plots surface maps of all ptracers
'''
from __future__ import division
import sys
import os
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import AxesGrid
from mncdask import mncdask

try:
    dirpfx, pfx, ntile, t = sys.argv[1:]
except:
    sys.exit(__doc__)

ntile = int(ntile)
t = int(t)
chunkdims = 3
k = 0
ny, nx = 160, 360

rdir, _ = os.path.split(dirpfx)
pdir, rname = os.path.split(rdir)

indices = np.arange(34)  #np.r_[1:21, 21, 22, 23, 25, 30, 35, 57, 61, 72, 73, 74, 76, 81, 86] - 1
nflds = len(indices)

mxphy = 2.
mxchl = .2
norms = dict.fromkeys(['c{:01d}'.format(i) for i in range(1, 36)],
                      plt.Normalize(0., mxphy))
norms.update(dict.fromkeys(['Chl{:01d}'.format(i) for i in range(1, 36)],
                      plt.Normalize(0., mxchl)))

plt.rc('axes', facecolor='k')

with mncdask(dirpfx, pfx, ntile, chunkdims) as d:
    names = d.ptracer_names
    lm = d['DIC'][t, k] == 0
    tny, tnx = lm.shape[-2:]
    nty = ny // tny
    ntx = nx // tnx
    tiledshape = (nty, ntx, tny, tnx)

#    nflds = len(names)
    nrows = int(np.ceil(np.sqrt(nflds)*1.05))
    ncols = int(np.ceil(nflds/nrows))
    W = 23.95
    H = W/ncols*nrows*.4
    plt.close(1)
    fig = plt.figure(1, (W, H), dpi=80)
    grid = AxesGrid(fig, [.6/W, .3/H, 1 - 1.6/W, 1 - .6/H], (nrows, ncols),
                    label_mode="L",
                    share_all=True,
                    cbar_location="right",
                    cbar_mode="each",
                    cbar_size=0.15,
                    cbar_pad=0.05,
                    axes_pad=(1., 0.3),
                    add_all=False,
                    )

    for iax, i in enumerate(indices):
        ax = grid.axes_all[iax]
        fig.add_axes(ax)
        fig.add_axes(ax.cax)
        fld = names[i]
        ax.set_title(fld)
        a = np.ma.MaskedArray(d[fld][t, k], lm)
        a = a.reshape(tiledshape).transpose([0, 2, 1, 3]).reshape((ny, nx))
        norm = norms.get(fld, plt.Normalize())
        im = ax.imshow(a, norm=norm, extent=(-180, 180, -80,80),
                       interpolation='lanczos')
        fig.colorbar(im, ax.cax)

fig.savefig('maps_{}_{}_mon{:03d}.png'.format(rname, pfx, t))

