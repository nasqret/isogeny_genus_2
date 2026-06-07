# Prime-Degree Synthesis Scaling

The end-to-end Frey-Kani pipeline is complete in degrees 13, 17, 19, and 23.
The machine-readable source is `results/prime_degree_scaling.json`.

| degree | field | samples | theta field | map field | theta seconds | recovery seconds | descent seconds | Magma seconds |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 13 | 8009 | 34 | 12 | 24 | 4.249 | 251.786 | 3.485 | 0.160 |
| 17 | 8263 | 42 | 12 | 24 | 6.150 | 384.812 | 6.487 | 0.200 |
| 19 | 11743 | 46 | 12 | 24 | 7.690 | 586.712 | 6.099 | 0.152 |
| 23 | 21943 | 54 | 12 | 24 | 18.774 | 1100.736 | 5.138 | 0.178 |

The observed formulas are stable across all four runs:

- sample count: `2*n+8`;
- Rosenhain X-degree pair: `(n,n-1)` for both maps;
- fixed-field X-degree pair: `(n,n)` for both maps;
- theta quotient field degree: `12`;
- exact map-recovery field degree: `24`.

Map recovery is the dominant cost. Theta reconstruction, base-field descent,
and final Magma verification remain small. The next optimization target is
therefore batched level-2 conversion and dual-isogeny evaluation, not
interpolation or final identity checking.

The degree-13 and degree-23 maps descend directly. In degrees 17 and 19, the
second map requires one target 2-torsion translation to kill its Frobenius
descent cocycle. The general descent engine searches the identity and all
three 2-torsion translations and selects the identity whenever possible.
