__precompile__()

module Juno

using MacroTools, Media

import Media: render

export Media, media, render, @render

_active = false

isprecompiling() = ccall(:jl_generating_output, Cint, ()) == 1

activate() = !isprecompiling() && @eval using Atom

setactive!(active) = (global _active = active)

"""
    isactive()

Will return `true` when the current Julia process is connected to a running Juno
frontend.
"""
isactive() = _active

if VERSION < v"0.5-"
  const String = AbstractString
end

include("types.jl")
include("utils.jl")
include("frontend.jl")
include("progress.jl")
include("user.jl")

# We do this so that a shim API is provided on 0.4
if VERSION >= v"0.5-"
  include("base/base.jl")
end

function startup(port)
  eval(Main, :(module JunoMain; using $(VERSION < v"0.5-" ? :Atom : :Juno); end))
  Juno.connect(port)
end

end # module
