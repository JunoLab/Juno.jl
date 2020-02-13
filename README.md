# Juno.jl

[![Build Status](https://travis-ci.org/JunoLab/Juno.jl.svg?branch=master)](https://travis-ci.org/JunoLab/Juno.jl) [![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JunoLab.github.io/JunoDocs.jl/latest)

This package defines [Juno](http://junolab.org/)'s frontend API (to install Juno, follow the instructions [here](http://docs.junolab.org/latest/man/installation)). It is aimed primarily at allowing package authors to:

* Integrate with Juno's display system to define custom output for graphics and data structures
* Take advantage of frontend features (like showing progress metres or asking for user input) with appropriate fallbacks in other environments

All while having only a small, pure Julia dependency (this package) as opposed to the entire Atom.jl tree.


## Note for developers

If any method signature has been changed after you modify the code base,
it may lead to cause an error in [the precompilation file](./src/precompile.jl)
when you precompile this package again.

It's okay to temporarily comment out the `_precompile_()` call in
[Juno.jl](./src/Juno.jl) until you satisfy with your changes,
and then error because of precompilation failure won't happen while editing.

Finally you may need to run the following command and update the precompilation statements.

> at the root of this package directory

```bash
λ julia --project=. --color=yes scripts/generate_precompile.jl
```
