import numpy as np
import matplotlib.pyplot as pt

data = []
with open('test_output.txt', 'r') as fid:
    for line in fid:
        x, y = line.split(',')
        data.append(float(x) + 1j*float(y))


pt.figure()
# pt.subplot(211)
pt.plot(np.real(data[:1000]), 'b')
pt.plot(np.imag(data[:1000]), 'r')
# x1 = np.cos(2*np.pi*(35.0/125.0)*np.arange(2**19))
# x2 = np.sin(2*np.pi*(35.0/125.0)*np.arange(2**19))
# a1 = np.dot(x1, np.real(data)) / np.dot(x1, x1)
# a2 = np.dot(x2, np.real(data)) / np.dot(x2, x2)
# x = np.round((a1 * x1 + a2 * x2)*2**15)*2**-15
# print ("detected phase of {0} degrees".format(180.0/np.pi*np.arctan2(a2, a1)))
# pt.subplot(212)
# pt.plot(np.real(x[:10000]))
# pt.plot(np.imag(x))

# pt.figure()
# Z = np.fft.fft(data, 10000)
# X = np.fft.fft(x, 10000)
# pt.plot(125.0*np.arange(-5000, 5000)/10000.0, 20*np.log10(np.abs(Z)))
# pt.plot(125.0*np.arange(-5000, 5000)/10000.0, 20*np.log10(np.abs(X)))
# pt.xlabel('MHz')

pt.figure()
Z = np.fft.fftshift(np.fft.fft(data, 2**18))
# X = np.fft.fftshift(np.fft.fft(x, 2**18))
# fs = 250.0
fs = 1.0
pt.plot(fs*np.arange(-2**17, 2**17)/2**18, 20*np.log10(np.abs(Z)))
# pt.plot(fs*np.arange(-2**17, 2**17)/2**18, 20*np.log10(np.abs(X)))
# pt.xlabel('MHz')

pt.show()