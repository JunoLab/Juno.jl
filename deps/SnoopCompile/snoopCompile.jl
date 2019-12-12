using SnoopCompile

@snoopiBot "Juno" begin
  using Juno, Pkg

  # Use runtests.jl
  include(joinpath(dirname(dirname(pathof(Juno))), "test", "runtests.jl"))

  # Ues examples
end
