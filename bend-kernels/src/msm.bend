# Multi-scalar multiplication kernel for GPU.
# Bend language for parallel computing.
# This is a simplified version.

def msm(scalars: List[Field], points: List[Point]) -> Point:
    # Parallel map over scalars and points.
    # Use bend's parallel capabilities.
    sum = point_zero()
    for i in range(len(scalars)):
        sum = point_add(sum, point_mul(scalars[i], points[i]))
    return sum