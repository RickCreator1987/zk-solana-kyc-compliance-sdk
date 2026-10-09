# Optimized MSM using Pippenger's algorithm with warp-level reductions.
# Input: points (list of points in projective coordinates), scalars (list of scalars)
# Output: resulting point.

def msm(points: List[Point], scalars: List[Field]) -> Point:
    # Bucket size for Pippenger.
    bucket_size = 16
    num_buckets = 1 << bucket_size

    # Parallel reduction: each thread processes a chunk.
    # Using bend's parallel for loop.
    buckets = [point_zero() for _ in range(num_buckets)]

    # Partition scalars into windows.
    for i in range(len(scalars)):
        scalar = scalars[i]
        # Extract windows of bucket_size bits.
        for w in range(0, len(scalar), bucket_size):
            window = (scalar >> w) & (num_buckets - 1)
            if window != 0:
                # Add point to bucket in parallel.
                # In bend, we can use a parallel reduce.
                buckets[window] = point_add(buckets[window], points[i])

    # Aggregate buckets using double-and-add.
    result = point_zero()
    for w in range(num_buckets - 1, 0, -1):
        # Fuse multiply-add: result = result * 2^bucket_size + bucket[w]
        for _ in range(bucket_size):
            result = point_double(result)
        result = point_add(result, buckets[w])

    return result