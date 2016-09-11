export selector, input, @progress, progress

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

Show a progress meter for the given loop if possible.
"""
macro progress(ex)
  @capture(ex, for x_ in range_ body_ end) ||
    error("@progress requires a for loop")
  @esc x range body
  quote
    file = @__FILE__
    if isactive()
      range = $range
      n = length(range)
      t_0 = time()
      for (i, $x) in enumerate(range)
        $body
        progress(i, n, time() - t_0, file)
      end
    else
      $(esc(ex))
    end
  end
end

"""
    progress(x = [0..1])

Set Atom's progress bar to the given value.
"""
progress(x::Void = nothing) = Atom.msg("progress", "indeterminate")

progress(x::Real) =
  Atom.msg("progress", (x < 0.01 ? nothing :
                        x > 1 ? 1 :
                        x))

"""
    progress(i, n, t_elapsed, [file])

Set Atom's progress bar to `i/n` and calculate the remaining time from `t_elapsed`.
If the `file` argument is provided, the progress bar will be linked to said file.
"""
function progress(i, n, Δt, file)
  (prog, t) = _progress(i, n, Δt)
  Atom.msg("progress", prog, "$t remaining @ $file", file)
end

function progress(i, n, Δt)
  (prog, t) = _progress(i, n, Δt)
  Atom.msg("progress", prog, "$t remaining")
end

function _progress(i, n, Δt)
  remaining = Δt/i*(n-i)
  h = Base.div(remaining, 60*60)
  m = Base.div(remaining -= h*60*60, 60)
  s = remaining - m*60
  t = @sprintf "%u:%02u:%02u" h m s

  prog = i/n < 0.1 ? "indeterminate" :
         i/n >   1 ?               1 :
         i/n
  (prog, t)
end
