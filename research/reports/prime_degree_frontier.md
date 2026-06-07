# Prime-Degree Arithmetic Frontier

The generic SageMath scanner searches primes `q = 1 mod ell` in increasing
order. For each field it computes every Hasse trace compatible with
`ell^2 | #E(F_q)` and accepts the first field having at least two traces
whose Frobenius discriminants have distinct squareclasses.

The first candidates for the next three prime degrees are:

| degree | field | traces | CM squareclasses | samples | kernel cells |
|---:|---:|---|---|---:|---:|
| 31 | 64853 | `467,-494` | `-43,-1` | 70 | 68231 |
| 37 | 128021 | `705,-664` | `-11,-13` | 82 | 113627 |
| 41 | 195817 | `822,-859` | `-1,-3` | 90 | 152971 |

Degree 31 was selected and completed. Its kernel table has 21.1% more cells
than degree 29. The deliberately conservative extension-weighted model
predicted `2410.819` seconds for dual-isogeny evaluation; the measured value
is `2400.937` seconds, an error of `0.41%`.

The corresponding degree-37 and degree-41 estimates remain planning
heuristics at about 4792 and 7148 seconds. Degree 31 measures `1783.443`
seconds in the kernel recurrence and `353.803` seconds in theta power sums.
These are the next optimization targets before launching degree 37.
