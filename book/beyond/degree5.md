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

where $q_{a,b}$ is quadratic. Its discriminant factors as

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

Thus the generic branch field is the square class of $aG(a,b)$.

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
divisors. Since a plane quartic has arithmetic genus $3$, these three nodes
force generic geometric genus zero.

## Normalization conic

Projection from $P_0$ gives

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
$K$ is reduced first to a conic-solubility problem over $K$, followed by
one genus-one normalization and exact map reconstruction.

## Generic branch-field point

Let $c$ be a root of

$$
(2a+1)c^2+(2b-2ab-2a-a^2)c+b^2+2ab=0.
$$

The diagonal critical pair $(c,c)$ lies on the divided self-fiber. Projecting
it from $P_0$ gives a point on the normalization conic over
$\mathbf Q(a,b,c)$. With

$$
\Delta_0=2a^2+3a+4b,
$$

the point is

$$
m_0=\frac{(a+2b)c-2b(2a+b)}{\Delta_0}
$$

and

$$
y_0=
\frac{
(a^3-2a^2b+a^2-ab-2b^2)c
+2a^2b-3ab^2-2b^3
}{\Delta_0}.
$$

Exact reduction modulo the critical quadratic proves

$$
y_0^2=Lm_0^2+Mm_0+N.
$$

Therefore the generic normalization conic splits over the branch field.

## Practical algorithm

For a rational pair $(a,b)$:

1. reject the explicit degeneracy divisors;
2. compute $q_{a,b}(e)$ and the branch field $K$;
3. construct $E_e:y^2=t(t-1)(t-e)$;
4. take the squarefree part of
   \[
   \phi_{\rm num}
   (\phi_{\rm num}-\phi_{\rm den})
   (\phi_{\rm num}-e\phi_{\rm den});
   \]
5. certify the resulting genus-2 curve and degree-5 map;
6. test the normalization conic over $\mathbf Q$ and $K$;
7. use the canonical point $(m_0,y_0)$ to parametrize it;
8. construct the orientation double cover and its complementary invariant.

All eight steps are implemented.

## Complementary invariant

The conic parameterization is

$$
\begin{aligned}
m(t)&=m_0+\frac{(2Lm_0+M)-2y_0t}{t^2-L},\\
y(t)&=y_0+t(m(t)-m_0).
\end{aligned}
$$

Recover $s=t_1+t_2$, $p=t_1t_2$, and the common value
$z=\phi(t_1)=\phi(t_2)$. If $e=\phi(c)$, the orientation double cover has
square class

$$
z(z-1)(z-e)(s^2-4p).
$$

After square reduction this is a quartic $q_4(t)$. Writing

$$
I=12a_4a_0-3a_3a_1+a_2^2
$$

for its binary-quartic invariant gives the generic exact formula

$$
j'=\frac{256I^3}{\operatorname{disc}(q_4)}
\in\mathbf Q(a,b,c).
$$

In general $j'$ is quadratic over $\mathbf Q(a,b)$; it does not always
descend to the rational parameter field.

## Current census

Ten irreducible rational specializations were constructed exactly. All ten
normalization conics are insoluble over $\mathbf Q$ and soluble over their
branch quadratic fields. The explicit point above upgrades the observed
branch-field splitting to a generic theorem.

For $(a,b)=(7,1)$,

$$
289e^2-605e+289=0,
$$

so $K=\mathbf Q(\sqrt{21})$. The conic is

$$
y^2=3235m^2+800m+15.
$$

SageMath detects a rational obstruction at $13$. The canonical branch-field
point is

$$
(m_0,y_0)=
\left(\frac{3c-10}{41},\frac{95c+25}{41}\right),
$$

and the complementary invariant is

$$
j'=-\frac{250888806400}{56807829}.
$$
