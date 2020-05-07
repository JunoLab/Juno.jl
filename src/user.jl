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

Analyse `ex` for type instabilities using [Traceur.jl](https://github.com/JunoLab/Traceur.jl).

!!! warning
    You need to first run `using Traceur` before using this macro.
"""
macro trace(ex, args...)
  return if isdefined(Main.Atom,  :trace)
    Main.Atom.trace(ex, args...)
  else
    notification("`Juno.@trace`"; kind = :Warning, options = (
      dismissable = true,
      description = """
      You haven't loaded [Traceur package](https://github.com/JunoLab/Traceur.jl) into this running session.
      Run `using Traceur` first and use this macro again.
      """
    ))
    :($(esc(ex)))
  end
end

function connect(args...; kws...)
  activate()
  eval(:(Main.Atom.connect($args...; $kws...)))
  return
end
