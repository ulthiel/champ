/*
	CHAMP (CHerednik Algebra Magma Package)
	Copyright (C) 2013-2021 Ulrich Thiel
	Licensed under GNU GPLv3, see COPYING.
	thiel@mathematik.uni-kl.de
	https://ulthiel.com/math
*/

/*
	Parameters for rational Cherednik algebras
*/

declare attributes GrpMat:
	MartinoSharp,
	CherednikParameterSpace;


//=========================================================================
intrinsic CherednikParameter(G::GrpMat : Type:="GGOR", Rational:=false) -> Map
/*
    History:
        Tuesday, September 17, 2013 12:10:52: Initial.
*/
{A (rational if true) generic Cherednik parameter of specified type for G.}

    if Type eq "EG" then
        //standard Etingof-Ginzburg parameters
        ReflectionLibrary(~G);
        N := #G`ReflectionClasses;
        if not Rational then
            K := PolynomialRing(BaseRing(G), N);
        else
            K := RationalFunctionField(BaseRing(G), N);
        end if;
        AssignNames(~K, [ "c"*Sprint(i) : i in [1..N] ]);
        c := map<{1..N} -> K | [ <i,K.i> : i in [1..N]]>;
        return c;
    elif Type eq "BR" then
        //Bonnafe-Rouquier parameters
        ReflectionLibrary(~G);
        N := #G`ReflectionClasses;
        if not Rational then
            K := PolynomialRing(BaseRing(G), N);
        else
            K := RationalFunctionField(BaseRing(G), N);
        end if;
        AssignNames(~K, [ "C"*Sprint(i) : i in [1..N] ]);
        c := map<{1..N} -> K | [ <i,(G`ReflectionLibraryClasses[i]`Eigenvalue-1)*K.i> : i in [1..N]]>;
        return c;
    // elif Type eq "completed" then
    //     //the GGOR parameters but without setting k_{\Omega,0} = 0
    //     ReflectionLibrary(~G);
    //     N := #G`ReflectionClasses;
    //     eOmega := [ #G`ReflectionLibrary[i][1] + 1 : i in [1..#G`ReflectionLibrary] ];
    //     if not Rational then
    //         K := PolynomialRing(BaseRing(G), &+[ eOmega[i] : i in [1..#eOmega] ]);
    //     else
    //         K := RationalFunctionField(BaseRing(G), &+[ eOmega[i] : i in [1..#eOmega] ]);
    //     end if;
    //     names := [];
    //     for i:=1 to #eOmega do
    //         for j:=0 to eOmega[i]-1 do
    //             Append(~names, "k"*Sprint(i)*"_"*Sprint(j)*"");
    //         end for;
    //     end for;
    //     AssignNames(~K, names);
    //     cvalues := [ Zero(K) : i in [1..N] ];
    //     for i:=1 to N do
    //         s := G`ReflectionLibraryClasses[i];
    //         Omega := s`ID[1]; //Omega_s
    //         det := Determinant(s`Element);
		//
    //         for j:=0 to eOmega[Omega]-1 do
    //             kj := K.Position(names, "k"*Sprint(Omega)*"_"*Sprint(j mod eOmega[Omega])*""); //k_{Omega_s,j}
    //             cvalues[i] +:= det^j*kj;
    //         end for;
    //         cvalues[i] *:= (det^-1-1);
    //     end for;
    //     c := map<{1..N} -> K | [ <i,cvalues[i]> : i in [1..#cvalues]]>;
    //     return c;
    elif Type eq "GGOR" then
        ReflectionLibrary(~G);
        N := #G`ReflectionClasses;
        eOmega := [ #G`ReflectionLibrary[i][1] + 1 : i in [1..#G`ReflectionLibrary] ];
        if not Rational then
            K := PolynomialRing(BaseRing(G), &+[ eOmega[i]-1 : i in [1..#eOmega] ]);
        else
            K := RationalFunctionField(BaseRing(G), &+[ eOmega[i]-1 : i in [1..#eOmega] ]);
        end if;
        names := [];
        for i:=1 to #eOmega do
            for j:=1 to eOmega[i]-1 do
                Append(~names, "k"*Sprint(i)*"_"*Sprint(j)*"");
            end for;
        end for;
        AssignNames(~K, names);
        cvalues := [ Zero(K) : i in [1..N] ];
        for i:=1 to N do
            s := G`ReflectionLibraryClasses[i];
            Omega := s`ID[1]; //Omega_s
            det := Determinant(s`Element);
            for j:=1 to eOmega[Omega]-1 do
                kj := K.Position(names, "k"*Sprint(Omega)*"_"*Sprint(j mod eOmega[Omega])*""); //k_{Omega_s,j+1}
                cvalues[i] +:= det^j*kj;
            end for;
            cvalues[i] *:= (det^-1 - 1);
        end for;
        c := map<{1..N} -> K | [ <i,cvalues[i]> : i in [1..#cvalues]]>;
        return c;
    end if;

    return 0;

end intrinsic;

//=========================================================================
intrinsic CherednikParameter(G::GrpMat, c::SeqEnum : Type:="GGOR") -> Map
{A Cherednik parameter for G with t=0.}

    cgen := CherednikParameter(G:Type:=Type, Rational:=false);
    K := BaseRing(G);
    cmap := map<{1..#G`ReflectionClasses}->K | [ <i,K!Evaluate(cgen(i),c)> : i in [1..#G`ReflectionClasses]]>;
    return cmap;

end intrinsic;

//=========================================================================
intrinsic FullCherednikParameter(G::GrpMat : Type:="GGOR", Rational:=true) -> Tup
{A Cherednik parameter for G including the t-parameter.}

    c := CherednikParameter(G:Type:=Type,Rational:=Rational);
    K:=Codomain(c);
    N := #G`ReflectionClasses;
    if not Rational then
        L := PolynomialRing(BaseRing(G),Ngens(K)+1);
    else
        L := RationalFunctionField(BaseRing(G), Ngens(K)+1);
    end if;
    names := ["t"] cat Names(K);
    AssignNames(~L,names);
    emb := hom<K->L | [ L.(i+1) : i in [1..Ngens(K)]]>;
    cL := map<Domain(c)->L | [<x,emb(c(x))> : x in Domain(c)]>;
    return <L.1, cL>;

end intrinsic;

//=========================================================================
intrinsic SpecializeCherednikParameterInHyperplane(c::Map, H::RngElt) -> Map
/*
    History:
        Monday, October 21, 2013 16:35:19: Initial.
*/
{Specializes a Cherednik parameter in the generic point of a hyperplane.}
    if not Degree(H) eq 1 then
        error "Not a hyperplane";
    end if;

    if 1 in Monomials(H) then
        error "Hyperplane is affine.";
    end if;

    P := Codomain(c);
    coeffs := [ MonomialCoefficient(P!H,P.i) : i in [1..Ngens(P)] ];

    lnum:=1;
    while coeffs[lnum] eq 0 do
        lnum +:= 1;
    end while;

    alpha := coeffs[lnum];

    for i:=1 to #coeffs do
        coeffs[i] *:= 1/alpha;
    end for;

    Q := RationalFunctionField(BaseRing(P), Ngens(P)-1);
    AssignNames(~Q, [ Names(P)[i] : i in [1..Ngens(P)] | i ne lnum]);

    rep := - ArraySum( [ coeffs[i]*Q.i : i in [1..lnum-1] ] cat [ coeffs[i]*Q.(i-1) : i in [lnum+1..Ngens(P)] ]);

    f := hom<P->Q | [ Q.i : i in [1..lnum-1] ] cat [rep] cat [ Q.(i-1) : i in [lnum+1..Ngens(P)] ]>;

    cf := map<Domain(c) -> Q | [<i,f(c(i))> : i in Domain(c)]>;

    return cf;


end intrinsic;

//=========================================================================
intrinsic RestrictCherednikParameterInHyperplane(c::Map, H::RngElt) -> Map
/*
    History:
        Monday, October 21, 2013 16:35:19: Initial.
*/
{}
    if not Degree(H) eq 1 then
        error "Not a hyperplane";
    end if;

    if 1 in Monomials(H) then
        error "Hyperplane is affine.";
    end if;

    P := Codomain(c);
    coeffs := [ MonomialCoefficient(H,P.i) : i in [1..Ngens(P)] ];

    lnum:=1;
    while coeffs[lnum] eq 0 do
        lnum +:= 1;
    end while;

    alpha := coeffs[lnum];

    for i:=1 to #coeffs do
        coeffs[i] *:= 1/alpha;
    end for;

    Q := PolynomialRing(BaseRing(P), Ngens(P)-1);
    AssignNames(~Q, [ Names(P)[i] : i in [1..Ngens(P)] | i ne lnum]);

    rep := - ArraySum( [ coeffs[i]*Q.i : i in [1..lnum-1] ] cat [ coeffs[i]*Q.(i-1) : i in [lnum+1..Ngens(P)] ]);

    f := hom<P->Q | [ Q.i : i in [1..lnum-1] ] cat [rep] cat [ Q.(i-1) : i in [lnum+1..Ngens(P)] ]>;

    cf := map<Domain(c) -> Q | [<i,f(c(i))> : i in Domain(c)]>;

    return cf;

end intrinsic;


//=========================================================================
intrinsic CherednikParameterSpace(~G::GrpMat)
{}

    if assigned G`CherednikParameterSpace then
        return;
    end if;

    G`CherednikParameterSpace := Codomain(CherednikParameter(G : Type:="GGOR", Rational:=false));

    sharp := [];

    for i:=1 to #G`ReflectionLibrary do
        eOmega := #G`ReflectionLibrary[i][1]+1;
        for j:=1 to eOmega-1 do
            pos := Position(Names(G`CherednikParameterSpace), "k"*Sprint(i)*"_"*Sprint(j));
            newj := -j+eOmega;
            newpos := Position(Names(G`CherednikParameterSpace), "k"*Sprint(i)*"_"*Sprint(newj));
            Append(~sharp, G`CherednikParameterSpace.newpos);
        end for;
    end for;

    G`MartinoSharp := hom<G`CherednikParameterSpace->G`CherednikParameterSpace | sharp>;

end intrinsic;

//============================================================================
intrinsic CherednikParameter(c::SeqEnum) -> Map
{}

	return map<{1..#c}->Universe(c) | [<i,c[i]> : i in [1..#c]]>;

end intrinsic;
