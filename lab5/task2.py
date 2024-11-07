from math import atan

q = 15
S = 0

for n in range(1, 50):
    print(f"S = {S}, n = {n}")
    S += atan(1 / n) + (n - 1) / (n ** 2 + q ** n)