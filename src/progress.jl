import Base: done

export ProgressBar, progress!, msg!, name!, done, right_text!, @progress


type ProgressBar{T}
  id::String
end

"""
    ProgressBar(;name = "", msg = "")

Create a new progress bar and register it with Juno, if possible.
"""
function ProgressBar(;name = "", msg = "")
  p = ProgressBar{Val{isactive()}}(string(Base.Random.uuid1()))
  register(p)
  name!(p, name)
  msg!(p, msg)
  p
end

"""
    register(p::ProgressBar)

Register `p` with the Juno frontend.
"""
register(p::ProgressBar{Val{true}})  = Atom.msg("progress", "add", p)

register(p::ProgressBar{Val{false}}) = nothing

"""
    done(p::ProgressBar)

Remove `p` from the frontend.
"""
done(p::ProgressBar{Val{true}})  = Atom.msg("progress", "delete", p)

done(p::ProgressBar{Val{false}}) = nothing

"""
    progress!(p::ProgressBar, prog::Number)

Update `p`'s progress to `prog`.
"""
progress!(p::ProgressBar{Val{true}}, prog::Number) =
  Atom.msg("progress", "progress", p, clamp(prog, 0, 1))

progress!(p::ProgressBar{Val{false}}, prog::Number) = nothing

"""
    progress!(p::ProgressBar)

Set `p` to an indeterminate progress bar.
"""
progress!(p::ProgressBar{Val{true}})  = Atom.msg("progress", "progress")

progress!(p::ProgressBar{Val{false}}) = nothing

"""
    msg!(p::ProgressBar, m)

Update the message that will be displayed in the frontend when hovering over the
corrseponding progress bar.
"""
msg!(p::ProgressBar{Val{true}}, m)  = Atom.msg("progress", "message", p, m)

msg!(p::ProgressBar{Val{false}}, m) = nothing

"""
    name!(p::ProgressBar, m)

Update `p`s name.
"""
name!(p::ProgressBar{Val{true}}, m)  = Atom.msg("progress", "leftText", p, m)

name!(p::ProgressBar{Val{false}}, m) = nothing

"""
    right_text!(p::ProgressBar, m)

Update the string that will be displayed to the right of the progress bar.

Defaults to the linearly extrpolated remaining time based upon the time
difference between registering a progress bar and the latest update.
"""
right_text!(p::ProgressBar{Val{true}}, s)  = Atom.msg("progress", "rightText", p, s)

right_text!(p::ProgressBar{Val{false}}, s) = nothing

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
