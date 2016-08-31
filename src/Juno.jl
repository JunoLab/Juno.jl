module Juno

using MacroTools, Media

export render

_active = false

activate() = @eval using Atom

setactive!(active) = (global _active = active)

"""
    isactive()

Will return `true` when the current Julia process is connected to a running Juno
frontend.
"""
isactive() = _active

include("types.jl")
include("frontend.jl")

end # module
