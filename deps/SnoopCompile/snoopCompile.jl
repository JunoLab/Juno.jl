using SnoopCompile


################################################################
const packageName = "Juno"
const filePath = joinpath(pwd(),"src","$packageName.jl")

function precompileDeactivator(packageName, filePath)

    file = open(filePath,"r")
    packageText = read(file, String)
    close(file)

    packageEdited = foldl(replace,
                 (
                  "include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")" => "#include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")",
                  "_precompile_()" => "#_precompile_()",
                 ),
                 init = packageText)

     file = open(filePath,"w")
     write(file, packageEdited)
     close(file)
end

function precompileActivator(packageName, filePath)

    file = open(filePath,"r")
    packageText = read(file, String)
    close(file)

    packageEdited = foldl(replace,
                 (
                  "#include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")" => "include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")",
                  "#_precompile_()" => "_precompile_()",
                 ),
                 init = packageText)

     file = open(filePath,"w")
     write(file, packageEdited)
     close(file)
end

################################################################
const rootPath = pwd()

precompileDeactivator(packageName, filePath);

cd(@__DIR__)
################################################################

### Log the compiles
# This only needs to be run once (to generate log file)

SnoopCompile.@snoopc "$(pwd())/Snoop.log" begin

    # Use runtests.jl or your exmaples that uses package:

    using Juno, Pkg
    include(joinpath(dirname(dirname(pathof(Juno))), "test", "runtests.jl"))
end

################################################################

### Parse the compiles and generate precompilation scripts
# This can be run repeatedly to tweak the scripts

data = SnoopCompile.read("$(pwd())/Snoop.log")

pc = SnoopCompile.parcel(reverse!(data[2]))
SnoopCompile.write("$(pwd())/precompile", pc)

################################################################
cd(rootPath)
precompileActivator(packageName, filePath)
