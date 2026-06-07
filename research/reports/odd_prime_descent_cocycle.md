# Odd-Prime Descent Cocycle

## Setting

Let \(K/k\) be a finite Galois extension of fields of characteristic not two,
let \(C/k\) be a genus-2 curve with hyperelliptic involution \(\iota\), and
let \(E/k\) be an elliptic curve. Suppose

\[
f:C_K\longrightarrow E_K
\]

is a nonconstant map satisfying \(f\circ\iota=[-1]\circ f\). Assume that for
every \(\sigma\in\operatorname{Gal}(K/k)\), the maps \(f\) and \(\sigma(f)\)
induce the same homomorphism \(\operatorname{Jac}(C)_K\to E_K\). This is the
normalization supplied by the Frey-Kani factor projection.

## Theorem

For every \(\sigma\) there is a unique point \(P_\sigma\in E[2](K)\) such
that

\[
\sigma(f)=\tau_{P_\sigma}\circ f.
\]

The points \(P_\sigma\) form a 1-cocycle:

\[
P_{\sigma\tau}=P_\sigma+\sigma(P_\tau).
\]

A translation \(g=\tau_Q\circ f\), with \(Q\in E[2](K)\), is defined over
\(k\) exactly when

\[
P_\sigma=Q-\sigma(Q)
\]

for every \(\sigma\). If one correction exists, the full correction set is a
coset of \(E[2](k)\).

## Proof

Two maps from \(C\) to \(E\) inducing the same Jacobian homomorphism differ
by a unique target translation, so
\(\sigma(f)=\tau_{P_\sigma}\circ f\) for a unique \(P_\sigma\in E(K)\).
Applying the hyperelliptic equivariance to both sides gives
\(\tau_{P_\sigma}\circ[-1]=[-1]\circ\tau_{P_\sigma}\), hence
\(P_\sigma=-P_\sigma\) and \(P_\sigma\in E[2]\).

Applying \(\sigma\) to
\(\tau(f)=\tau_{P_\tau}\circ f\) proves the cocycle identity. Finally,

\[
\sigma(\tau_Q\circ f)
=\tau_{\sigma(Q)+P_\sigma}\circ f,
\]

which equals \(\tau_Q\circ f\) precisely when
\(P_\sigma=Q-\sigma(Q)\). Two solutions differ by a Galois-fixed 2-torsion
point, and adding any element of \(E[2](k)\) to one solution gives another.

For a finite field \(k=\mathbf F_q\), \(K=\mathbf F_{q^d}\), and Frobenius
\(F\), the cocycle is determined by one point \(P=P_F\). It must satisfy

\[
P+F(P)+\cdots+F^{d-1}(P)=0.
\]

## Algorithm

For each transported Frey-Kani map:

1. compute the coefficientwise Frobenius conjugate \(F(f)\);
2. enumerate the four points of \(E[2](K)\);
3. find the unique \(P\) with \(F(f)=\tau_P\circ f\);
4. verify the Frobenius norm of \(P\) is zero;
5. solve \(P=Q-F(Q)\) over the same four points;
6. verify the solution set is one coset of \(E[2](k)\);
7. choose the identity correction when available, otherwise the first
   deterministic solution;
8. verify every corrected coefficient is Frobenius fixed;
9. descend coefficients and recheck the elliptic identity, degree, and
   differential eigendirection over \(k\).

The search is constant size: exactly four cocycle comparisons and four
coboundary tests, independent of the cover degree.

## Certified cases

The strengthened descent engine certifies both maps in degrees 13, 17, 19,
and 23. Among the eight maps, six descend directly. The two nontrivial
cocycles occur for the second factors in degrees 17 and 19.

The number of valid corrections varies with rational target 2-torsion:

| degree | factor | Frobenius on \(E[2]\) | cocycle | corrections |
|---:|---:|---|---:|---|
| 13 | 0 | \([0,3,1,2]\) | 0 | \([0]\) |
| 13 | 1 | \([0,1,3,2]\) | 0 | \([0,1]\) |
| 17 | 0 | \([0,1,2,3]\) | 0 | \([0,1,2,3]\) |
| 17 | 1 | \([0,2,3,1]\) | 3 | \([1]\) |
| 19 | 0 | \([0,1,3,2]\) | 0 | \([0,1]\) |
| 19 | 1 | \([0,3,1,2]\) | 1 | \([3]\) |
| 23 | 0 | \([0,2,3,1]\) | 0 | \([0]\) |
| 23 | 1 | \([0,1,3,2]\) | 0 | \([0,1]\) |

Here index 0 is the identity of \(E[2]\). Each row verifies the unique
Frobenius translation, the norm-zero condition, the selected coboundary
equation, and the correction-coset identity.
