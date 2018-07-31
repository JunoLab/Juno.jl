export @progress

"""
    ProgressBar(;name = "", msg = "")

Create a new progress bar and register it with Juno, if possible.

Take care to unregister the progress bar by calling `done` on it, or use the
`progress(f::Function)` syntax, which will handle that automatically.
"""
function ProgressBar(;args...)
  isactive() && Atom.Progress.ProgressBar(;args...)
end

"""
    register(p::ProgressBar)

Register `p` with the Juno frontend.
"""
register(p) = isactive() && Atom.Progress.register(p)

"""
    done(p::ProgressBar)

Remove `p` from the frontend.
"""
done(p) = isactive() && Atom.Progress.done(p)

"""
    progress(p::ProgressBar, prog::Number)

Update `p`'s progress to `prog`.
"""
progress(p, prog::Real) = isactive() && Atom.Progress.progress(p, prog)

"""
    progress(p::ProgressBar)

Set `p` to an indeterminate progress bar.
"""
progress(p) = isactive() && Atom.Progress.progress(p)

"""
    progress(f::Function; name = "", msg = "")

Evaluates `f` with `p = ProgressBar(name = name, msg = msg)` as the argument and
calls `done(p)` afterwards. This is guaranteed to clean up the progress bar,
even if `f` errors.
"""
progress(f::Function; name = "", msg = "") = isactive() && Atom.Progress.progress(f; name = name, msg = msg)

"""
    msg(p::ProgressBar, m)

Update the message that will be displayed in the frontend when hovering over the
corrseponding progress bar.
"""
msg(p, m) = isactive() && Atom.Progress.msg(p, m)

"""
    name(p::ProgressBar, m)

Update `p`s name.
"""
name(p, s) = isactive() && Atom.Progress.name(p, s)

"""
    right_text(p::ProgressBar, m)

Update the string that will be displayed to the right of the progress bar.

Defaults to the linearly extrapolated remaining time based upon the time
difference between registering a progress bar and the latest update.
"""
right_text(p, s) = isactive() && Atom.Progress.right_text(p, s)

"""
    @progress [name="", threshold=0.005] for i = ..., j = ..., ...
    @progress [name="", threshold=0.005] x = [... for i = ..., j = ..., ...]

Show a progress meter named `name` for the given loop or array comprehension
if possible. Update frequency is limited by `threshold` (one update per 0.5% of
progress by default).
"""
macro progress(args...)
  _progress(args...)
end

_progress(ex) = _progress("", 0.005, ex)
_progress(name::AbstractString, ex) = _progress(name, 0.005, ex)
_progress(thresh::Real, ex) = _progress("", thresh, ex)

function _progress(name, thresh, ex)
  if ex.head == Symbol("=") &&
        ex.args[2].head == :comprehension &&
        ex.args[2].args[1].head == :generator
    # comprehension: <target> = [<body> for <iter_var> in <range>,...]
    target = esc(ex.args[1])
    gen_ex = ex.args[2].args[1]
    body = esc(gen_ex.args[1])
    iter_exprs = gen_ex.args[2:end]
    iter_vars = [e.args[1] for e in iter_exprs]
    ranges = [e.args[2] for e in iter_exprs]
  elseif ex.head == :for &&
        ex.args[1].head == Symbol("=") &&
        ex.args[2].head == :block
    # single-variable for: for <iter_var> = <range>; <body> end
    target = Symbol("_")
    iter_vars = [ex.args[1].args[1]]
    ranges = [ex.args[1].args[2]]
    body = esc(ex.args[2])
  elseif ex.head == :for &&
        ex.args[1].head == :block &&
        ex.args[2].head == :block
    # multi-variable for: for <iter_var> = <range>,...; <body> end
    target = Symbol("_")
    iter_vars = [e.args[1] for e in ex.args[1].args]
    ranges = [e.args[2] for e in ex.args[1].args]
    body = esc(ex.args[2])
  else
    error("@progress requires a for loop or comprehension")
  end
  _progress(name, thresh, ex, target, iter_vars, ranges, body)
end

function _progress(name, thresh, ex, target, iter_vars, ranges, body)
  iter_exprs = [:(($(Symbol("i$k")),$(esc(v))) = enumerate($(esc(r))))
                  for (k,(v,r)) in enumerate(zip(iter_vars,ranges))]
  var_array_ex = Expr(:vect, (esc(v) for v in iter_vars)...)
  quote
    if isactive()
      p = ProgressBar(name = $name)
      progress(p, 0)
      try
        ranges = $(Expr(:vect,ranges...))
        nranges = length(ranges)
        lens = length.(ranges)
        n = prod(lens)
        strides = cumprod([1;lens[1:end-1]])
        _frac(i) = (sum((i-1)*s for (i,s) in zip(i,strides)) + 1) / n
        lastfrac = 0.0
        function _update(frac,lastfrac)
          if frac - lastfrac > $thresh
            progress(p, frac)
            lastfrac = frac
          end
          lastfrac
        end

        $target = $(Expr(:comprehension, Expr(:generator,
                            quote
                              lastfrac = _update(_frac($var_array_ex),lastfrac)
                              $body
                            end,
                            iter_exprs...
                         )))
      finally
        done(p)
      end
    else
      $(esc(ex))
    end
  end
end
