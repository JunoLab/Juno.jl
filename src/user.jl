export @enter, breakpoint
"""
    @enter ex

Step into the function call in `ex`.
"""
macro enter(ex)
  @capture(ex, f_(args__)) || error("Syntax: @enter f(...)")
  :(Atom.Debugger.@enter($(ex)))
end

breakpoint(args...) = Atom.breakpoint(args...)

function connect(args...; kws...)
  activate()
  eval(:(Atom.connect($args...; $kws...)))
  return
end
