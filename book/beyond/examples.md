# Executable Examples

## Degree 5: a full exact map

For $(a,b)=(7,1)$, let $e$ satisfy

$$
289e^2-605e+289=0.
$$

The script `census_degree5_family.sage` constructs a squarefree quintic
$F_e(x)$, the genus-2 curve

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

The $Y$-coordinate multiplier is recovered by exact squarefree
factorization, and the target equation is checked as an identity over
$\mathbf Q(e)(x)$.

## Degree 7: a primitive benchmark

Kumar's rational curve on $Y_-(49)$ gives at $u=1$

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
Frobenius polynomials at all 41 good primes $11\leq p<200$. The two maps
have now also been recovered exactly.

For the first map, put

$$
\begin{aligned}
N_1={}&x^7+\frac{2415}{2}x^5+\frac{7245}{2}x^4
+\frac{41306965}{192}x^3+\frac{393877001}{96}x^2\\
&-\frac{90651235955}{768}x
+\frac{1179635972075}{768},\\
D_1={}&x^3-\frac{46}{5}x^2+\frac{3013}{4}x-\frac{25645}{4}.
\end{aligned}
$$

Then

$$
X_1=\frac{576N_1}{2401D_1},
\qquad
Y_1=\frac{yX_1'}{2(49/12)}.
$$

SageMath verifies

$$
F(x)(X_1')^2
=4\left(\frac{49}{12}\right)^2
\left(X_1^3-7876003275X_1-272222678576250\right).
$$

The missing $x^6$ coefficient in $N_1$ gives
$\operatorname{Tr}(x)=0$, so the complementary eigenform is
$x\,dx/y$. Put

$$
\begin{aligned}
N_2={}&\frac{10465}{4}x^7+\frac{197225}{8}x^6
+\frac{164727955}{64}x^5+\frac{1305770375}{64}x^4\\
&+\frac{36305600625}{64}x^3
-\frac{1306013384375}{64}x^2
-\frac{232046932796875}{16},\\
D_2={}&(x^3+23x^2+552x+17940)
\left(x^2-\frac{115}{24}x+\frac{7475}{24}\right)^2.
\end{aligned}
$$

The second map is

$$
X_2=\frac{N_2}{D_2},
\qquad
Y_2=\frac{yX_2'}{2(-49/60)x},
$$

and satisfies

$$
F(x)(X_2')^2
=4\left(\frac{49}{60}\right)^2x^2
\left(X_2^3-20353275X_2+35382561750\right).
$$

The positive point at infinity maps to

$$
\left(\frac{10465}{4},-\frac{51175}{8}\right),
$$

which is $-7(29,-590)$ on the original second elliptic model. Remote
Magma independently constructs both morphisms and returns degree $7$ for
each. Since $7$ is prime, both maps are primitive.

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
