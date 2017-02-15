using Hiccup

view(x) =
  Dict(:type    => :html,
       :content => stringmime(MIME"text/html"(), x))

render(e::Editor, ::Void) =
  render(e, Atom.icon("check"))

render(::Console, ::Void) = nothing

render(::Inline, x::AbstractFloat) =
  isnan(x) || isinf(x) ?
    view(span(".syntax--constant.syntax--number", string(x))) :
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

@render Inline x::Text begin
  ls = split(chomp(string(x)), "\n")
  length(ls) > 1 ?
    Tree(Model(ls[1]), c(Model(join(ls[2:end], "\n")))) :
    span(ls[1])
end

getfield′(x, f) = isdefined(x, f) ? getfield(x, f) : UNDEF

showmethod(T) = which(show, (IO, T))

@render Inline x begin
  fields = fieldnames(typeof(x))
  if showmethod(typeof(x)) ≠ showmethod(Any)
    Text(io -> show(IOContext(io, limit = true), x))
  elseif isempty(fields)
    span(c(render(Inline(), typeof(x)), "()"))
  else
    LazyTree(typeof(x), () -> [SubTree(Text("$f → "), getfield′(x, f)) for f in fields])
  end
end

typ(x) = span(".syntax--support.syntax--type", x)

@render Inline x::Type typ(string(x))

for A in :[Vector, Matrix, AbstractVector, AbstractMatrix].args
  @eval begin
    render(i::Inline, ::Type{$A}) =
      render(i, typ($(string(A))))
    render{T}(i::Inline, ::Type{$A{T}}) =
      render(i, typ(string($(string(A)), "{$T}")))
  end
end

@render Inline x::Module span(".syntax--keyword.syntax--other", string(x))

@render Inline x::Symbol span(".syntax--constant.syntax--other.syntax--symbol", ":$x")

@render Inline x::Char span(".syntax--string.syntax--quoted.syntax--single", escape_string("'$x'"))

@render Inline x::VersionNumber span(".syntax--string.syntax--quoted.syntax--other", sprint(show, x))

@render Inline _::Void span(".syntax--constant", "nothing")

import Base.Docs: doc

isanon(f) = contains(string(f), "#")

@render Inline f::Function begin
  isanon(f) ? span(".syntax--support.syntax--function", "λ") :
    LazyTree(span(".syntax--support.syntax--function", string(typeof(f).name.mt.name)),
             ()->[(Atom.CodeTools.hasdoc(f) ? [doc(f)] : [])..., methods(f)])
end

# TODO: lazy load a recursive tree
trim(xs, len = 25) =
  length(xs) ≤ 25 ? undefs(xs) :
                    [undefs(xs[1:10]); fade("..."); undefs(xs[end-9:end])]

@render i::Inline xs::Vector begin
    Tree(span(c(render(i, eltype(xs)), Atom.fade("[$(length(xs))]"))), trim(xs))
end

@render Inline xs::AbstractArray begin
  Text(sprint(io -> show(IOContext(io, limit=true), MIME"text/plain"(), xs)))
end

@render i::Inline d::Dict begin
  j = 0
  st = Array{Atom.SubTree}(0)
  for (key, val) in d
    push!(st, SubTree(span(c(render(i, key), " → ")), val))
    j += 1
    j > 25 && (push!(st, SubTree(span("... → "), span("..."))); break)
  end
  Tree(span(c(strong("Dict"),
            Atom.fade(" $(eltype(d).parameters[1]) → $(eltype(d).parameters[2]) with $(length(d)) entries"))), st)
end

@render Inline x::Number span(".syntax--constant.syntax--number", sprint(show, x))

@render i::Inline x::Complex begin
  re, ima = reim(x)
  span(c(render(i, re), signbit(ima) ? " - " : " + ", render(i, abs(ima)), "im"))
end

@render Inline p::Ptr begin
  Row(Atom.fade(string(typeof(p))), Text(" @"),
       span(".syntax--constant.syntax--number", c("0x$(hex(UInt(p), Sys.WORD_SIZE>>2))")))
end

@render i::Inline x::AbstractString begin
  length(x) ≤ 100 ?
    span(".syntax--string", c(render(i, Text(stringmime("text/plain", x))))) :
    Row(span(".syntax--string", c("\"", render(i, Text(io -> unescape_string(io, x[1:100]))))),
        Text("..."))
end

@static if VERSION < v"0.6.0-dev.615"
  @render Inline li::LambdaInfo begin
    out = split(sprint(show, MIME"text/plain"(), li), '\n', limit=2)
    Tree(Text(out[1]),
         [Model(Dict(:type => :code, :text => out[2]))])
  end
end

render{sym}(i::Inline, x::Irrational{sym}) =
  render(i, span(c(string(sym), " = ", render(i, float(x)), "...")))

@render i::Inline xs::Tuple begin
  span(c("(", interpose(map(x->render(i, x), xs), ", ")..., ")"))
end

@render i::Inline md::Base.Markdown.MD begin
  mds = Atom.CodeTools.flatten(md)
  length(mds) == 1 ? Text(chomp(sprint(show, MIME"text/markdown"(), md))) :
                     Tree(Text("MD"), [HTML(sprint(show, MIME"text/html"(), md))])
end

include("methods.jl")
