export @enter, breakpoint
"""
    @enter ex

Step into the function call in `ex`.
"""
macro enter(ex)
  Atom.enter(ex)
end

breakpoint(args...) = Atom.breakpoint(args...)

function connect(args...; kws...)
  activate()
  eval(:(Atom.connect($args...; $kws...)))
  return
end
