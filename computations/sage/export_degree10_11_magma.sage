"""Export the exact degree-10 and degree-11 Sage maps as static Magma files."""

import json
from pathlib import Path


root = Path.cwd()
benchmarks = {
    10: {
        "target_coefficients": [
            (-806858835275202528, 279253187015570073126859402),
            (1238639330931912, -306965070990450656294238),
        ],
    },
    11: {
        "target_coefficients": [
            (3368911697438868, -17302825474991342749008),
            (-2580223408812, -797634783259688808),
        ],
    },
}


def magma_map_block(index, map_data, target_coefficients):
    a4, a6 = target_coefficients
    x_coordinate = map_data["x_coordinate"]
    return f"""
// Map {index}: {map_data["label"]}.
E{index} := EllipticCurve([Q | 0, 0, 0, {a4}, {a6}]);
c{index} := {map_data["differential_scale"]};
h{index} := P!({map_data["eigenform"]});
a{index} := F!({x_coordinate["rational_part"]});
b{index} := F!({x_coordinate["y_part"]});
Y{index}_rational := F!(
    (
        source_polynomial*Derivative(b{index})
        + b{index}*Derivative(source_polynomial)/2
    )
    /
    (2*c{index}*h{index})
);
Y{index}_y_part := F!(Derivative(a{index})/(2*c{index}*h{index}));

a{index}K :=
    Evaluate(Numerator(a{index}), t)/Evaluate(Denominator(a{index}), t);
b{index}K :=
    Evaluate(Numerator(b{index}), t)/Evaluate(Denominator(b{index}), t);
Y{index}_rational_K :=
    Evaluate(Numerator(Y{index}_rational), t)
    / Evaluate(Denominator(Y{index}_rational), t);
Y{index}_y_part_K :=
    Evaluate(Numerator(Y{index}_y_part), t)
    / Evaluate(Denominator(Y{index}_y_part), t);
X{index}K := a{index}K+y*b{index}K;
Y{index}K := Y{index}_rational_K+y*Y{index}_y_part_K;
assert Y{index}K^2 eq X{index}K^3 + ({a4})*X{index}K + ({a6});
map{index} := map< C -> E{index} | [X{index}K, Y{index}K, K!1] >;
degree{index} := Degree(map{index});
assert degree{index} eq {map_data["cover_degree"]};
"""


for degree, benchmark in benchmarks.items():
    result_path = root / "results" / f"sage_degree{degree}_recovery.json"
    data = json.loads(result_path.read_text())
    assert data["verified"]
    assert len(data["maps"]) == 2

    source = data["specialization"]["normalized_source_polynomial"]
    blocks = [
        magma_map_block(index, map_data, coefficients)
        for index, (map_data, coefficients) in enumerate(
            zip(data["maps"], benchmark["target_coefficients"]),
            start=1,
        )
    ]
    output = f"""Q := Rationals();
P<x> := PolynomialRing(Q);
F := FieldOfFractions(P);

source_polynomial := P!({source});
assert IsSquarefree(source_polynomial);
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;
{"".join(blocks)}
print "B004_B010_DEGREE{degree}_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
quit;
"""
    output_path = (
        root / "computations" / "magma"
        / f"verify_degree{degree}_maps.m"
    )
    output_path.write_text(output)
    print(f"Wrote {output_path}")
