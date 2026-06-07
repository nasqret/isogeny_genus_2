"""
Import Kumar's square-discriminant Hilbert modular families.

The upstream auxiliary files use a small mixture of Macaulay/Maxima-like
syntax.  This adapter keeps those files immutable and exposes exact SageMath
objects for degrees 6 through 11:

* the double-cover equation z^2 = D_n(r,s);
* the Igusa-Clebsch tuple;
* the quadratic polynomial with roots j_1 and j_2;
* specialized tautological genus-2 sextics.

The individual j-invariants need not lie in Q(r,s).  Their sum and product
do, and adjoining a root of the quadratic is exactly the Hilbert modular
double cover described in Kumar's paper.
"""

import hashlib
import re
from functools import lru_cache
from pathlib import Path


KUMAR_DEGREES = tuple(range(6, 12))
KUMAR_DISCRIMINANTS = {
    degree: degree^2
    for degree in KUMAR_DEGREES
}


def _kumar_data_directory():
    return (
        Path.cwd()
        / "sources"
        / "upstream"
        / "KumarSquareDiscriminants"
    )


def _validate_degree(degree):
    degree = ZZ(degree)
    if degree not in KUMAR_DEGREES:
        raise ValueError("Kumar importer supports degrees 6 through 11")
    return degree


def _data_path(kind, degree):
    degree = _validate_degree(degree)
    path = (
        _kumar_data_directory()
        / f"{kind}{KUMAR_DISCRIMINANTS[degree]}.txt"
    )
    if not path.exists():
        raise FileNotFoundError(path)
    return path


@lru_cache(maxsize=None)
def _data_text(kind, degree):
    return _data_path(kind, degree).read_text(encoding="utf-8")


def _sage_expression(text):
    expression = text.strip()
    while expression.endswith(";"):
        expression = expression[:-1].rstrip()
    expression = " ".join(expression.split())
    return expression.replace("^", "**")


def _evaluate_expression(text, locals_dictionary):
    return sage_eval(
        _sage_expression(text),
        locals=locals_dictionary,
        preparse=True,
    )


def _evaluate_arithmetic_expression(text, locals_dictionary):
    """
    Evaluate +,-,*,/,^ expressions without constructing a Python AST.

    Kumar's degree-11 coefficients are several megabytes long.  Python's
    compiler rejects their flat sums with a recursion-depth error, so this
    iterative shunting-yard evaluator is used for those assignments.
    """
    expression = _sage_expression(text).replace("**", "^")
    token_pattern = re.compile(r"\d+|[A-Za-z_]\w*|[()+\-*/^]")
    tokens = token_pattern.findall(expression)
    compact = re.sub(r"\s+", "", expression)
    if "".join(tokens) != compact:
        raise ValueError("unsupported token in arithmetic expression")

    precedence = {
        "+": 1,
        "-": 1,
        "*": 2,
        "/": 2,
        "u+": 3,
        "u-": 3,
        "^": 4,
    }
    right_associative = {"u+", "u-", "^"}
    output = []
    operators = []
    previous_kind = "start"

    for token in tokens:
        if token.isdigit():
            output.append(ZZ(token))
            previous_kind = "value"
            continue
        if re.fullmatch(r"[A-Za-z_]\w*", token):
            if token not in locals_dictionary:
                raise ValueError(f"unknown variable {token}")
            output.append(locals_dictionary[token])
            previous_kind = "value"
            continue
        if token == "(":
            operators.append(token)
            previous_kind = "left_parenthesis"
            continue
        if token == ")":
            while operators and operators[-1] != "(":
                output.append(operators.pop())
            if not operators:
                raise ValueError("unmatched right parenthesis")
            operators.pop()
            previous_kind = "value"
            continue

        operator = token
        if (
            operator in ("+", "-")
            and previous_kind in (
                "start",
                "operator",
                "left_parenthesis",
            )
        ):
            operator = f"u{operator}"
        while operators and operators[-1] != "(":
            top = operators[-1]
            should_pop = (
                precedence[top] > precedence[operator]
                or (
                    precedence[top] == precedence[operator]
                    and operator not in right_associative
                )
            )
            if not should_pop:
                break
            output.append(operators.pop())
        operators.append(operator)
        previous_kind = "operator"

    while operators:
        operator = operators.pop()
        if operator == "(":
            raise ValueError("unmatched left parenthesis")
        output.append(operator)

    values = []
    for token in output:
        if token not in precedence:
            values.append(token)
            continue
        if token in ("u+", "u-"):
            if not values:
                raise ValueError("missing unary operand")
            value = values.pop()
            values.append(value if token == "u+" else -value)
            continue
        if len(values) < 2:
            raise ValueError("missing binary operand")
        right = values.pop()
        left = values.pop()
        if token == "+":
            values.append(left+right)
        elif token == "-":
            values.append(left-right)
        elif token == "*":
            values.append(left*right)
        elif token == "/":
            values.append(left/right)
        elif token == "^":
            values.append(left^ZZ(right))
    if len(values) != 1:
        raise ValueError("arithmetic expression did not reduce to one value")
    return values[0]


def _marker_match(text, marker_pattern):
    match = re.search(marker_pattern, text, flags=re.MULTILINE)
    if match is None:
        raise ValueError(f"missing source marker: {marker_pattern}")
    return match


def _marked_expression(text, start_pattern, end_pattern=None):
    start = _marker_match(text, start_pattern).end()
    tail = text[start:]
    if end_pattern is None:
        end = len(tail)
    else:
        end_match = re.search(
            end_pattern,
            tail,
            flags=re.MULTILINE,
        )
        if end_match is None:
            raise ValueError(f"missing end marker: {end_pattern}")
        end = end_match.start()
    return tail[:end].strip()


def _semicolon_assignment(text, name):
    marker = _marker_match(
        text,
        rf"^\s*{re.escape(name)}\s*(?::=|=)",
    )
    end = text.find(";", marker.end())
    if end < 0:
        raise ValueError(f"unterminated assignment for {name}")
    return text[marker.end():end].strip()


@lru_cache(maxsize=None)
def kumar_parameter_field():
    parameter_ring = PolynomialRing(QQ, names=("r", "s"))
    r, s = parameter_ring.gens()
    return parameter_ring.fraction_field(), r, s


@lru_cache(maxsize=None)
def kumar_surface_rhs(degree):
    """Return D_n(r,s) in Q(r,s), where Y_-(n^2) has z^2=D_n."""
    degree = _validate_degree(degree)
    field, r, s = kumar_parameter_field()
    text = _data_text("disc", degree)
    expression = _marked_expression(
        text,
        r"^z\^2\s*=",
        r"^\s*$",
    )
    expression = expression.split(";", 1)[0]
    return field(_evaluate_expression(
        expression,
        {"r": r, "s": s},
    ))


@lru_cache(maxsize=None)
def kumar_j_symmetric_functions(degree):
    """Return (j_1+j_2, j_1*j_2) in Q(r,s)."""
    degree = _validate_degree(degree)
    field, r, s = kumar_parameter_field()
    text = _data_text("disc", degree)
    j_sum_text = _marked_expression(
        text,
        r"^j1\s*\+\s*j2\s*=",
        r"^j1\s*\*\s*j2\s*=",
    )
    j_product_text = _marked_expression(
        text,
        r"^j1\s*\*\s*j2\s*=",
        r"^-{5,}",
    )
    local_variables = {"r": r, "s": s}
    return (
        field(_evaluate_expression(j_sum_text, local_variables)),
        field(_evaluate_expression(j_product_text, local_variables)),
    )


@lru_cache(maxsize=None)
def kumar_j_polynomial(degree):
    """Return J^2-(j_1+j_2)J+j_1*j_2 over Q(r,s)."""
    field, _, _ = kumar_parameter_field()
    polynomial_ring = PolynomialRing(field, "J")
    J = polynomial_ring.gen()
    j_sum, j_product = kumar_j_symmetric_functions(degree)
    return J^2-j_sum*J+j_product


@lru_cache(maxsize=None)
def kumar_igusa_clebsch_invariants(degree):
    """Return Kumar's exact [I2,I4,I6,I10] tuple over Q(r,s)."""
    degree = _validate_degree(degree)
    field, r, s = kumar_parameter_field()
    text = _data_text("ig", degree)
    local_variables = {"r": r, "s": s}
    values = {}
    for name in ("A1", "A", "B1", "B", "B2"):
        values[name] = field(_evaluate_expression(
            _semicolon_assignment(text, name),
            local_variables,
        ))
        local_variables[name] = values[name]
    A1 = values["A1"]
    A = values["A"]
    B1 = values["B1"]
    B = values["B"]
    B2 = values["B2"]
    return (
        -24*B1/A1,
        -12*A,
        96*(A/A1)*B1-36*B,
        -4*A1*B2,
    )


def _specialization_field(surface_value, z_value=None, z_sign=1):
    surface_value = QQ(surface_value)
    z_sign = ZZ(z_sign)
    if z_sign not in (-1, 1):
        raise ValueError("z_sign must be 1 or -1")

    if z_value is not None:
        z_value = QQ(z_value)
        if z_value^2 != surface_value:
            raise ValueError("z_value does not satisfy the surface equation")
        return QQ, z_value

    if surface_value.is_square():
        return QQ, QQ(z_sign*surface_value.sqrt())

    polynomial_ring = PolynomialRing(QQ, "w")
    w = polynomial_ring.gen()
    field = NumberField(w^2-surface_value, "z")
    return field, z_sign*field.gen()


def _specialized_universal_sextic(
    degree,
    coefficient_field,
    r_value,
    s_value,
    z_value,
):
    degree = _validate_degree(degree)
    polynomial_ring = PolynomialRing(coefficient_field, "T")
    T = polynomial_ring.gen()
    local_variables = {
        "r": coefficient_field(r_value),
        "s": coefficient_field(s_value),
        "z": coefficient_field(z_value),
        "T": T,
    }
    text = _data_text("univcurve", degree)

    if degree == 11:
        coefficients = {
            index: polynomial_ring.base_ring()(
                _evaluate_arithmetic_expression(
                    _semicolon_assignment(text, f"a{index}"),
                    local_variables,
                )
            )
            for index in range(6)
        }
        sextic = T^6+sum(
            coefficients[index]*T^index
            for index in range(6)
        )
    else:
        sextic = polynomial_ring(_evaluate_expression(
            text,
            local_variables,
        ))

    if sextic.degree() != 6 or sextic[6] != 1:
        raise ValueError("upstream tautological curve is not monic sextic")
    return sextic


def specialize_kumar_family(
    degree,
    r_value,
    s_value,
    z_value=None,
    z_sign=1,
    include_curve=True,
):
    """
    Specialize Y_-(n^2) at an exact rational (r,s)-point.

    If the surface value is nonsquare, the tautological curve is returned
    over the corresponding quadratic number field.  Supplying z_value fixes
    a rational lift when one is known.
    """
    degree = _validate_degree(degree)
    r_value = QQ(r_value)
    s_value = QQ(s_value)
    field, r, s = kumar_parameter_field()
    surface_rhs = kumar_surface_rhs(degree)
    surface_value = QQ(surface_rhs(r=r_value, s=s_value))
    if surface_value == 0:
        raise ValueError("specialization lies on the branch locus")

    coefficient_field, specialized_z = _specialization_field(
        surface_value,
        z_value=z_value,
        z_sign=z_sign,
    )
    j_sum, j_product = kumar_j_symmetric_functions(degree)
    specialized_j_sum = QQ(j_sum(r=r_value, s=s_value))
    specialized_j_product = QQ(j_product(r=r_value, s=s_value))
    j_ring = PolynomialRing(QQ, "J")
    J = j_ring.gen()
    specialized_j_polynomial = (
        J^2-specialized_j_sum*J+specialized_j_product
    )

    result = {
        "degree": degree,
        "discriminant": degree^2,
        "parameters": (r_value, s_value),
        "surface_value": surface_value,
        "coefficient_field": coefficient_field,
        "z_value": specialized_z,
        "j_sum": specialized_j_sum,
        "j_product": specialized_j_product,
        "j_polynomial": specialized_j_polynomial,
    }
    if include_curve:
        sextic = _specialized_universal_sextic(
            degree,
            coefficient_field,
            r_value,
            s_value,
            specialized_z,
        )
        if not sextic.is_squarefree():
            raise ValueError("specialized tautological sextic is singular")
        result["source_polynomial"] = sextic
        result["source_curve"] = HyperellipticCurve(sextic)
    return result


def audit_kumar_source_files():
    """Return a structural inventory of all 18 vendored source files."""
    inventory = []
    for degree in KUMAR_DEGREES:
        discriminant = KUMAR_DISCRIMINANTS[degree]
        for kind in ("disc", "ig", "univcurve"):
            path = _data_path(kind, degree)
            text = _data_text(kind, degree)
            inventory.append({
                "degree": degree,
                "discriminant": discriminant,
                "kind": kind,
                "path": str(path),
                "byte_count": path.stat().st_size,
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "has_surface": kind != "disc" or "z^2" in text,
                "has_j_sum": kind != "disc" or re.search(
                    r"^j1\s*\+\s*j2\s*=",
                    text,
                    flags=re.MULTILINE,
                ) is not None,
                "has_j_product": kind != "disc" or re.search(
                    r"^j1\s*\*\s*j2\s*=",
                    text,
                    flags=re.MULTILINE,
                ) is not None,
                "has_sextic": (
                    kind != "univcurve"
                    or (
                        "T^6" in text
                        and (
                            degree != 11
                            or all(
                                f"a{index}:=" in text
                                for index in range(6)
                            )
                        )
                    )
                ),
            })
    return inventory
