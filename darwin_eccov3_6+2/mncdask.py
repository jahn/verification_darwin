from collections import OrderedDict
from glob import glob
import dask.array as da
from netCDF4 import Dataset

class MNCDask(object):
    def __init__(self, dirpfx, pfx, ntile, chunkdims=0):
        self.dirpfx = dirpfx
        self.pfx = pfx
        self.ntile = ntile
        self.chunkdims = chunkdims

        fnames = []
        for i in range(self.ntile):
            patt = self.dirpfx + '*/{}.t{:03d}.nc'.format(self.pfx, i+1)
            names = glob(patt)
            if len(names) == 0:
                raise IOError('No file found for {}\n'.format(patt))
            elif len(names) > 1:
                raise IOError('Multiple files found for {}\n'.format(patt))
            fname, = names
            fnames.append(fname)

        self.dss = [Dataset(fname, 'r') for fname in fnames]
        d = OrderedDict()
        names = []
        for fld in self.dss[0].variables:
            v0 = self.dss[0].variables[fld]
            shape = v0.shape
            if len(shape) >= 2 and v0.dimensions[-1][:1] == 'X' and v0.dimensions[-2][:1] == 'Y':
                chunks = shape
                if self.chunkdims:
                    chunks = max(0, len(shape) - self.chunkdims)*(1,) + shape[-self.chunkdims:]
                arrays = [da.from_array(ds.variables[fld], chunks=chunks) for ds in self.dss]
                oshape = shape[:-2] + (self.ntile,) + shape[-2:]
                a = da.concatenate(arrays, axis=-2).reshape(oshape)
                d[fld] = a
                if fld[:4] == 'TRAC':
                    name = v0.description.replace(' concentration', '')
                    d[name] = a
                    names.append(name)
            else:
                d[fld] = self.dss[0].variables[fld]

        self.d = d
        self.ptracer_names = names

    def __getitem__(self, idx):
        return self.d[idx]

    def scalar(self, fld):
        return self.dss[0].variables[fld]

    def close(self):
        if hasattr(self, 'dss'):
            for ds in self.dss[::-1]:
                if ds.isopen():
                    ds.close()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()

    def __del__(self):
        self.close()


mncdask = MNCDask

