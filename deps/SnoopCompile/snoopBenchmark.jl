# dev your package

# comment the precompile part of your package ("include() and _precompile_()")
# run this benchmark
# restart Julia

# uncomment the precompile part of your package ("include() and _precompile_()")
# run this benchmark
# restart Julia

# now compare the result
################################################################
using SnoopCompile, Pkg

println("Package load time:")
loadSnoop = @snoopi using Juno

timesum(loadSnoop)

################################################################
println("Running Examples/Tests:")
runSnoop = @snoopi begin

using Juno

Pkg.test("Juno")

end

timesum(runSnoop)
