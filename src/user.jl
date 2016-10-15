export @step, breakpoint

macro step(ex)
  @capture(ex, f_(args__)) || error("Syntax: @step f(...)")
  :(Atom.step($(esc(f)), $(map(esc, args)...)))
end

breakpoint(args...) = Atom.breakpoint(args...)

function connect(port)
  activate()
  Atom.connect(port)
  return
end
