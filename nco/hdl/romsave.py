import numpy as np

def mybin(x, N=36):
    if N == 36:
        if x < 0:
            return '{:036b}'.format(2**N + x)
        else:
            return '{:036b}'.format(x)
    elif N == 18:
        if x < 0:
            return '{:018b}'.format(2**N + x)
        else:
            return '{:018b}'.format(x)
    elif N == 16:
        if x < 0:
            return '{:016b}'.format(2**N + x)
        else:
            return '{:016b}'.format(x)
    elif N == 8:
        if x < 0:
            return '{:08b}'.format(2**N + x)
        else:
            return '{:08b}'.format(x)
    else:
        if x < 0:
            return '{:0b}'.format(2**N + x)
        else:
            return '{:0b}'.format(x)


rom0 = np.exp(2j*np.pi*(np.arange(32) - 2)/32.0)
rom1 = np.exp(2j*np.pi*(np.arange(32) - 1)/32.0)
rom2 = np.exp(2j*np.pi*(np.arange(32) - 0)/32.0)
rom3 = np.exp(2j*np.pi*(np.arange(32) + 1)/32.0)

scale_factor = ((2**35) - 2)

with open('dds_cosines0.mif', 'w') as fid:
    for r in rom0:
        cval = int(np.round(scale_factor * np.real(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))

with open('dds_sines0.mif', 'w') as fid:
    for r in rom0:
        cval = int(np.round(scale_factor * np.imag(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))

with open('dds_cosines1.mif', 'w') as fid:
    for r in rom1:
        cval = int(np.round(scale_factor * np.real(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))

with open('dds_sines1.mif', 'w') as fid:
    for r in rom0:
        cval = int(np.round(scale_factor * np.imag(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))

with open('dds_cosines2.mif', 'w') as fid:
    for r in rom2:
        cval = int(np.round(scale_factor * np.real(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))

with open('dds_sines2.mif', 'w') as fid:
    for r in rom2:
        cval = int(np.round(scale_factor * np.imag(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))

with open('dds_cosines3.mif', 'w') as fid:
    for r in rom3:
        cval = int(np.round(scale_factor * np.real(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))

with open('dds_sines3.mif', 'w') as fid:
    for r in rom3:
        cval = int(np.round(scale_factor * np.imag(r)))
        fid.write("{0}\n".format(mybin(cval, N=36)))