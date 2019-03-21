export selector, clearconsole, input, structure, @sh, @profiler

"""
    selector([xs...]) -> x

Allow the user to select one of the `xs`.

`xs` should be an iterator of strings. Currently there is no fallback in other
environments.
"""
selector(xs) = Main.Atom.selector(xs)

"""
    clearconsole()

Clear the console if Juno is used; does nothing otherwise.
"""
clearconsole() = isactive() && Main.Atom.clearconsole()

"""
    input(prompt = "") -> "..."

Prompt the user to input some text, and return it. Optionally display a prompt.
"""
input(prompt = "") = (print(prompt); isactive() ? Main.Atom.input() : readline())

"""
    info(msg)

Show the given message in Juno's console using blue styling, or fall back to
`Base.info`.

In a package, you can use `import Juno: info` to replace the default version
with this one.
"""
info(msg) = (isactive() ? Main.Atom : Base).info(msg)

"""
    notify(msg)

Display `msg` as an OS specific notification.

Useful for signaling the end of a long running computation or similar. This
disregards the `Notifications` setting in `julia-client`. Falls back to
`info(msg)` in other environments.
"""
notify(msg::AbstractString) = isactive() ? Main.Atom.sendnotify(msg) : @info(msg)

"""
    plotsize()

Get the size of Juno's plot pane in `px`. Returns `[100, 100]` as a fallback value.
"""
plotsize() = isactive() ? Main.Atom.plotsize() : [100, 100]

"""
    syntaxcolors(selectors = Atom.SELECTORS)::Dict{String, UInt32}

Get the colors used by the current Atom theme.
`selectors` should be a `Dict{String, Vector{String}}` which assigns a css
selector (e.g. `syntax--julia`) to a name (e.g. `variable`).
"""
syntaxcolors(selectors) = isactive() ? Main.Atom.syntaxcolors(selectors) : Dict{String, UInt32}()
syntaxcolors() = isactive() ? Main.Atom.syntaxcolors() : Dict{String, UInt32}()


"""
    profiler()

Show currently collected profile information as an in-editor flamechart.
"""
profiler() = isactive() && Main.Atom.Profiler.profiler()

"""
    @profiler

Clear currently collected profile traces, profile the provided expression and show
it via `Juno.profiler()`.
"""
macro profiler(exp)
  quote
    $(Profile).clear()
    res = $(Profile).@profile $(esc(exp))
    profiler()
    res
  end
end

"""
    profiletree()

Show currently collected profile information in tree-form. Falls back to `Profile.print()`.
"""
profiletree() = isactive() ? Main.Atom.Profiler.tree() : Profile.print()

"""
    structure(x)

Display `x`'s underlying representation, rather than using its normal display
method.

For example, `structure(:(2x+1))` displays the `Expr` object with its
`head` and `args` fields instead of printing the expression.
"""
structure(args...) = Main.Atom.structure(args...)
