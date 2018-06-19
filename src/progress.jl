export @progress

using Logging: @logmsg

const PROGRESSLEVEL = -1

"""
    progress(f::Function; name = "", msg = "")

Evaluates `f` with `id` as its argument and makes sure to destroy the progress
bar afterwards. To update the progress bar in `f` you can call a logging statement
like `@info` or even just `@logmsg` with `_id=id` and `progress` as arguments.

`progress` can take either of the following values:
  - `0 <= progress < 1`: create or update progress bar
  - `progress == nothing || progress = NaN`: set progress bar to indeterminate progress
  - `progress > 1 || progress == "done"`: destroy progress bar

The logging message (e.g. `"foo"` in `@info "foo"`) will be used as the progress
bar's name.

```julia
Juno.progress() do id
    for i = 1:10
        sleep(0.5)
        @info "iterating" progress=i/10 _id=id
    end
end
```
"""
function progress(f; name = "")
  _id = gensym()
  @logmsg PROGRESSLEVEL name progress=NaN _id=_id
  try
    f(_id)
  finally
    @logmsg PROGRESSLEVEL name progress="done" _id=_id
  end
end

"""
    @progress [name] for i = ...

Show a progress metre for the given loop if possible.
"""
macro progress(args...)
  _progress(args...)
end

_progress(ex) = _progress("", 0.005, ex)
_progress(name::AbstractString, ex) = _progress(name, 0.005, ex)
_progress(thresh::Real, ex) = _progress("", thresh, ex)

function _progress(name, thresh, ex)
  if ex.head == :for &&
     ex.args[1].head == Symbol("=") &&
     ex.args[2].head == :block
    x = esc(ex.args[1].args[1])
    range = esc(ex.args[1].args[2])
    body = esc(ex.args[2])
    _id = "progress_$(gensym())"
    quote
      if isactive()
        @logmsg($PROGRESSLEVEL, $name, progress=0.0, _id=Symbol($_id))
        try
          lastfrac = 0.0
          range = $range
          n = length(range)
          for (i, $x) in enumerate(range)
            $body

            frac = i/n
            if frac - lastfrac > $thresh
              @logmsg($PROGRESSLEVEL, $name, progress=frac, _id=Symbol($_id))
              lastfrac = frac
            end
          end
        finally
          @logmsg($PROGRESSLEVEL, $name, progress="done", _id=Symbol($_id))
        end
      else
        $(esc(ex))
      end
    end
  else
    error("@progress requires a for loop")
  end
end
