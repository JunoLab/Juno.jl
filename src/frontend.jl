export selector, input, @progress

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
