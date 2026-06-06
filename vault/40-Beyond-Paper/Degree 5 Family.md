# Degree 5 Family

## Generic result

The symmetric off-diagonal self-fiber is a plane quartic with three generic
ordinary nodes. Projection from the node above zero gives

`y^2=L*m^2+M*m+N`,

where

- `L=a^4+2*a^3+2*a^2*b+a^2+b^2`,
- `M=2*b*(a+b)*(a^2+b)`,
- `N=b^3*(2*a+b)`.

## Census

Ten exact rational parameter pairs were tested:

- 10 primitive degree-5 maps constructed over their branch fields;
- 0 normalization conics soluble over `Q`;
- 10 normalization conics soluble over the branch quadratic field.

This is a conjectural pattern until the generic Brauer class is evaluated.

## Evidence

- `computations/sage/verify_degree5_family_structure.sage`
- `computations/sage/census_degree5_family.sage`
- `results/sage_degree5_family_structure.json`
- `results/sage_degree5_family_census.json`
