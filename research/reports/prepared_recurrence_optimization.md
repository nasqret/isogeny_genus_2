# Prepared Basis Differential Additions

## Reused data

The kernel-table recurrence repeatedly computes

```text
P + B from P, B, and P - B
```

for one of two fixed basis points `B`. The standard AVIsogenies differential
addition recomputes the Riemann relation and the quadratic sums involving
`B` on every call.

The prepared strategy computes those basis-dependent constants once. Each
subsequent recurrence step evaluates only the point-dependent quadratic sum
and combines it with the cached constant. If a difference point has a zero
theta coordinate, the implementation falls back to the original general
formula.

## Exact regression

Both strategies were run with the same Kummer-class root evaluator.

| degree | standard recurrence | prepared recurrence | reduction |
|---:|---:|---:|---:|
| 13 | 28.059 s | 20.432 s | 27.18% |
| 17 | 123.030 s | 58.156 s | 52.73% |
| 31 | 1783.443 s | 488.441 s | 72.61% |

The degree-17 dual phase falls from `167.898` to `117.750` seconds
(`29.87%`), and total recovery falls from `187.361` to `147.177` seconds
(`21.45%`). Degree-13 total timing is excluded from the performance claim
because unrelated extension construction was substantially slower in the
prepared run.

Exact comparison proves that all four X-maps and all four Y-maps are
identical. The target curves, invariant differentials, degrees, and every
interpolation sample also agree.

Prepared basis differential addition is now the default recurrence strategy
for explicit root evaluators. The standard recurrence remains selectable as
the regression oracle.

The degree-31 production comparison is exact. Prepared recurrence reduces
dual evaluation from `2400.937` to `896.082` seconds and total recovery from
`2560.543` to `968.821` seconds. Both maps are coefficient-for-coefficient
identical to the original production maps.
