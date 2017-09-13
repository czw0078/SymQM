# Introduction to SymQM
A symbolic manipulation tool to optimize integral in quantum chemistry calculation. It is an approximate method by subtracting common subexpressions. The complete optimization seems to be a NP-complete problem, it may reduce to a vertex-cover problem, but I have not proved it yet.

## Quick Start
Start Mathematica kernel in a terminal. For example, Mac user can type:
```bash
user@mac ~$ /Applications/Mathematica.app/Contents/MacOS/MathKernel
Mathematica 9.0 for Mac OS X x86 (64-bit)
Copyright 1988-2012 Wolfram Research, Inc.

In[1]:= <<"/path/to/package/SymQM.m"

In[2]:= Opt[(x+y)2+(x+y)^3+(a+b)^2+ff[a+b]]

                                                       2            3
Out[3]= Hold[Block[{t1, t2}, t1 = a + b; t2 = x + y; t1  + 2 t2 + t2  + ff[t1]]]
```
Or in a desktop environment, just open the "SymQM.m" by GUI Mathematica and append command at the end of the file:
```Mathematica
Opt[(x+y)2+(x+y)^3+(a+b)^2+ff[a+b]]
```
And the output will be the same:
```Mathematica
Hold[Block[{t1, t2}, t1 = a + b; t2 = x + y; t1^2 + 2 t2 + t2^3 + ff[t1]]]
```
Notice the original expression has been changed by the function "Opt" into a form that the repetitive sub-expressions are replaced by temporary variable t1, t2, thus saved 2 plus arithmetic operation. Of course, it seems trivial in this example, but in Quantum Chemistry field, the integral involves a long and complicate expression weighted and summed up together, share the common sub-expressions heavily, and in practice it saves huge.
## Explain the Code
### Mathematica: Under the engine hood
Mathematica is a LISP-like programming language together with a computer algebra system that already implemented. The implementation of the computer algebra system is beyond the scope of this document, but we can still see some insights. We first see how the algebra expressions are actually represented in Mathematica:
```Mathematica
(x+y)2+(x+y)^3+(a+b)^2+ff[a+b]//FullForm

Plus[Power[Plus[a,b],2],Times[2,Plus[x,y]],Power[Plus[x,y],3],ff[Plus[a,b]]]
```
As we can see, all the expressions are in prefix form. This form can be seen as nested lists whose first element is the special "head" of a function and the rest are the arguments. Lists are the fundamental data structures of the whole system. 
### DownValues
A set of rules is also needed to be pre-defined or customized in the system, therefore the system can perform symbolic manipulation such as expanding (a+b)^2 into a^2+2ab+b^2. Except for many predefined rules in the algebra system, the user can use set "=" or delayed set ":=" to add new rules into the system. When you define a function, you should use delayed set ":="
```Mathematica
foo[e_]:= e*2+1
```
After setting the function foo, a certain rule is added into the system. This rule is associated with specific symbol "foo". It is called down values of foo in Mathematica. The reason it is called "down" instead of "up" is that the rules apply only to the elements within the bracket after foo(up values are those rules apply to elements outside the bracket, but we will not discuss it here.). See:
```Mathematica
DownValues[foo]

{HoldPattern[foo[e_]]:>e 2+1}
```
This shows that how previous delayed set ":=" transformed into actual rules(down values) associated with symbol "fool", the ":>" is a delayed rule, just like delayed set ":=" only triggered when applied. "HoldPattern" is used because we need the left side of the rule as a pattern remains intact during the process of rule matching. Remember there are lots of predefined rules in the system which will be evaluated first if we do not hold the pattern.
### Cached Form
A cached form is frequently used in Mathematica, see example:
```Mathematica
foo[e_]:= foo[e] = e*2+1
```
And the down values of such definition is:
```Mathematica
{HoldPattern[foo[e_]]:>(f[e]=e 2+1)}
```
The cached form can avoid unnecessary calculation and just take the cached value. How this affects the change of down values? The right side of the rule now become a "set expression" instead of a simple value, so it will execute if you send argument "y" and a new rule add to itself.
```Mathematica
{HoldPattern[foo[e_]]:>(f[e]=e 2+1), HoldPattern[foo[y]]:>y 2+1}
```
This is the beauty of functional programming, function(closure) or basic types can be treated as same as first-class members. 
### Save the Sub-expression
Let look at the line 14 and 24 of SymQM:
```Mathematica
DownSub[e_] :=(
     If[Mod[index, 50] == 0, Share[]];
     DownRule[e] := DownRule[e] = # ; #) &@tmp[++index];
...
DownRule[e : Blank[Hold[Power]]] := DownSub[e];
```
Every time call function "DownSub", it executes the closure "DownRule", combine with line 24, a rule is established. Modify the source code of "SymQM.m" can print out the rule:
```Mathematica
HoldPattern[SymQM`Private`DownRule[Hold[Plus][x,y]]]:>(SymQM`Private`DownRule[Hold[Plus][x,y]]=tmp[1])
```
The "tmp" is a serial of temporary variables named with numbers in the bracket. Notice this rule is slightly different with cached form in "SymQM". The left side of the rule is a fixed pattern, not an expression. When it triggered, the new rule will cover the old rule
```Mathematica
HoldPattern[SymQM`Private`DownRule[Hold[Plus][x,y]]]:>tmp[1]
```
This is critical of the program. If such rule is used more than once, then the right side of the rule must have a head "tmp". If not, then such "tmp" replacement only used once in the original expression, it is also not repetitive. So we need only brute-force apply the rule to everywhere of the expression(see line 42) and only keep the rules like latter form and throw the other rules, then we will have proper replace rules for repetitive sub-expression. That is the work of line 48~50.
## File
All the integrals need to be Opt and math background of the projects are put in folder "Integrals". 





