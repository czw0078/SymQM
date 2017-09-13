# SymQM
A symbolic manipulation tool to optimize integral in quantum chemistry calculation approximately by subtract common subexpressions.
The optimization is a NP-complete problem, it may reduce to a vertex-cover, but I have not prove it yet.

## Quick Start
Start Mathematica in terminal or GUI, load the package "SymQM"

```Mathematica
Opt[(x+y)2+(x+y)^3+(a+b)^2+ff[a+b]]
```

## Code Explains
### DownValues
### Cached Form
