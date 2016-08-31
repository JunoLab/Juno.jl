# Displays

type Inline end
type Clipboard end

type Editor end
type Console end

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
