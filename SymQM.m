(* ::Package:: *)

(*Chengfei Wang 6/17/2013, UESTC*)
(*last modified 9/28/2016, Auburn University*)
BeginPackage["SymQM`"];
Opt::usage = "Opt[expr] extract and replace the duplicated sub-expression with temporary varible.";
tmp::usage = "tmp is the temporary intermidiate varible.";
Begin["`Private`"];

Opt[expr_]:=Block[
{index=0,downvalues,HoldAndOpt,DownSub,optExpr,DownRule,tmp,rules},

SetAttributes[DownSub, HoldAll];
DownSub[e_] :=(
    If[Mod[index, 50] == 0, Share[]];  
    DownRule[e] := DownRule[e] = # ; #) &@tmp[++index];

(*Saved optimization rules for reciprocals as downvalues*)
DownRule[e : Hold[Power][_, -1]] := DownSub[e];
DownRule[Hold[Power][x_, y_?(NumberQ[#] && Negative[#] &)]] := \
    DownRule[Hold[Power][DownRule[Hold[Power][x, -y]], -1]];

(*Saved optimization rules for power as downvalues*)
DownRule[e : Blank[Hold[Power]]] := DownSub[e];

(*Saved optimization rules for plus as downvalues*)
DownRule[Hold[Plus][n_?NumberQ, x_, y__]] := \
    DownRule[Hold[Plus][n, DownRule[Hold[Plus][x, y]]]];
DownRule[e : Blank[Hold[Plus]]] := DownSub[e];

(*Saved optimization rules for times as downvalues*)
DownRule[Hold[Times][n_?NumberQ, x_, y__]] := \
    DownRule[Hold[Times][n, DownRule[Hold[Times][x, y]]]];
DownRule[e : Blank[Hold[Times]]] := DownSub[e];

(*Saved optimization rules for function as downvalues*)
DownRule[e_] := DownSub[e];

(* Step1: hold expressions and apply those opt rules *)
(* generate downvalues -2 means leave 2 level of mapping due to the atomic operation*)
HoldAndOpt[e_]:= DownRule[Operate[Hold,e]];
optExpr = Map[HoldAndOpt,expr,-2];

(*Step2: Modifie Rules and tmp*)
downvalues = DownValues[DownRule];
(*Degub*)(*Print["downvalues:\n",downvalues]*)
(*remove unused rule and tmp*)
Cases[downvalues,HoldPattern[_ :> (DownRule[rhs_] = lhs_)] :> (lhs = rhs)];
(*pick rules we need*)
rules = Sort[Cases[downvalues,
    HoldPattern[_[DownRule[rhs : _]] :> lhs : _tmp] :> lhs -> rhs]];
(*Debug*)(*Print[rules]*)
(*squeez the tmp[i] into tmpi*)
index=0;
tmp[i_]:=tmp[i]=ToExpression["t"<>ToString[++index]];

(*Step3: convert the result into a block and return the result*)
MakeBlock[{optRule__Rule}, releasedOptExpr_] :=(
    Hold[Block[#, optRule; releasedOptExpr]] /. Rule -> Set) &@First[Thread[{optRule}, Rule]];
MakeBlock[ReleaseHold[rules],ReleaseHold[optExpr]]
];
End[ ];
EndPackage[ ];


Opt[(x+y)^2+(x+y)^3+(a+b)^2+ff[a+b]]
