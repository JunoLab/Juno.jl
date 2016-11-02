import Base: done

export ProgressBar, progress, progress!, msg!, name!, done, right_text!, @progress


type ProgressBar
  id::String
end

"""
    ProgressBar(;name = "", msg = "")

Create a new progress bar and register it with Juno, if possible.

Take care to unregister the progress bar by calling `done` on it, or use the
`progress(f::Function)` syntax, which will handle that automatically.
"""
function ProgressBar(;name = "", msg = "")
  p = ProgressBar(string(Base.Random.uuid1()))
  register(p)
  name!(p, name)
  msg!(p, msg)
  p
end

"""
    register(p::ProgressBar)

Register `p` with the Juno frontend.
"""
register(p::ProgressBar) = isactive() && Atom.msg("progress", "add", p)

"""
    done(p::ProgressBar)

Remove `p` from the frontend.
"""
done(p::ProgressBar) = isactive() && Atom.msg("progress", "delete", p)

"""
    progress!(p::ProgressBar, prog::Number)

Update `p`'s progress to `prog`.
"""
progress!(p::ProgressBar, prog::Number) =
  isactive() && Atom.msg("progress", "progress", p, clamp(prog, 0, 1))

"""
    progress!(p::ProgressBar)

Set `p` to an indeterminate progress bar.
"""
progress!(p::ProgressBar) = isactive() && Atom.msg("progress", "progress")

"""
    progress(f::Function; name = "", msg = "")

Evaluates `f` with `ProgressBar(name = name, msg = msg)` as the argument and
calls `done` on it afterwards. This is guaranteed to clean the progress bar up,
even if `f` errors.
"""
function progress(f::Function; name = "", msg = "")
  p = ProgressBar(name = name, msg = msg)
  try
    f(p)
  finally
    done(p)
  end
end

"""
    msg!(p::ProgressBar, m)

Update the message that will be displayed in the frontend when hovering over the
corrseponding progress bar.
"""
msg!(p::ProgressBar, m) = isactive() && Atom.msg("progress", "message", p, m)

"""
    name!(p::ProgressBar, m)

Update `p`s name.
"""
name!(p::ProgressBar, m) =
  isactive() && Atom.msg("progress", "leftText", p, m)

"""
    right_text!(p::ProgressBar, m)

Update the string that will be displayed to the right of the progress bar.

Defaults to the linearly extrpolated remaining time based upon the time
difference between registering a progress bar and the latest update.
"""
right_text!(p::ProgressBar, s) =
  isactive() && Atom.msg("progress", "rightText", p, s)

"""
    @progress [name] for i = ...

Show a progress metre for the given loop if possible.
"""
macro progress(args...)
  _progress(args...)
end

function _progress(ex)
  _progress("", ex)
end

function _progress(name, ex)
  @capture(ex, for x_ in range_ body_ end) ||
    error("@progress requires a for loop")
  @esc x range body
  quote
    if isactive()
      p = ProgressBar(name = $name)
      try
        range = $range
        n = length(range)
        for (i, $x) in enumerate(range)
          $body
          progress!(p, i/n)
        end
      finally
        done(p)
      end
    else
      $(esc(ex))
    end
  end
end
