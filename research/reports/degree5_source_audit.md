# Degree-5 Source and Formula Audit

## Result

The degree-5 example is not correct as stated.

1. The printed quartic has four incorrect coefficients.
2. The corrected quartic has geometric genus zero, but it has a nonsingular
   point over the stated quadratic base field.
3. The complementary computation therefore does not require a further field
   extension.
4. Parametrizing over the base field and completing the Magma elimination
   gives
   \[
   j(E')=-\frac{250888806400}{56807829}.
   \]

The executable evidence is
[`verify_degree5_basic.sage`](../../computations/sage/verify_degree5_basic.sage)
and
[`verify_degree5_over_base_field.m`](../../computations/magma/verify_degree5_over_base_field.m).

## Citation mismatch

The article cites Tanush Shaska, *Curves of genus 2 with \((N,N)\)
decomposable Jacobians*, J. Symbolic Comput. 31 (2001), for the
two-parameter presentation used in the example and for a comparison formula.
The degree-5 section of that paper treats a different special presentation;
it does not contain the displayed
\[
\phi(x)=x\left(\frac{F_1(x)}{F_2(x)}\right)^2
\]
with parameters \(a,b\).

That two-parameter normal form appears in Kay Magaard, Tanush Shaska, and
Helmut Voelklein, *Genus 2 curves that admit a degree 5 map to an elliptic
curve*, Forum Math. 21 (2009), arXiv
[`1209.0443`](https://arxiv.org/abs/1209.0443). Its Theorem 1 gives
\[
\begin{aligned}
F_1(x)&=x^2+(2a+2b+a^2)x+2ab+b^2,\\
F_2(x)&=(2a+1)x^2+(a^2+2ab+2b)x+b^2.
\end{aligned}
\]
This later source computes the given elliptic subcover but does not display a
generic formula for the complementary \(j\)-invariant that can be specialized
to the article's value. Consequently, the numerical complementary invariant
is independently confirmed, but the article's specific comparison to
"the formulas in Shaska" is not reproducible from the cited source.

The present repository now supplies the missing generic construction
independently. See
[`degree5_complement_formula.md`](degree5_complement_formula.md) and
[`degree5_complement.sage`](../../computations/sage/lib/degree5_complement.sage).
