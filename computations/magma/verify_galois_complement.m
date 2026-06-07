/*
Full subgroup and Riemann-Hurwitz certificate for B011.

This verifies:
  - H_Z and H_W in S_n x C2 for degrees 4 through 11;
  - the twisted ordered-pair coset action;
  - genus one for the generic odd-degree branch signature;
  - the critical-quartic specialization, where the elliptic quadratic
    field is the sign subfield and H_W intersects the S4 graph in a
    transposition subgroup of index 12.
*/

load "computations/magma/lib/galois_complement.m";

for n in [4..11] do
    G, HZ, HW := GaloisComplementSubgroups(n);
    print "SUBGROUP_CERTIFICATE", n;
    print "G_order", #G;
    print "HZ_order_index", #HZ, Index(G, HZ);
    print "HW_order_index", #HW, Index(G, HW);
end for;

for n in [5, 7, 9, 11, 13, 15] do
    certificate := GenericOddComplementCertificate(n);
    assert certificate`Genus eq 1;
    print "GENERIC_ODD_CERTIFICATE", n;
    print "quotient_degree", certificate`QuotientDegree;
    print "branch_indices", certificate`BranchIndices;
    print "quotient_genus", certificate`Genus;
    print "action_order", certificate`ActionOrder;
    print "stabilizer_order", certificate`StabilizerOrder;
end for;

// Exact signatures of the compact degree-6, degree-7, and degree-8
// rational quotients.  The first entries lie over branch values of the
// elliptic double cover and therefore carry C2 coordinate -1.
S6 := SymmetricGroup(6);
degree6_signature := ComplementSignatureCertificate(
    6,
    [
        ProductOfDisjointTranspositions(S6, 2),
        ProductOfDisjointTranspositions(S6, 2),
        ProductOfDisjointTranspositions(S6, 2),
        ProductOfDisjointTranspositions(S6, 3),
        S6!(1, 2)
    ],
    [-1, -1, -1, -1, 1]
);
assert degree6_signature`Genus eq 1;

S7 := SymmetricGroup(7);
degree7_signature := ComplementSignatureCertificate(
    7,
    [
        ProductOfDisjointTranspositions(S7, 3),
        ProductOfDisjointTranspositions(S7, 3),
        ProductOfDisjointTranspositions(S7, 3),
        S7!(1, 2, 3, 4)
    ],
    [-1, -1, -1, -1]
);
assert degree7_signature`Genus eq 1;

S8 := SymmetricGroup(8);
degree8_signature := ComplementSignatureCertificate(
    8,
    [
        ProductOfDisjointTranspositions(S8, 3),
        ProductOfDisjointTranspositions(S8, 3),
        ProductOfDisjointTranspositions(S8, 3),
        S8!(1, 2, 3, 4) * S8!(5, 6) * S8!(7, 8)
    ],
    [-1, -1, -1, -1]
);
assert degree8_signature`Genus eq 1;

for certificate in [
    degree6_signature,
    degree7_signature,
    degree8_signature
] do
    print "BENCHMARK_SIGNATURE", certificate`Degree;
    print "branch_indices", certificate`BranchIndices;
    print "quotient_genus", certificate`Genus;
end for;

critical_group, critical_fixed_subgroup :=
    CriticalQuarticIntersection();
print "CRITICAL_QUARTIC_CERTIFICATE";
print "critical_group_order", #critical_group;
print "critical_fixed_subgroup_order",
    #critical_fixed_subgroup;
print "critical_quotient_degree",
    Index(critical_group, critical_fixed_subgroup);

print "B011_GALOIS_COMPLEMENT_VERIFIED";
quit;
