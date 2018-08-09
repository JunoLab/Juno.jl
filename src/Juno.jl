module Juno

using Media, Base64, Profile

import Media: render

export Media, media, @render

_active = false

isprecompiling() = ccall(:jl_generating_output, Cint, ()) == 1

activate() = return nothing #!isprecompiling() && @eval using Atom

setactive!(active) = (global _active = active)

"""
    isactive()

Will return `true` when the current Julia process is connected to a running Juno
frontend.
"""
isactive() = _active

include("types.jl")
include("frontend.jl")
include("progress.jl")
include("user.jl")
include("utils.jl")

end # module
