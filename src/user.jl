"""
    @enter ex

Step into `ex`.
"""
macro enter(ex)
  Main.Atom.enter(__module__, ex)
end

"""
    @run ex

Run `ex` with the Interpreter and break when a breakpoint is encountered.
"""
macro run(ex)
  Main.Atom.enter(__module__, ex; initial_continue = true)
end

"""
    @trace ex

Analyse `ex` for type instabilities using Traceur.jl.
"""
macro trace(ex, args...)
  Main.Atom.trace(ex, args...)
end

function connect(args...; kws...)
  activate()
  eval(:(Main.Atom.connect($args...; $kws...)))
  return
end
