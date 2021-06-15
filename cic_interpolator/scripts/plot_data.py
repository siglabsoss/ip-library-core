import numpy as np
import matplotlib.pyplot as pt

freqs, phases, mags = [], [], []
with open('../sim/test1.txt') as fid:
    for line in fid:
        fields = line.split(',')
        freqs.append(float(fields[0]))
        mags.append(float(fields[1]))
        phases.append(float(fields[2]))
freqs = np.array(freqs)
phases = np.array(phases)
mags = np.array(mags)

pt.figure()
pt.title('Magnitudes')
pt.plot(freqs, 20*np.log10(mags/np.max(mags)))
pt.xlabel('CIC output')
pt.xlim([-0.5,0.5])

pt.figure()
pt.title('Phases')
pt.plot(freqs, phases)
pt.xlabel('CIC output')
pt.xlim([-0.5,0.5])

pt.show()
