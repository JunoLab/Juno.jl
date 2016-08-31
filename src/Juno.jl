module Juno

_active = false

function activate()
  @eval using Atom
  activate(true)
end

activate(active) = (global _active = active)

"""
    isactive()

Will return `true` when the current Julia process is connected to a running Juno
frontend.
"""
isactive() = _active

end # module
