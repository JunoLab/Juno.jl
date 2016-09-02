# Displays

type Inline end
type Clipboard end

type Editor end
type Console end
type PlotPane end

render(::Clipboard, x) = stringmime(MIME"text/plain"(), x)

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

immutable SubTree
  label
  child
end

type Copyable
  view
  text::String
  Copyable(view, text::AbstractString) = new(view, text)
end

Copyable(view, text) = Copyable(view, render(Clipboard(), text))
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
