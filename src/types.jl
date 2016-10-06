# Displays

type Inline end
type Clipboard end

type Editor end
type Console end
type PlotPane end

render(::Clipboard, x) =
  sprint(io -> show(IOContext(io, limit=true), MIME"text/plain"(), x))

render(::Editor, x) =
  render(Inline(), Copyable(x))

render(::Console, x) =
  Atom.msg("result", render(Inline(), Copyable(x)))

render(::PlotPane, x) =
  Atom.msg("plot", render(Inline(), x))

# View data structures

type Model
  data
end

immutable Tree
  head
  children::Vector{Any}
end

immutable LazyTree
  head
  children::Function
end

immutable SubTree
  label
  child
end

limit(s::AbstractString) = length(s) ≤ 1000 ? s : s[1:1000]*"..."

type Copyable
  view
  text::String
  Copyable(view, text::String) = new(view, limit(text))
end

function Copyable(view, text)
  cp = try
    render(Clipboard(), text)
  catch e
    sprint(showerror, e, catch_backtrace())
  end
  Copyable(view, cp)
end

Copyable(view) = Copyable(view, view)

immutable Link
  file::String
  line::Int
  contents::Vector{Any}
  Link(file::AbstractString, line::Integer, contents...) =
    new(file, line, [contents...])
end

Link(file::AbstractString, contents...) = Link(file, 0, contents...)

link(a...) = Link(a...)

type Row
  xs::Vector{Any}
  Row(xs...) = new(collect(xs))
end

@render Inline l::Row begin
  span([render(Inline(), x) for x in l.xs])
end
