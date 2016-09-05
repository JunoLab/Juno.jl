using Hiccup
c(a...) = Any[a...]

render(e::Editor, ::Void) =
  render(e, Atom.icon("check"))

render(::Console, ::Void) = nothing

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

@render Inline x::Text begin
  ls = split(chomp(string(x)), "\n")
  length(ls) > 1 ?
    Tree(Model(ls[1]), c(Model(join(ls[2:end], "\n")))) :
    span(ls[1])
end

@render Inline x begin
  fields = fieldnames(typeof(x))
  if isempty(fields)
    span(c(render(Inline(), typeof(x)), "()"))
  else
    LazyTree(typeof(x), () -> [SubTree(Text("$f → "), getfield(x, f)) for f in fields])
  end
end

@render Inline x::Type span(".support.type", string(x))

@render Inline x::Module span(".keyword.other", string(x))

import Base.Docs: doc

isanon(f) = contains(string(f), "#")

@render Inline f::Function begin
  isanon(f) ? span(".support.function", "λ") :
    Tree(span(".support.function", string(typeof(f).name.mt.name)),
         [(Atom.CodeTools.hasdoc(f) ? [doc(f)] : [])..., methods(f)])
end

@render i::Inline xs::Vector begin
  length(xs) <= 25 ? children = handleundefs(xs) :
                     children = [handleundefs(xs, 1:10); span("..."); handleundefs(xs, length(xs)-9:length(xs))]
    Tree(span(c(render(i, eltype(xs)), Atom.fade("[$(length(xs))]"))),
         children)
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

@render Inline x::Number span(".constant.number", sprint(show, x))

@render i::Inline x::Complex begin
  span(c(render(i, real(x)), " + ", render(i, imag(x)), "im"))
end

@render i::Inline x::AbstractString begin
  span(".string", c(render(i, Text(stringmime("text/plain", x)))))
end

render{sym}(i::Inline, x::Irrational{sym}) =
  render(i, span(c(string(sym), " = ", render(i, float(x)), "...")))

handleundefs(X::Vector) = handleundefs(X, 1:length(X))

function handleundefs(X::Vector, inds)
  Xout = Vector{Union{String, eltype(X)}}(length(inds))
  j = 1
  for i in inds
    Xout[j] = isdefined(X, i) ? X[i] : "#undef"
    j += 1
  end
  Xout
end

@render i::Inline xs::Tuple begin
  span(c("(", interpose(map(x->render(i, x), xs), ", ")..., ")"))
end

@render i::Inline md::Base.Markdown.MD begin
  mds = Atom.CodeTools.flatten(md)
  length(mds) == 1 ? Text(chomp(sprint(show, MIME"text/markdown"(), md))) :
                     Tree(Text("MD"), [HTML(sprint(show, MIME"text/html"(), md))])
end

include("methods.jl")
