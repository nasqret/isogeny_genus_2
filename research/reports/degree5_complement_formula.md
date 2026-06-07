# Generic Degree-5 Complement

## Result

Let

\[
\phi(x)=x\left(\frac{F_1(x)}{F_2(x)}\right)^2
\]

be the two-parameter degree-5 map, and let \(c\) satisfy

\[
(2a+1)c^2+(2b-2ab-2a-a^2)c+b^2+2ab=0.
\]

The normalization conic of the off-diagonal self-fiber splits over
\(\mathbf Q(a,b,c)\). This is now a theorem with exact SageMath and Magma
certificates, not a census observation.

Set

\[
\Delta_0=2a^2+3a+4b.
\]

The point induced by the diagonal critical pair \((c,c)\) is

\[
m_0=
\frac{(a+2b)c-2b(2a+b)}{\Delta_0}
\]

and

\[
y_0=
\frac{
(a^3-2a^2b+a^2-ab-2b^2)c
+2a^2b-3ab^2-2b^3
}{\Delta_0}.
\]

Direct reduction modulo the critical quadratic proves

\[
y_0^2=Lm_0^2+Mm_0+N,
\]

where

\[
\begin{aligned}
L&=a^4+2a^3+2a^2b+a^2+b^2,\\
M&=2b(a+b)(a^2+b),\\
N&=b^3(2a+b).
\end{aligned}
\]

## Complement algorithm

Parameterize the conic by

\[
\begin{aligned}
m(t)&=m_0+\frac{(2Lm_0+M)-2y_0t}{t^2-L},\\
y(t)&=y_0+t(m(t)-m_0).
\end{aligned}
\]

Projection from the node over zero gives \(s=t_1+t_2\) and \(p=t_1t_2\).
The common base coordinate \(z=\phi(t_1)=\phi(t_2)\) is recovered from the
constant remainder coefficient of

\[
N(X)-zD(X)\pmod{X^2-sX+p}.
\]

If \(e=\phi(c)\), the orientation double cover has square class

\[
z(z-1)(z-e)(s^2-4p).
\]

Reducing the four factors independently modulo squares produces a squarefree
quartic \(q_4(t)\). For

\[
q_4(t)=a_4t^4+a_3t^3+a_2t^2+a_1t+a_0,
\]

put

\[
I=12a_4a_0-3a_3a_1+a_2^2.
\]

Then the complementary invariant is the exact generic formula

\[
j'=\frac{256I^3}{\operatorname{disc}(q_4)}
\in \mathbf Q(a,b,c).
\]

The implementation is
[`degree5_complement.sage`](../../computations/sage/lib/degree5_complement.sage).
It certifies the conic parameterization, pair curve, common base coordinate,
four square classes, quartic degree, and \(j\)-invariant.

## Arithmetic behavior

The generic \(j'\) is quadratic over \(\mathbf Q(a,b)\); it need not descend
to the rational parameter field. The exact census contains both behaviors:
six tested rows have rational \(j'\), while four have quadratic \(j'\).

For the article specialization \((a,b)=(7,1)\), the generic construction
gives

\[
j'=-\frac{250888806400}{56807829},
\]

agreeing with the independent base-field Magma reconstruction.

For \((a,b)=(1,2)\), one obtains a genuine quadratic example:

\[
j'=\frac{1902924663}{6545000}c
-\frac{3625833671}{8181250},
\qquad
3c^2-3c+8=0.
\]

Its minimal polynomial is

\[
J^2+\frac{19492046053}{32725000}J
+\frac{8560545186167023}{29218750000}.
\]

## Evidence

- `computations/sage/verify_degree5_family_structure.sage`
- `computations/sage/census_degree5_family.sage`
- `computations/sage/verify_degree5_complement.sage`
- `computations/magma/verify_degree5_conic_generic.m`
- `computations/magma/derive_degree5_complement_j_generic.m`
- `results/sage_degree5_family_structure.json`
- `results/sage_degree5_family_census.json`
- `results/sage_degree5_complement.json`
