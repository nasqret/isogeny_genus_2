# Kumar square-discriminant auxiliary files

These files are the computer-readable auxiliary data accompanying:

> Abhinav Kumar, *Hilbert modular surfaces for square discriminants and
> elliptic subfields of genus 2 function fields*, Res. Math. Sci. 2 (2015),
> arXiv:1412.2849.

The repository vendors the three files needed for each discriminant
`36, 49, 64, 81, 100, 121`:

- `discD.txt`: Hilbert modular surface and symmetric elliptic
  `j`-invariants;
- `igD.txt`: Igusa-Clebsch invariants;
- `univcurveD.txt`: a tautological genus-2 sextic.

They are preserved in their original computer-algebra syntax.  The SageMath
adapter in
`computations/sage/lib/kumar_square_discriminant_families.sage` parses the
source expressions without rewriting the mathematical data.

Source: <https://arxiv.org/abs/1412.2849>
