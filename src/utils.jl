using Hiccup

c(a...) = Any[a...]

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
