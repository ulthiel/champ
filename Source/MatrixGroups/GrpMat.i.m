/*
	CHAMP (CHerednik Algebra Magma Package)
	Copyright (C) 2010-2021 Ulrich Thiel
	Licensed under GNU GPLv3, see COPYING.
	thiel@mathematik.uni-kl.de
	https://ulthiel.com/math
*/

/*
	Simple extensions matrix groups.
*/


declare attributes GrpMat:
    DualGroup, //the matrix group generated by (g.i^T)^-1
    IsNonModular, //true if the characteristic of the base field is coprime to group order
    Dimension, //dimension of the vector space on which the group acts
    Generators //the sequence of generators (speeds up G.i)
    ;

//============================================================================
intrinsic Generators(~G::GrpMat)
{}

	if assigned G`Generators then
		return;
	end if;

	G`Generators := [G.i : i in [1..Ngens(G)]];

end intrinsic;

//============================================================================
intrinsic MatrixGroup(Q::SeqEnum : ForceField:=true) -> GrpMat
{
	Creates matrix group generated by the matrices in Q.
}

    entries := SequenceToSet(FlatFixed(Q));
    K := Universe(entries);
    if Type(K) eq RngInt and ForceField then
        K := Rationals();
    end if;

    mats := [];
    for i:=1 to #Q do
        Append(~mats, Matrix(K, Q[i]));
    end for;

    n := Nrows(mats[1]);

    return MatrixGroup<n, K | mats>;

end intrinsic;

//============================================================================
intrinsic IsNonModular(~G::GrpMat)
{
	True iff the characteristic of the base ring is zero or does not divide the order of +G+.
}

    if Characteristic(BaseRing(G)) eq 0 or not IsDivisibleBy(Order(G), Characteristic(BaseRing(G))) then
        G`IsNonModular := true;
    else
        G`IsNonModular := false;
    end if;

end intrinsic;

//============================================================================
intrinsic IsNonModular(G::GrpMat) -> BoolElt
{True iff G is non-modular.}

    IsNonModular(~G);
    return G`IsNonModular;

end intrinsic;



//==============================================================================
/*
    Intrinsic: Specialize

    Reduces a matrix group in a prime (ideal).

    Declaration:
        :intrinsic Specialize(G::GrpMat, P::RngOrdIdl) -> GrpMat, Map
        :intrinsic Specialize(G::GrpMat, p::RngIntElt) -> GrpMat, Map

    Parameters:
    	G - a matrix group
    	P or p - a prime ideal or a prime number.

    Description:
    	Let +G+ be a matrix group over a number field +K+ with ring of integers +O+. If +P+ is a prime ideal of
    	+O+, we can reduce the matrices of +G+ in +P+ to get a matrix group over the residue field +O/P+.
*/
intrinsic Specialize(G::GrpMat, P::RngOrdIdl) -> GrpMat, Map
{Specializes (reduces) the matrix group M in the ideal P.}

    k,q := ResidueClassFieldGF(P);
    Gspecgens := [Specialize(Matrix(G.i),P) : i in [1..Ngens(G)]];
    Gspec := MatrixGroup<Dimension(G), k | Gspecgens >;
    return Gspec, hom<G->Gspec | [<G.i,Gspecgens[i]> : i in [1..Ngens(G)]]>;  //we have to be a bit careful as two generators of G might reduce to the same generator!

end intrinsic;

//==============================================================================
intrinsic Specialize(G::GrpMat, p::RngIntElt) -> GrpMat, Map
{Specializes (reduces) the matrix group M in the ideal P.}

    K := BaseRing(G);
    O := RingOfIntegers(K);
    I := ideal<O|p>;
    if Type(K) ne FldRat then
        P := Factorization(I)[1][1];
    else
        P := ideal<RingOfIntegers(CyclotomicField(1))|p>; //this is not really nice
    end if;
    return Specialize(G,P);

end intrinsic;

//==============================================================================
intrinsic IsSemisimple(G::GrpMat) -> BoolElt
/*
    Intrinsic: IsSemisimple

    Attaches/returns if the action of G is semisimple.

    Declaration:
        :intrinsic IsSemisimple(G::GrpMat) -> BoolElt

    Parameters:
    	G - a matrix group
*/
{}

    return IsSemisimple(GModule(G));

end intrinsic;


//==============================================================================
intrinsic DualGroup(G::GrpMat) -> GrpMat
/*
    Intrinsic: DualGroup

    Attaches/returns the dual group of G.

    Declaration:
        :intrinsic DualGroup(G::GrpMat) -> GrpMat

    Parameters:
    	G - a matrix group

    Description:
    	This is the matrix group consisting of the transpose-inverses of the elements of +G+ and
    	thus describes the natural action of +G+ on the dual space +V^*+.
*/
{}

    DualGroup(~G);
    return G`DualGroup;

end intrinsic;


//==============================================================================
intrinsic NaturalRepresentation(G::GrpMat) -> Map
/*
    Intrinsic: NaturalRepresentation

    Returns the natural representation.

    Declaration:
        :intrinsic NaturalRepresentation(G::GrpMat) -> Map

    Parameters:
    	G - a matrix group
*/
{}

    return hom<G->GeneralLinearGroup(Dimension(G), BaseRing(G))|[G.i:i in [1..Ngens(G)]]>;

end intrinsic;


//==============================================================================
intrinsic NaturalGModule(G::GrpMat) -> Map
/*
    Intrinsic: NaturalGModule

    Returns the natural G-module.

    Declaration:
        :intrinsic NaturalGModule(G::GrpMat) -> Map

    Parameters:
    	G - a matrix group
*/
{}

    return GModule(G, [ G.i : i in [1..Ngens(G)] ]);

end intrinsic;
