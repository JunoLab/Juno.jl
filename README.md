# Juno.jl

[![Developer Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/JunoLab/Juno)
[![Build Status](https://travis-ci.org/JunoLab/Juno.jl.svg?branch=master)](https://travis-ci.org/JunoLab/Juno.jl)

This package defines [Juno](http://junolab.org/)'s frontend API and is the user facing repository for the project.
Please report your issues either at the [Juno Discussion Board](http://discuss.junolab.org/)
or here.

Juno.jl is aimed primarily at allowing package authors to:

* Integrate with Juno's display system to define custom output for graphics and data structures
* Take advantage of frontend features (like showing progress metres or asking for user input) with appropriate fallbacks in other environments

All while having only a small, pure Julia dependency (this package) as opposed to the entire Atom.jl tree.

The code in the [`base` folder](src/base) shows what the package can do. Even fundamental types like arrays or `nothing` are rendered here; nothing is a special case, and anything they can do, you can do too. See the [Juno Documentation]() for more details on how to use the package.
