import Base: MethodList

stripparams(t) = replace(t, r"\{([A-Za-z, ]*?)\}", "")

function methodarray(mt::MethodList)
  defs = collect(mt)
  file(m) = m.file |> string |> basename
  line(m) = m.line
  sort!(defs, lt = (a, b) -> file(a) == file(b) ?
                               line(a) < line(b) :
                               file(a) < file(b))
  return defs
end

methodarray(x) = methodarray(methods(x))

interpose(xs, y) = map(i -> iseven(i) ? xs[i÷2] : y, 2:2length(xs))

function view(m::Method)
  tv, decls, file, line = Base.arg_decl_parts(m)
  params = [span(c(x, isempty(T) ? "" : "::", strong(stripparams(T)))) for (x, T) in decls[2:end]]
  params = interpose(params, ", ")
  span(c(string(m.name),
         "(", params..., ")")),
  file == :null ? "not found" : Atom.baselink(string(file), line)
end

@render i::Inline m::Method begin
  sig, link = view(m)
  r(x) = render(i, x)
  span(c(r(sig), " at ", r(link)))
end

# TODO: factor out table view
@render i::Inline m::MethodList begin
  ms = methodarray(m)
  isempty(ms) && return "$(m.mt.name) has no methods."
  r(x) = render(i, x)
  length(ms) == 1 && return r(ms[1])
  Tree(span(c(span(".syntax--support.syntax--function", string(m.mt.name)),
              " has $(length(ms)) methods:")),
       [table(".syntax--methods", [tr(td(c(r(a))), td(c(r(b)))) for (a, b) in map(view, ms)])])
end
