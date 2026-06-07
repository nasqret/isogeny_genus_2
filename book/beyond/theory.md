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
