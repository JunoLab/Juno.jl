# Juno.jl

This package defines Juno's frontend API. It is aimed primarily at allowing package authors to:

* Integrate with Juno's display system to define custom output for graphics and data structures
* Take advantage of frontend features (like showing progress metres or asking for user input) with appropriate fallbacks in other environments

All while having only a small, pure Julia dependency (this package) as opposed to the entire Atom.jl tree.
