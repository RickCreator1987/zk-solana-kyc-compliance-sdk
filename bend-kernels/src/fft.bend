# Fast Fourier Transform kernel.
def fft(a: List[Field]) -> List[Field]:
    # Simplified iterative Cooley-Tukey.
    n = len(a)
    if n == 1:
        return a
    else:
        even = fft(a[0::2])
        odd = fft(a[1::2])
        result = [0.0] * n
        for k in range(n//2):
            t = odd[k] * exp(-2*pi*1i*k/n)
            result[k] = even[k] + t
            result[k + n//2] = even[k] - t
        return result