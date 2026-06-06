/*
Independent Magma verification of claim C037.

The specialization x^4-8*x^2+16*x-1 has Galois group S4.  Since a
specialized Galois group embeds in the generic group and the generic
group is already a subgroup of S4, this certifies the generic S4 group.
The remainder checks every subgroup and index in the paper's tower.
*/

Q := Rationals();
P<x> := PolynomialRing(Q);
f := x^4 - 8*x^2 + 16*x - 1;
assert IsIrreducible(f);
G, roots, map := GaloisGroup(f);
assert #G eq 24;
assert IsIsomorphic(G, SymmetricGroup(4));

S4 := SymmetricGroup(4);
sigma34 := S4!(3, 4);
sigma234 := S4!(2, 3, 4);

H34 := sub<S4 | sigma34>;
H234 := sub<S4 | sigma234>;
A4 := AlternatingGroup(4);
Stab1 := Stabilizer(S4, 1);
intersection := A4 meet Stab1;

assert #H34 eq 2;
assert #H234 eq 3;
assert #A4 eq 12;
assert #Stab1 eq 6;
assert intersection eq H234;

assert Index(S4, H34) eq 12;
assert Index(S4, Stab1) eq 4;
assert Index(S4, A4) eq 2;
assert Index(Stab1, H34) eq 3;
assert Index(A4, H234) eq 4;
assert Index(Stab1, H234) eq 2;

// H234 is maximal in A4: there is no proper subgroup strictly between them.
intermediate := [
    H : H in Subgroups(A4)
    | H234 subset H`subgroup and H`order gt #H234 and H`order lt #A4
];
assert #intermediate eq 0;

print "C037_OK";
print "specialization_polynomial", f;
print "specialization_galois_group_order", #G;
print "H34_order_index", #H34, Index(S4, H34);
print "Stab1_order_index", #Stab1, Index(S4, Stab1);
print "A4_order_index", #A4, Index(S4, A4);
print "H234_order_index_in_A4", #H234, Index(A4, H234);
print "intersection_is_H234", intersection eq H234;
print "H234_maximal_in_A4", #intermediate eq 0;
quit;
