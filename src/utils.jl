fade(x::String) = HTML("<span class=\"fade\">$x</span>")

icon(x::String) = HTML("<span class=\"icon icon-$x\"></span>")

function interleave(xs, j)
  ys = []
  for x in xs
    push!(ys, x, j)
  end
  isempty(xs) || pop!(ys)
  return ys
end

dims(xs...) = Row(interleave(xs, fade("×"))...)

const UNDEF = fade("#undef")

function undefs(xs)
  xs′ = similar(xs, Any)
  for i in eachindex(xs)
    xs′[i] = isassigned(xs, i) ? xs[i] : UNDEF
  end
  return xs′
end

errtrace(e, trace) = trace

errmsg(e) = sprint(io -> showerror(IOContext(io, :limit => true), e))

view(x) =
  Dict(:type    => :html,
       :content => stringmime(MIME"text/html"(), x))
