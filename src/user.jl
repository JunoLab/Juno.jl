"""
    @enter ex

Step into `ex`.
"""
macro enter(ex)
  Main.Atom.enter(__module__, ex)
end

"""
    @enter ex

Step into `ex`.
"""
macro run(ex)
  Main.Atom.enter(__module__, ex; initial_continue = true)
end

function connect(args...; kws...)
  activate()
  eval(:(Main.Atom.connect($args...; $kws...)))
  return
end
