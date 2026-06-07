# Theory and Invariants

## Primitive elliptic covers

Let $C$ be a smooth genus-2 curve over a field $k$ of characteristic zero,
and let

$$
f:C\longrightarrow E
$$

be a finite map of degree $n$ to an elliptic curve. The map is **maximal** or
**primitive** when it does not factor through a nontrivial elliptic isogeny.
Then the connected kernel of

$$
f_*:\operatorname{Jac}(C)\longrightarrow E
$$

is an elliptic curve $E'$. The induced complementary map
$f':C\to E'$ also has degree $n$, and

$$
E\times E'\longrightarrow \operatorname{Jac}(C)
$$

is an $(n,n)$-isogeny. Its kernel is the graph of an anti-isometry
$E[n]\to E'[n]$ for the Weil pairings. This is the Frey-Kani structure that
the computational pipeline must recover and certify.

## Synthesis from an anti-isometry

Conversely, let $n$ be prime to the characteristic and let
$\psi:E[n]\to E'[n]$ be an anti-isometry. Its graph is maximally isotropic in
$E[n]\times E'[n]$, so the product principal polarization descends to a
principal polarization on

$$
A=(E\times E')/\operatorname{Graph}(\psi).
$$

For the finite-field synthesis used here, both full torsion modules are
rational and the anti-isometry is represented by a matrix in chosen bases.
If the basis pairings are $\zeta_1$ and $\zeta_2$, then a matrix of
determinant $d$ is anti-symplectic exactly when

$$
\zeta_1\zeta_2^d=1.
$$

For prime $n$, each nonzero determinant occurs on exactly
$n(n^2-1)$ matrices in $\operatorname{GL}_2(\mathbf F_n)$.

A strong sufficient irreducibility test is that $E$ and $E'$ are
geometrically nonisogenous. For ordinary finite-field curves this follows
when their Frobenius discriminants define different imaginary quadratic
fields. Then there is no nonzero geometric homomorphism between the factors,
the Frey-Kani anti-isometry is irreducible, and the principally polarized
quotient is geometrically the Jacobian of a smooth genus-2 curve rather than
a product.

## Certifying the splitting kernel

Suppose both maps $f:C\to E$ and $f':C\to E'$ are known. Their pullbacks
define

$$
\Phi:E\times E'\longrightarrow \operatorname{Jac}(C),\qquad
(P,Q)\longmapsto f^*(P-O)+f'^*(Q-O').
$$

At a good reduction of characteristic prime to $n$, choose bases
$(P_1,P_2)$ and $(Q_1,Q_2)$ of the full rational $n$-torsion. Pull the point
divisors back to the genus-2 Jacobian and solve

$$
f^*(P_i-O)+f'^*(\psi(P_i)-O')=0.
$$

This gives a matrix for $\psi:E[n]\to E'[n]$. A complete certificate checks:

1. the matrix has unit determinant modulo $n$;
2. exactly $n^2$ pairs in $E[n]\times E'[n]$ map to zero;
3. the Weil pairings satisfy
   $e_n(P_1,P_2)e_n(\psi(P_1),\psi(P_2))=1$.

Thus the kernel is the graph of an anti-isometry and is maximally isotropic.
Because the characteristic is prime to $n$, the torsion and kernel schemes
are finite etale at good reduction.

## Quotient diagram

The hyperelliptic involution on $C$ and negation on $E$ give a degree-$n$
rational map

$$
\phi:\mathbf P^1_x\longrightarrow\mathbf P^1_t.
$$

Given $\phi=N/D$, the off-diagonal self-fiber begins with

$$
\frac{N(x_1)D(x_2)-N(x_2)D(x_1)}{x_1-x_2}=0.
$$

Passing to

$$
s=x_1+x_2,\qquad p=x_1x_2
$$

removes the transposition symmetry. The normalization and component structure
of this plane curve control the practical reconstruction. One then lifts the
base correspondence through the double covers defining $C$ and $E$ to
obtain the genus-one complementary curve.

Gallese's degree-independent construction uses the non-diagonal component of
$C\times_E C$ and a natural involution. Its quotient has genus one and gives
the complement. This supplies a general existence theorem and an algorithmic
fallback even when the symmetric plane model becomes unwieldy.

## What must be certified

For a primitive degree-$n$ output, a complete certificate contains:

1. smooth models for $C,E,E'$;
2. exact rational maps $f$ and $f'$;
3. function-field identities proving that both maps land on their targets;
4. exact degree computations;
5. maximality or an explicit nonfactorization certificate;
6. the induced $(n,n)$-splitting of $\operatorname{Jac}(C)$;
7. fields of definition and every excluded parameter divisor.

Euler-factor splitting is useful for discovery and twist selection, but by
itself it is not a replacement for the two exact maps.

## Frobenius descent of normalized maps

Let \(K/k\) be finite Galois, let \(C/k\) have hyperelliptic involution
\(\iota\), and let \(E/k\) be elliptic. Suppose a map

$$
f:C_K\longrightarrow E_K
$$

satisfies \(f\circ\iota=[-1]\circ f\), and suppose \(f\) and every conjugate
\(\sigma(f)\) induce the same homomorphism
\(\operatorname{Jac}(C)_K\to E_K\).

:::{admonition} Descent-cocycle theorem
:class: theorem
There is a unique $P_\sigma\in E[2](K)$ with

$$
\sigma(f)=\tau_{P_\sigma}\circ f.
$$

The points $P_\sigma$ form a 1-cocycle. A translated map
$\tau_Q\circ f$, with $Q\in E[2](K)$, descends to $k$ exactly when

$$
P_\sigma=Q-\sigma(Q).
$$

When a correction exists, all corrections form one coset of $E[2](k)$.
:::

:::{admonition} Proof
:class: proof
Maps inducing the same Jacobian homomorphism differ by a unique target
translation. Hyperelliptic equivariance then forces the translating point
to equal its negative, so it lies in \(E[2]\). Conjugating twice gives the
1-cocycle identity. Finally,

$$
\sigma(\tau_Q\circ f)
=\tau_{\sigma(Q)+P_\sigma}\circ f,
$$

which equals \(\tau_Q\circ f\) exactly under the displayed coboundary
equation. Two solutions differ by a Galois-fixed 2-torsion point.
:::

Over \(k=\mathbf F_q\), the algorithm enumerates only the four geometric
2-torsion points. It identifies the unique Frobenius translation, verifies
its norm is zero, solves the four coboundary equations, and checks that the
solution set is a coset of \(E[2](\mathbf F_q)\). The cost is independent of
the cover degree.

The exact aggregate certificate covers both maps in degrees 13, 17, 19, and
23. Six maps descend directly. The second maps in degrees 17 and 19 have
nontrivial cocycles resolved by unique nonrational 2-torsion corrections.

## Primitive versus composed degree

If $f:C\to E$ has degree $n$ and $\alpha:E\to E_1$ is an isogeny of
degree $d$, then

$$
\deg(\alpha\circ f)=nd.
$$

In particular, composition with multiplication by $m$ has degree $nm^2$.
This gives arbitrarily high degrees immediately. Such examples are valuable
for testing algorithms, but they retain the same maximal elliptic subfield and
must be recorded as nonprimitive.

## Primary sources

- [Magaard-Shaska-Voelklein, degree 5](https://arxiv.org/abs/1209.0443)
- [Kumar, square-discriminant Hilbert modular surfaces](https://arxiv.org/abs/1412.2849)
- [Gallese, geometric splitting construction](https://arxiv.org/abs/2412.07414)
