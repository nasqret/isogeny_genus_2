Q := Rationals();
P0<x> := PolynomialRing(Q);

N0 :=
    1162836225963*x^9
    - 256545765846466281*x^8
    + 12652488352380857709336*x^7
    + 818827565449711168023412677*x^6
    - 60886103685147745340670731299508*x^5
    - 3146599524765592448018557306442895716*x^4
    + 279436442970809306335577972418159506755232*x^3
    + 1746202059537274010678006676413547682896124208*x^2
    - 533062849190004836422732749143975255871828802923584*x
    + 11229668661977555866970270104041120158473185041800892736;
D0 :=
    5041*x^9
    - 2457565316*x^8
    + 413733513750033*x^7
    - 21565635256056602542*x^6
    - 1340101343350854652279676*x^5
    + 187261747469204952946806060248*x^4
    - 4426121358811994618001199054583248*x^3
    - 211440669630409945327261004278658031136*x^2
    + 11125625311906705351796300739141028282480064*x
    - 125204069316651023422344999259625249073639005568;

// A good specialization embeds its Galois group into the generic group.
// Irreducibility gives transitivity.  The factorization at 47 gives cycle
// type (1)(3)(5), whose third power is a 5-cycle.  Such an element excludes
// the only possible nontrivial block size, 3.  Jordan's theorem then gives
// A9.  The factorization at 109 gives cycle type (2)(7), whose seventh
// power is a transposition, so the specialized and generic groups are S9.
assert IsIrreducible(N0);
cycle_types := [];
for prime in [47, 109] do
    finite_ring := PolynomialRing(GF(prime));
    factorization := Factorization(finite_ring!N0);
    degrees := Sort(&cat[
        [Degree(item[1]) : index in [1..item[2]]]
        : item in factorization
    ]);
    Append(~cycle_types, degrees);
end for;
assert cycle_types[1] eq [1, 3, 5];
assert cycle_types[2] eq [2, 7];

KT<T> := FunctionField(Q);
P<X> := PolynomialRing(KT);
N := &+[
    KT!Coefficient(N0, index)*X^index
    : index in [0..Degree(N0)]
];
D := &+[
    KT!Coefficient(D0, index)*X^index
    : index in [0..Degree(D0)]
];
fiber := N-T*D;

fiber_discriminant := Discriminant(fiber);
target_branch :=
    4*(
        T^3
        - T^2
        - 1604677999942163*T
        - 205661103401997979787347
    )
    + 1;
discriminant_square_class :=
    359687
    * (
        1842229401671*T
        + 98280453222687553920
    );
square_constant := KT!(
    fiber_discriminant
    / (
        discriminant_square_class
        * (target_branch/4)^4
    )
);
square_constant_rational := Q!square_constant;
assert Denominator(square_constant_rational) eq 1;
is_square_constant, square_root_constant := IsSquare(
    Numerator(square_constant_rational)
);
assert is_square_constant;

target_branch_polynomial := Numerator(target_branch);
discriminant_class_polynomial := Numerator(
    discriminant_square_class
);
assert IsSquarefree(target_branch_polynomial);
assert IsSquarefree(discriminant_class_polynomial);
assert GCD(
    target_branch_polynomial,
    discriminant_class_polynomial
) eq 1;

// S9 has one quadratic subfield, cut out by the fiber discriminant.
// The elliptic base adjoins sqrt(target_branch), a different square class.
print "B011_B016_DEGREE9_MONODROMY_VERIFIED";
print "specialized_cycle_types", cycle_types;
print "specialized_fiber_group", "S9";
print "specialized_fiber_order", 362880;
print "generic_rational_map_group", "S9";
print "elliptic_base_group", "S9";
print "discriminant_square_class",
    "359687*(1842229401671*T+98280453222687553920)";
quit;
