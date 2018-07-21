export @enter, breakpoint
"""
    @enter ex

Step into the function call in `ex`.
"""
macro enter(ex)
  Main.Atom.enter(ex)
end

breakpoint(args...) = Main.Atom.breakpoint(args...)

function connect(args...; kws...)
  activate()
  eval(:(Main.Atom.connect($args...; $kws...)))
  return
end
