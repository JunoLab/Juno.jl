import Base: done

export ProgressBar, progress!, msg!, done, right_text!, @progress

type ProgressBar
  leftText::String
  rightText::String
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
  p = ProgressBar(name, "", id, 0.0, msg, true)
  register(p)
  p
end

"""
    register(p::ProgressBar)

Register `p` with the Juno frontend.
"""
function register(p::ProgressBar)
  isactive() && Atom.msg("progress!", "add", p)
end

"""
    done(p::ProgressBar)

Remove `p` from the frontend.
"""
function done(p::ProgressBar)
  isactive() && Atom.msg("progress!", "delete", p)
end

"""
    progress!(p::ProgressBar, prog::Number)

Update `p`'s progress. If `prog` is negative, set the progress bar to indeterminate.
"""
function progress!(p::ProgressBar, prog::Number)
  p.determinate = prog >= 0
  p.progress = clamp(prog, 0, 1)
  isactive() && Atom.msg("progress!", "update", p)
end

"""
    msg!(p::ProgressBar, m)

Update the message that will be displayed in the frontend when hovering over the
corrseponding progress bar.
"""
function msg!(p::ProgressBar, m)
  p.msg = m
  isactive() && Atom.msg("progress!", "update", p)
end

"""
    right_text!(p::ProgressBar, m)

Update the string that will be displayed to the right of the progress bar.

Defaults to the linearly extrpolated remaining time based upon the time
difference between registering a progress bar and the latest update.
"""
function right_text!(p::ProgressBar, s)
  p.rightText = s
  isactive() && Atom.msg("progress!", "update", p)
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
      end
      done(p)
    else
      $(esc(ex))
    end
  end
end

macro progress(ex)
  :(@progress "" $(esc(ex)))
end
