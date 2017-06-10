export selector, input, structure, @sh

"""
    selector([xs...]) -> x

Allow the user to select one of the `xs`.

`xs` should be an iterator of strings. Currently there is no fallback in other
environments.
"""
selector(xs) = Atom.selector(xs)

"""
    input(prompt = "") -> "..."

Prompt the user to input some text, and return it. Optionally display a prompt.
"""
input(prompt = "") = (print(prompt); isactive() ? Atom.input() : readline())

"""
    info(msg)

Show the given message in Juno's console using blue styling, or fall back to
`Base.info`.

In a package, you can use `import Juno: info` to replace the default version
with this one.
"""
info(msg) = (isactive() ? Atom : Base).info(msg)

"""
    notify(msg)

Display `msg` as an OS specific notification.

Useful for signaling the end of a long running computation or similar. This
disregards the `Notifications` setting in `julia-client`. Falls back to
`info(msg)` in other environments.
"""
notify(msg::AbstractString) = isactive() ? Atom.sendnotify(msg) : info(msg)

"""
    plotsize()

Get the size of Juno's plot pane in `px`. Does not yet have a fallback for
other environments.
"""
plotsize() = Atom.plotsize()

"""
    profiler()

Show currently collected profile information as an in-editor flamechart.
"""
profiler() = isactive() && Atom.Profiler.profiler()

"""
    @profiler

Clear currently collected profile traces, profile the provided expression and show
it via `Juno.profiler()`.
"""
macro profiler(exp)
  quote
    Profile.clear()
    res = @profile $(esc(exp))
    profiler()
    res
  end
end

"""
    profiletree()

Show currently collected profile information in tree-form. Falls back to `Profile.print()`.
"""
profiletree() = isactive() ? Atom.Profiler.tree() : Profile.print()

"""
    structure(x)

Display `x`'s underlying representation, rather than using its normal display
method.

For example, `structure(:(2x+1))` displays the `Expr` object with its
`head` and `args` fields instead of printing the expression.
"""
function structure(x)
  fields = fieldnames(typeof(x))
  if isempty(fields)
    isbits(x) ?
      Row(typeof(x), Text(" "), x) :
      Row(typeof(x), Text("()"))
  else
    LazyTree(typeof(x), () -> [SubTree(Text("$f → "), structure(getfield′(x, f))) for f in fields])
  end
end

structure(xs::Vector) =
  Tree(Row(eltype(xs), fade("[$(length(xs))]")),
       [isassigned(xs, i) ? structure(xs[i]) : UNDEF for i = 1:length(xs)])

structure(s::Symbol) = s
structure(s::Ptr) = s
structure(s::String) = s
# TODO: do this recursively
structure(x::Array) = x

macro sh(ex)
  quote
    result = $(esc(ex))
    display(Row($(Expr(:quote, ex)), text" = ", result))
    result
  end
end
