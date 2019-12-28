using SnoopCompile, Pkg

@snoopiBot "Juno" begin
  using Juno

  # Use runtests.jl
  include(joinpath(dirname(dirname(pathof(Juno))), "test", "runtests.jl"))

  # Ues examples
end
