using Hiccup

fade(x) = span(".fade", x)

icon(x) = span(".icon.icon-$x", [])

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
