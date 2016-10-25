export selector, input, @progress, structure

"""
    selector([xs...]) -> x

Allow the user to select one of the `xs`.

`xs` should be an iterator of strings. Currently there is no fallback in other
environments.
"""
selector(xs) = Atom.selector(xs)

"""
    input() -> "..."

Prompt the user to input some text, and return it.
"""
input() = isactive() ? Atom.input() : readline()

"""
    info(msg)

Show the given message in Juno's console using blue styling, or fall back to
`Base.info`.

In a package, you can use `import Juno: info` to replace the default version
with this one.
"""
info(msg) = (isactive() ? Atom : Base).info(msg)

"""
    @progress for i = ...

Show a progress metre for the given loop if possible.
"""
macro progress(ex)
  @capture(ex, for x_ in range_ body_ end) ||
    error("@progress requires a for loop")
  @esc x range body
  quote
    if isactive()
      range = $range
      n = length(range)
      for (i, $x) in enumerate(range)
        $body
        Atom.progress(i/n)
      end
    else
      $(esc(ex))
    end
  end
end

plotsize() = Atom.plotsize()

"""
    structure(x)

Display `x`'s underlying representation, rather than using its normal display
method. For example, `structure(:(2x+1))` displays the `Expr` object with its
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

structure(x::Vector) = Tree(Row(eltype(x), fade("[$(length(x))]")), structure.(x))
structure(s::Symbol) = s
structure(s::Ptr) = s
# TODO: do this recursively
structure(x::Array) = x
