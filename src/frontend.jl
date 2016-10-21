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

import Base: done

type ProgressBar
  name::String
  id::String
  progress::Float64
  msg::String
  determinate::Bool
end

"""
    ProgressBar(;name = "", msg = "")

Create a new progress bar and register it with Juno, if possible.
"""
function ProgressBar(;name = "", msg = "")
  id = randstring(10)
  p = ProgressBar(name, id, 0.0, msg, false)
  register(p)
  p
end

"""
    register(p::ProgressBar)

Register `p` with the Juno frontend.
"""
function register(p::ProgressBar)
  Juno.isactive() && Atom.msg("progress!", "add", p)
end

"""
    done(p::ProgressBar)

Remove `p` from the frontend.
"""
function done(p::ProgressBar)
  Atom.msg("progress!", "delete", p)
end

"""
    progress!(p::ProgressBar, prog::Number)

Update `p`'s progress. If `prog` is negative, set the progress bar to indeterminate.
"""
function progress!(p::ProgressBar, prog::Number)
  p.determinate = prog > 0
  p.progress = clamp(prog, 0, 1)
  Atom.msg("progress!", "update", p)
end

"""
    msg!(p::ProgressBar, m)

Update the message that will be displayed in the frontend when hovering over the
corrseponding progress bar.
"""
function msg!(p::ProgressBar, m)
  p.msg = msg
  Atom.msg("progress!", "update", p)
end

"""
    @progress [name] for i = ...

Show a progress metre for the given loop if possible.
"""
macro progress(name, ex)
  @capture(ex, for x_ in range_ body_ end) ||
    error("@progress requires a for loop")
  @esc x range body
  quote
    if isactive()
      p = ProgressBar(name = $name)
      range = $range
      n = length(range)
      for (i, $x) in enumerate(range)
        $body
        progress!(p, i/n)
        @show p
      end
      done(p)
    else
      $(esc(ex))
    end
  end
end

macro progress(ex)
  :(@progress "" $ex)
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
structure(s::String) = s
# TODO: do this recursively
structure(x::Array) = x
