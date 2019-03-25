# Juno.jl

[![Build Status](https://travis-ci.org/JunoLab/Juno.jl.svg?branch=master)](https://travis-ci.org/JunoLab/Juno.jl) [![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JunoLab.github.io/JunoDocs.jl/latest)

This package defines [Juno](http://junolab.org/)'s frontend API (to install Juno, follow the instructions [here](http://docs.junolab.org/latest/man/installation)). It is aimed primarily at allowing package authors to:

* Integrate with Juno's display system to define custom output for graphics and data structures
* Take advantage of frontend features (like showing progress metres or asking for user input) with appropriate fallbacks in other environments

All while having only a small, pure Julia dependency (this package) as opposed to the entire Atom.jl tree.
