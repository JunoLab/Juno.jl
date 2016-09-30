using Hiccup

c(a...) = Any[a...]

fade(x) = span(".fade", x)

icon(x) = span(".icon.icon-$x", [])

function interleave(xs::Vector, j)
  ys = []
  for x in xs
    push!(ys, x, j)
  end
  pop!(ys)
  return ys
end
