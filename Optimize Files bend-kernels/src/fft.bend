# Optimized FFT with precomputed twiddle factors and shared memory.
# Input: a (list of field elements), forward (bool)
# Output: transformed list.

# Precomputed twiddle factors (global in GPU memory).
twiddles = precompute_twiddles(max_size)

def fft(a: List[Field], forward: bool) -> List[Field]:
    n = len(a)
    if n == 1:
        return a

    # Cooley-Tukey with shared memory for each level.
    # Use iterative approach for better memory access.
    result = a.copy()
    # Bit-reversal reordering.
    j = 0
    for i in range(1, n):
        bit = n >> 1
        while j & bit:
            j ^= bit
            bit >>= 1
        j ^= bit
        if i < j:
            result[i], result[j] = result[j], result[i]

    # FFT stages.
    length = 2
    while length <= n:
        wlen = exp(-2*pi*1i/length) if forward else exp(2*pi*1i/length)
        for i in range(0, n, length):
            w = 1
            for j in range(i, i + length//2):
                u = result[j]
                v = result[j + length//2] * w
                result[j] = u + v
                result[j + length//2] = u - v
                w *= wlen
        length <<= 1

    return result