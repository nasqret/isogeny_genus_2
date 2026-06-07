# Kummer-Class Root Extraction

## Algebra

Let the level-2 field be `F_Q`, let `ell` be an odd prime, and assume
`v_ell(Q-1)=1`. Write `Q-1=ell*m`, so `gcd(ell,m)=1`.

Choose `c` whose image in `F_Q^*/(F_Q^*)^ell` is nontrivial, and take one
root `alpha` with `alpha^ell=c` in `F_(Q^ell)`. For any nonzero `a` in
`F_Q`, the value `a^m` identifies the unique class index `k` such that
`a/c^k` is an `ell`-th power in `F_Q`. If `e=ell^(-1) mod m`, then

```text
root(a) = (a/c^k)^e * alpha^k
```

has `ell`-th power `a`.

Thus one genuine `nth_root` computation replaces one call per compatible
lift. The remaining work is finite-field exponentiation and a lookup in the
order-`ell` class group.

## Measurements

The instrumented degree-13 individual-root run splits the heavy phase as:

| subphase | seconds |
|---|---:|
| compatible lifts | 1.774 |
| extension and 71 roots | 33.266 |
| kernel recurrence | 24.441 |
| theta power sums | 2.821 |
| descent and target construction | 1.635 |

Kummer batching reduces the root subphase to `11.455` seconds. Complete
runtime falls from `72.162` to `55.524` seconds, and the dual phase falls
from `63.952` to `46.297` seconds.

In degree 17, complete runtime falls from `272.338` to `187.361` seconds,
while the dual phase falls from `253.200` to `167.898` seconds.

Exact comparison proves that all four X-maps are identical. The Y-maps and
pulled-back differentials agree with sign `+1` in both factors and both
degrees. All map identities, degrees, and interpolation samples remain
certified.

Kummer-class extraction is now the default for the common prime-degree
extension. Individual root extraction remains selectable as an independent
regression strategy.

## Degree-31 production

The first production use takes one genuine root for all `143` compatible
deltas. The root-extraction subphase takes `237.727` seconds, while the full
dual-isogeny phase takes `2400.937` seconds. The exact maps descend directly
to `F_64853`, and independent Magma verification returns degrees `31,31`.

This confirms that root batching scales to the next frontier, but also shows
that it is no longer the dominant subphase: the kernel recurrence alone
takes `1783.443` seconds.
