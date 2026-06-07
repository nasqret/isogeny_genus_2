"""Export descended prime-degree Frey-Kani maps to static Magma code."""

import json
import sys
from pathlib import Path


root = Path.cwd()
degree = int(sys.argv[1])
input_path = (
    root / "results" / f"sage_degree{degree}_descended_maps.json"
)
data = json.loads(input_path.read_text())
assert data["status"] == "verified"
assert len(data["maps"]) == 2
field_order = int(data["base_field"].removeprefix("F_"))


def magma_expression(expression):
    return expression.replace("X", "x")


def magma_map_block(index, map_data):
    x_coordinate = map_data["x_coordinate"]
    y_coefficient = map_data["y_coefficient"]
    a4 = map_data["target_a4"]
    a6 = map_data["target_a6"]
    eigenform = magma_expression(map_data["pullback_eigenform"])
    return f"""
E{index} := EllipticCurve([Fq | 0, 0, 0, {a4}, {a6}]);
X{index} := R!(
    ({magma_expression(x_coordinate["numerator"])})
    /
    ({magma_expression(x_coordinate["denominator"])})
);
Y{index}_multiplier := R!(
    ({magma_expression(y_coefficient["numerator"])})
    /
    ({magma_expression(y_coefficient["denominator"])})
);
assert R!source_polynomial*Y{index}_multiplier^2 eq
    X{index}^3 + ({a4})*X{index} + ({a6});
assert Derivative(X{index})/(2*Y{index}_multiplier) eq {eigenform};
X{index}K :=
    Evaluate(Numerator(X{index}), t)/Evaluate(Denominator(X{index}), t);
Y{index}MultiplierK :=
    Evaluate(Numerator(Y{index}_multiplier), t)
    / Evaluate(Denominator(Y{index}_multiplier), t);
Y{index}K := y*Y{index}MultiplierK;
assert Y{index}K^2 eq X{index}K^3 + ({a4})*X{index}K + ({a6});
map{index} := map< C -> E{index} | [X{index}K, Y{index}K, K!1] >;
degree{index} := Degree(map{index});
assert degree{index} eq {degree};
"""


blocks = [
    magma_map_block(index, map_data)
    for index, map_data in enumerate(data["maps"], start=1)
]
source_polynomial = magma_expression(data["source_curve"])
workstream = data["workstream"]
output = f"""/*
Static independent verification of both descended degree-{degree} maps.
Generated from {input_path.relative_to(root)}.
*/

Fq := GF({field_order});
P<x> := PolynomialRing(Fq);
R := FieldOfFractions(P);

source_polynomial := {source_polynomial};
assert IsSquarefree(source_polynomial);
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;
{"".join(blocks)}
print "{workstream}_DEGREE{degree}_MAPS_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
print "eigenform_1", {magma_expression(data["maps"][0]["pullback_eigenform"])};
print "eigenform_2", {magma_expression(data["maps"][1]["pullback_eigenform"])};
quit;
"""
output_path = (
    root / "computations" / "magma" / f"verify_degree{degree}_maps.m"
)
output_path.write_text(output)
print(f"Wrote {output_path}")
