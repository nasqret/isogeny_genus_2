# Executable Examples

## Degree 5: a full exact map

For \((a,b)=(7,1)\), let \(e\) satisfy

$$
289e^2-605e+289=0.
$$

The script `census_degree5_family.sage` constructs a squarefree quintic
\(F_e(x)\), the genus-2 curve

$$
C_e:y^2=F_e(x),
$$

the Legendre elliptic curve

$$
E_e:Y^2=t(t-1)(t-e),
$$

and the degree-5 map with

$$
t=x\left(\frac{F_1(x)}{F_2(x)}\right)^2.
$$

The \(Y\)-coordinate multiplier is recovered by exact squarefree
factorization, and the target equation is checked as an identity over
\(\mathbf Q(e)(x)\).

## Degree 7: a primitive benchmark

Kumar's rational curve on \(Y_-(49)\) gives at \(u=1\)

$$
\begin{aligned}
C:\quad y^2={}&(x^3+23x^2+552x+17940)\\
&\cdot\left(x^3-\frac{46}{5}x^2
+\frac{3013}{4}x-\frac{25645}{4}\right).
\end{aligned}
$$

The two elliptic invariants are

$$
j_1=-\frac{20285403817}{279936},\qquad
j_2=-\frac{97967097}{128}.
$$

Compatible rational twists are

$$
\begin{aligned}
E_1&:y^2+xy=x^3-6077163x-5835183183,\\
E_2&:y^2+xy+y=x^3-x^2-15705x+762297.
\end{aligned}
$$

The genus-2 Frobenius polynomial equals the product of the two elliptic
Frobenius polynomials at all 41 good primes \(11\leq p<200\). This is an exact
finite-reduction certificate for the expected split isogeny class. Recovering
the two degree-7 maps remains B008.

## Degrees 20 and 80: exact nonprimitive maps

Starting from the degree-5 map above, the script
`verify_composed_high_degree_maps.sage` applies the exact elliptic doubling
formulas once and twice. It certifies maps

$$
C_e\longrightarrow E_e
$$

of degrees

$$
5\cdot 2^2=20,\qquad 5\cdot 4^2=80.
$$

For each map, SageMath verifies the target equation in the function field and
checks the rational-function degree. These are practical stress tests for the
high-degree engine, but they are nonprimitive.
