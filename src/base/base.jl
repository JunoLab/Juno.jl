# Editor-specific

render(e::Editor, ::Void) =
  render(e, icon("check"))

render(::Editor, x) =
  render(Inline(), Copyable(x))

# Console-specific

render(::Console, x) =
  Atom.msg("result", render(Inline(), Copyable(x)))

render(::Console, ::Void) = nothing

# Clipboard-specific

render(::Clipboard, x) = stringmime(MIME"text/plain"(), x)

# Objects

render(::Inline, x::AbstractFloat) =
  isnan(x) || isinf(x) ?
    view(span(".constant.number", string(x))) :
    Dict(:type => :number, :value => Float64(x), :full => string(x))

@render Inline x::Expr begin
  text = string(x)
  length(split(text, "\n")) == 1 ?
    Model(Dict(:type => :code, :text => text)) :
    Tree(Text("Code"),
         [Model(Dict(:type => :code, :text => text))])
end

render(::Console, x::Expr) =
  Atom.msg("result", Dict(:type => :code, :text => string(x)))
