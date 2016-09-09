export @step, breakpoint

macro step(args...)
  :(Atom.Debugger.@step($(map(esc, args)...)))
end

breakpoint(args...) = Atom.Debugger.breakpoint(args...)
