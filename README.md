# SymQM
A symbolic manipulation tool to optimize integral in quantum chemistry calculation. It is a approximate method by subtract common subexpressions. The complete optimization seems to be a NP-complete problem, it may reduce to a vertex-cover problem, but I have not prove it yet.

## Quick Start
Start Mathematica kernel in terminal. For example, Mac user can type:
```bash
user@mac ~$ /Applications/Mathematica.app/Contents/MacOS/MathKernel
Mathematica 9.0 for Mac OS X x86 (64-bit)
Copyright 1988-2012 Wolfram Research, Inc.

In[1]:= <<"/path/to/package/SymQM.m"

In[2]:= Opt[(x+y)2+(x+y)^3+(a+b)^2+ff[a+b]]

                                                       2            3
Out[3]= Hold[Block[{t1, t2}, t1 = a + b; t2 = x + y; t1  + 2 t2 + t2  + ff[t1]]]
```
Or in desktop enviroment, just open the "SymQM.m" by GUI Maththematica and append command in the end of file:
```Mathematica
Opt[(x+y)2+(x+y)^3+(a+b)^2+ff[a+b]]
```
And the output will be the same:
```Mathematica
Hold[Block[{t1, t2}, t1 = a + b; t2 = x + y; t1^2 + 2 t2 + t2^3 + ff[t1]]]
```
Notice the original expression has been changed into a form that the repeative sub-expressions are replaced by temprary varible t1, t2, thus saved 2 plus arithmic operation. Of course it seems trival in this example, but in Quantum Chemistry field, the integral involves a long and complicate expression weighted and summed up together, share the common sub-expressions heavliy, and in practice it saves huge.
## Code Explains
### Mathematica: Under the engine hood

### DownValues
### Cached Form
