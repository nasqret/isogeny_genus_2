# Row-Major Theta Power Sums

The original summation traverses each kernel row once per theta coordinate.
The row-major strategy reads each theta point once, accesses its coordinate
tuple directly, and accumulates all coordinate powers together.

Exact comparisons give:

| degree | coordinate-major | row-major | reduction |
|---:|---:|---:|---:|
| 13 | 5.356 s | 2.950 s | 44.92% |
| 17 | 17.295 s | 9.599 s | 44.50% |
| 31 | 202.155 s | 187.407 s | 7.30% |

All six X-maps and all six Y-maps are identical, as are the target curves,
differential pullbacks, degrees, and interpolation samples. The degree-31
percentage is measured across separate full runs and is therefore more
sensitive to machine load; the exact equivalence is the decisive acceptance
condition.

Row-major power sums are now the explicit evaluator default.
Coordinate-major accumulation remains the regression oracle.
