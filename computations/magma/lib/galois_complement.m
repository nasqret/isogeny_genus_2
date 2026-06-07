/*
Group and branch-action certificates for the Galois complement.

For G = S_n x C_2, the off-diagonal component corresponds to

    H_Z = S_(n-2) x {1}.

The complementary quotient corresponds to the graph subgroup

    H_W = <H_Z, ((1 2), -1)>.

The coset action G/H_W has a concrete degree n(n-1) model on ordered
pairs (a,b), a ne b:

    (sigma,+1): (a,b) -> (sigma(a),sigma(b)),
    (sigma,-1): (a,b) -> (sigma(b),sigma(a)).
*/

GenericComplementCertificateRF := recformat<
    Degree,
    QuotientDegree,
    BranchIndices,
    BranchCycleLengths,
    Genus,
    ActionOrder,
    StabilizerOrder
>;

function PairIndex(n, a, b)
    assert a ge 1 and a le n;
    assert b ge 1 and b le n;
    assert a ne b;
    rank := b;
    if b gt a then
        rank -:= 1;
    end if;
    return (a-1)*(n-1) + rank;
end function;

function TwistedPairPermutation(n, sigma, epsilon)
    assert epsilon in {-1, 1};
    pair_symmetric_group := SymmetricGroup(n*(n-1));
    images := [ Integers() | ];
    for a in [1..n] do
        for b in [1..n] do
            if a eq b then
                continue;
            end if;
            image_a := a^sigma;
            image_b := b^sigma;
            if epsilon eq -1 then
                image_a, image_b := Explode(<image_b, image_a>);
            end if;
            Append(
                ~images,
                PairIndex(n, image_a, image_b)
            );
        end for;
    end for;
    return pair_symmetric_group!images;
end function;

function CycleLengths(permutation)
    degree := Degree(Parent(permutation));
    seen := { Integers() | };
    lengths := [ Integers() | ];
    for start in [1..degree] do
        if start in seen then
            continue;
        end if;
        current := start;
        length := 0;
        repeat
            Include(~seen, current);
            current := current^permutation;
            length +:= 1;
        until current eq start;
        Append(~lengths, length);
    end for;
    Sort(~lengths);
    return lengths;
end function;

function PermutationIndex(permutation)
    return Degree(Parent(permutation)) - #CycleLengths(permutation);
end function;

function ProductOfDisjointTranspositions(Sn, count)
    sigma := Sn!1;
    for index in [1..count] do
        sigma *:= Sn!(2*index-1, 2*index);
    end for;
    return sigma;
end function;

function TwistedPairActionGroup(n)
    Sn := SymmetricGroup(n);
    generators := [
        TwistedPairPermutation(n, Sn!(index, index+1), 1)
        : index in [1..n-1]
    ];
    Append(~generators, TwistedPairPermutation(n, Sn!1, -1));
    return sub<SymmetricGroup(n*(n-1)) | generators>;
end function;

function ComplementSignatureCertificate(n, sigmas, epsilons)
    assert #sigmas eq #epsilons;
    branch_permutations := [
        TwistedPairPermutation(n, sigmas[index], epsilons[index])
        : index in [1..#sigmas]
    ];

    quotient_degree := n*(n-1);
    branch_indices := [
        PermutationIndex(permutation)
        : permutation in branch_permutations
    ];
    genus_numerator := 2 - 2*quotient_degree + &+branch_indices;
    assert IsEven(genus_numerator);
    genus := genus_numerator div 2;

    action_group := TwistedPairActionGroup(n);
    stabilizer := Stabilizer(
        action_group,
        PairIndex(n, 1, 2)
    );
    assert #action_group eq 2*Factorial(n);
    assert #stabilizer eq 2*Factorial(n-2);
    assert Index(action_group, stabilizer) eq quotient_degree;

    certificate := rec<GenericComplementCertificateRF |
        Degree := n,
        QuotientDegree := quotient_degree,
        BranchIndices := branch_indices,
        BranchCycleLengths := [
            CycleLengths(permutation)
            : permutation in branch_permutations
        ],
        Genus := genus,
        ActionOrder := #action_group,
        StabilizerOrder := #stabilizer
    >;
    return certificate;
end function;

function GenericOddComplementCertificate(n)
    assert n ge 5 and IsOdd(n);
    Sn := SymmetricGroup(n);

    // At the four elliptic branch values the associated P1 cover has
    // fixed-point counts 3,1,1,1.  The fifth branch cycle is a single
    // transposition.  The C2 coordinate is -1 at the elliptic branch
    // values and +1 at the extra branch value.
    special := ProductOfDisjointTranspositions(
        Sn,
        (n-3) div 2
    );
    ordinary := ProductOfDisjointTranspositions(
        Sn,
        (n-1) div 2
    );
    extra := Sn!(1, 2);
    return ComplementSignatureCertificate(
        n,
        [special, ordinary, ordinary, ordinary, extra],
        [-1, -1, -1, -1, 1]
    );
end function;

function DiagonalEmbeddingPermutation(n, sigma)
    ambient := SymmetricGroup(2*n);
    images := [ Integers() | ];
    for index in [1..n] do
        Append(~images, index^sigma);
    end for;
    for index in [1..n] do
        Append(~images, n + index^sigma);
    end for;
    return ambient!images;
end function;

function BlockSwapPermutation(n)
    ambient := SymmetricGroup(2*n);
    return ambient!(
        [n+index : index in [1..n]]
        cat [index : index in [1..n]]
    );
end function;

function GaloisComplementSubgroups(n)
    assert n ge 4;
    Sn := SymmetricGroup(n);
    ambient := SymmetricGroup(2*n);
    diagonal_generators := [
        DiagonalEmbeddingPermutation(
            n,
            Sn!(index, index+1)
        )
        : index in [1..n-1]
    ];
    block_swap := BlockSwapPermutation(n);
    G := sub<ambient | diagonal_generators cat [block_swap]>;

    hz_generators := [
        DiagonalEmbeddingPermutation(
            n,
            Sn!(index, index+1)
        )
        : index in [3..n-1]
    ];
    HZ := sub<G | hz_generators>;
    graph_generator := (
        DiagonalEmbeddingPermutation(n, Sn!(1, 2))
        * block_swap
    );
    HW := sub<G | hz_generators cat [graph_generator]>;

    assert #G eq 2*Factorial(n);
    assert #HZ eq Factorial(n-2);
    assert #HW eq 2*Factorial(n-2);
    assert HZ subset HW;
    assert Index(G, HZ) eq 2*n*(n-1);
    assert Index(G, HW) eq n*(n-1);
    return G, HZ, HW;
end function;

function CriticalQuarticIntersection()
    n := 4;
    Sn := SymmetricGroup(n);
    G, HZ, HW := GaloisComplementSubgroups(n);
    block_swap := BlockSwapPermutation(n);
    signed_generators := [
        DiagonalEmbeddingPermutation(
            n,
            Sn!(index, index+1)
        ) * block_swap
        : index in [1..n-1]
    ];
    critical_group := sub<G | signed_generators>;
    critical_fixed_subgroup := critical_group meet HW;

    assert #critical_group eq Factorial(4);
    assert #critical_fixed_subgroup eq 2;
    assert IsCyclic(critical_fixed_subgroup);
    assert Index(
        critical_group,
        critical_fixed_subgroup
    ) eq 12;
    return critical_group, critical_fixed_subgroup;
end function;
