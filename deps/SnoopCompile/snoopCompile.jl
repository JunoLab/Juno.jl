using SnoopCompile

cd(@__DIR__)

### Log the compiles
# This only needs to be run once (to generate Juno.log)

# SnoopCompile.@snoopc LogPath begin
SnoopCompile.@snoopc "$(pwd())/Juno.log" begin
    using Juno, Pkg
    include(joinpath(dirname(dirname(pathof(Juno))), "test", "runtests.jl"))
end

### Parse the compiles and generate precompilation scripts
# This can be run repeatedly to tweak the scripts


data = SnoopCompile.read("$(pwd())/Juno.log")

pc = SnoopCompile.parcel(reverse!(data[2]))
SnoopCompile.write("$(pwd())/precompile", pc)
