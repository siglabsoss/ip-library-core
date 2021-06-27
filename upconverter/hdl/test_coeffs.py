import numpy as np
import matplotlib.pyplot as pt

words = [
    '111111111110000110',
    '000000000010111011',
    '111111111010111101',
    '000000001000000101',
    '111111110011101111',
    '000000010001111010',
    '111111100110101010',
    '000000100011000011',
    '111111010000010101',
    '000001000000010000',
    '111110101001100011',
    '000001110101100000',
    '111101011011110001',
    '000011110100101000',
    '111001010111010000',
    '010100010100011111'
]

weights = 2**(np.arange(17,-1,-1))
weights[0] = -weights[0]

h0 = np.zeros(63);

for k, word in enumerate(words):
    accum = 0
    for n, bit in enumerate(word):
        if bit == '1':
            accum += weights[n]
    h0[2*k] = accum
    h0[62-2*k] = accum

h0[31] = 1 << 17

pt.figure()
pt.plot(h0)

H0 = np.fft.fftshift(np.fft.fft(h0, 2**18))
pt.figure()
pt.plot(np.arange(-2**17, 2**17)*2**-18, 20*np.log10(np.abs(H0)))
pt.xlim([-0.5, 0.5])

pt.show()
