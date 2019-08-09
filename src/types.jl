# Displays

struct Inline end
struct Clipboard end

struct Editor end
struct Console end # deprecated
struct PlotPane end

# View data structures

mutable struct Model
  data
end

struct Tree
  head
  children::Vector{Any}
end

struct LazyTree
  head
  children::Function
end

struct SubTree
  label
  child
end

limit(s::AbstractString) = length(s) ≤ 5000 ? s : s[nextind(s, 0):prevind(s, 5000)]*"..."

struct Copyable
  view
  text::String
  Copyable(view, text::String) = new(view, limit(text))
end

Copyable(view, text) = Copyable(view, render(Clipboard(), text))
Copyable(view) = Copyable(view, view)

struct Link
  file::String
  line::Int
  contents::Vector{Any}
  function Link(file::AbstractString, line::Integer, contents...)
    isempty(contents) && (contents = ("$file:$line",))
    new(file, line, [contents...])
  end
end

Link(file::AbstractString, contents...) = Link(file, 0, contents...)

link(a...) = Link(a...)

mutable struct Row
  xs::Vector{Any}
  Row(xs...) = new(collect(xs))
end

mutable struct Table
  xs::Matrix{Any}
end

"""
    defaultrepr(x, lazy = false)

`render` fallback for types without any specialized `show` methods.

If `lazy` is true, then the type's fields will be loaded lazily when expanding the tree.
This is useful when the fields contain big elements that might need to be inspectable.

Can be used by packages to restore Juno's default printing if they have defined
a `show` method that should *not* be used by Juno:
```julia
Juno.render(i::Juno.Inline, x::myType) = Juno.render(i, Juno.defaultrepr(x))
```
"""
defaultrepr(x, lazy = false) = Main.Atom.defaultrepr(x, lazy)
