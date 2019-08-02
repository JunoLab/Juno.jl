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
_progress(name::Union{AbstractString, Expr}, ex) = _progress(name, 0.005, ex)
_progress(thresh::Real, ex) = _progress("", thresh, ex)

function _progress(name, thresh, ex)
  if ex.head == Symbol("=") &&
        ex.args[2].head == :comprehension &&
        ex.args[2].args[1].head == :generator
    # comprehension: <target> = [<body> for <iter_var> in <range>,...]
    loop = _comprehension
    target = esc(ex.args[1])
    result = target
    gen_ex = ex.args[2].args[1]
    body = esc(gen_ex.args[1])
    iter_exprs = gen_ex.args[2:end]
    iter_vars = [e.args[1] for e in iter_exprs]
    ranges = [e.args[2] for e in iter_exprs]
  elseif ex.head == :for &&
        ex.args[1].head == Symbol("=") &&
        ex.args[2].head == :block
    # single-variable for: for <iter_var> = <range>; <body> end
    loop = _for
    target = :_
    result = :nothing
    iter_vars = [ex.args[1].args[1]]
    ranges = [ex.args[1].args[2]]
    body = esc(ex.args[2])
  elseif ex.head == :for &&
        ex.args[1].head == :block &&
        ex.args[2].head == :block
    # multi-variable for: for <iter_var> = <range>,...; <body> end
    loop = _for
    target = :_
    result = :nothing
    # iter_vars and ranges are ordered from inner loop to outer loop, for
    # consistent computation of progress between for loops and comprehensions
    iter_vars = reverse([e.args[1] for e in ex.args[1].args])
    ranges = reverse([e.args[2] for e in ex.args[1].args])
    body = esc(ex.args[2])
  else
    error("@progress requires a for loop (for i in irange, j in jrange, ...; <body> end) " *
          "or array comprehension with assignment (x = [<body> for i in irange, j in jrange, ...])")
  end
  _progress(name, thresh, ex, target, result, loop, iter_vars, ranges, body)
end

function _progress(name, thresh, ex, target, result, loop, iter_vars, ranges, body)
  count_vars = [Symbol("i$k") for k=1:length(iter_vars)]
  iter_exprs = [:(($i,$(esc(v))) = enumerate($(esc(r))))
                  for (i,v,r) in zip(count_vars,iter_vars,ranges)]
  _id = "progress_$(gensym())"
  quote
    if isactive()
      @logmsg($PROGRESSLEVEL, $(esc(name)), progress=0.0, _id=Symbol($_id))
      $target = try
        ranges = $(Expr(:vect,esc.(ranges)...))
        nranges = length(ranges)
        lens = length.(ranges)
        n = prod(lens)
        strides = cumprod([1;lens[1:end-1]])
        _frac(i) = (sum((i-1)*s for (i,s) in zip(i,strides)) + 1) / n
        lastfrac = 0.0


        $(loop(iter_exprs,
            quote
                val = $body
                frac = _frac($(Expr(:vect, count_vars...)))
                if frac - lastfrac > $thresh
                    @logmsg($PROGRESSLEVEL, $(esc(name)), progress=frac, _id=Symbol($_id))
                    lastfrac = frac
                end
                val
            end
        ))

      finally
        @logmsg($PROGRESSLEVEL, $(esc(name)), progress="done", _id=Symbol($_id))
      end
      $result
    else
      $(esc(ex))
    end
  end
end

_comprehension(iter_exprs, body,) = Expr(:comprehension, Expr(:generator, body, iter_exprs...))
_for(iter_exprs, body) = Expr(:for, Expr(:block, reverse(iter_exprs)...), body)
