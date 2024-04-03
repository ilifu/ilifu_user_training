#!/usr/bin/env python

import numpy as np
import sympy

print("Started Setup")

# Memory
n = 1e9
arr=np.arange(0,n)
print(arr.shape)

# CPU
i = int(1e10)
p = sympy.prime(i)
print(f"Prime number {i}: {p}")
