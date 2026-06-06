# The Generic Degree-5 Family

## Normal form

The two-parameter degree-5 map is

$$
\phi(x)=x\left(\frac{F_1(x)}{F_2(x)}\right)^2,
$$

where

$$
\begin{aligned}
F_1(x)&=x^2+(2a+2b+a^2)x+2ab+b^2,\\
F_2(x)&=(2a+1)x^2+(a^2+2ab+2b)x+b^2,\\
F_3(x)&=x^2-(a^2-2b)x+b^2
\end{aligned}
$$

and the exact identity

$$
\phi(x)-1=(x-1)\left(\frac{F_3(x)}{F_2(x)}\right)^2
$$

holds.

## Branch field

The critical-value resultant has the form

$$
256a^{12}b^4(a+b+1)^4e^2(e-1)^2q_{a,b}(e),
$$

where \(q_{a,b}\) is quadratic. Its discriminant factors as

$$
aH(a,b)^2G(a,b)^3,
$$

with

$$
\begin{aligned}
H(a,b)&=-a^3+2ab+2b^2+2b,\\
G(a,b)&=a^3+4a^2b+4ab^2+4a^2\\
&\quad-12ab-16b^2+4a-16b.
\end{aligned}
$$

Thus the generic branch field is the square class of \(aG(a,b)\).

## Three-node theorem

The symmetric off-diagonal self-fiber is a plane quartic. It has the three
generic nodes

$$
\begin{aligned}
P_0&=\left(-(a^2+2a+2b),\,2ab+b^2\right),\\
P_1&=\left(a^2-2b,\,b^2\right),\\
P_\infty&=\left(
-\frac{a^2+2ab+2b}{2a+1},
\frac{b^2}{2a+1}
\right).
\end{aligned}
$$

Their tangent-cone discriminants are nonzero away from explicit parameter
divisors. Since a plane quartic has arithmetic genus \(3\), these three nodes
force generic geometric genus zero.

## Normalization conic

Projection from \(P_0\) gives

$$
y^2=Lm^2+Mm+N,
$$

where

$$
\begin{aligned}
L&=a^4+2a^3+2a^2b+a^2+b^2,\\
M&=2b(a+b)(a^2+b),\\
N&=b^3(2a+b).
\end{aligned}
$$

The quadratic discriminant is

$$
M^2-4LN=-4b^2a^3H(a,b).
$$

This is the central degree-5 reduction: finding the complement over a field
\(K\) is reduced first to a conic-solubility problem over \(K\), followed by
one genus-one normalization and exact map reconstruction.

## Practical algorithm

For a rational pair \((a,b)\):

1. reject the explicit degeneracy divisors;
2. compute \(q_{a,b}(e)\) and the branch field \(K\);
3. construct \(E_e:y^2=t(t-1)(t-e)\);
4. take the squarefree part of
   \[
   \phi_{\rm num}
   (\phi_{\rm num}-\phi_{\rm den})
   (\phi_{\rm num}-e\phi_{\rm den});
   \]
5. certify the resulting genus-2 curve and degree-5 map;
6. test the normalization conic over \(\mathbf Q\) and \(K\);
7. if soluble, parametrize it and construct \(E'\);
8. interpolate the complementary \(j\)-invariant and verify it symbolically.

Steps 1-6 are implemented. Steps 7-8 are B002-B003.

## Current census

Ten irreducible rational specializations were constructed exactly. All ten
normalization conics are insoluble over \(\mathbf Q\) and soluble over their
branch quadratic fields. This is evidence for a generic splitting phenomenon,
not yet a theorem.

For \((a,b)=(7,1)\),

$$
289e^2-605e+289=0,
$$

so \(K=\mathbf Q(\sqrt{21})\). The conic is

$$
y^2=3235m^2+800m+15.
$$

SageMath detects a rational obstruction at \(13\) and a point over \(K\).
