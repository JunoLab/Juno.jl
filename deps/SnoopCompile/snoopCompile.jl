const package = :Juno
################################################################
const packageName = string(package)
const filePath = joinpath(pwd(),"src","$packageName.jl")

function precompileDeactivator(packageName, filePath)

    file = open(filePath,"r")
    packageText = read(file, String)
    close(file)

    available = occursin("include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")", packageText)  && occursin("_precompile_()", packageText)

    if available
        packageEdited = foldl(replace,
                     (
                      "include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")" => "#include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")",
                      "_precompile_()" => "#_precompile_()",
                     ),
                     init = packageText)
    else
        error(""" add the following codes into your package:
         include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")
         _precompile_()
         """)
    end

     file = open(filePath,"w")
     write(file, packageEdited)
     close(file)
end

function precompileActivator(packageName, filePath)

    file = open(filePath,"r")
    packageText = read(file, String)
    close(file)

    available = occursin("#include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")", packageText)  && occursin("#_precompile_()", packageText)
    if available
        packageEdited = foldl(replace,
                     (
                      "#include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")" => "include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")",
                      "#_precompile_()" => "_precompile_()",
                     ),
                     init = packageText)
    else
        error(""" add the following codes into your package:
         include(\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\")
         _precompile_()
         """)
    end

     file = open(filePath,"w")
     write(file, packageEdited)
     close(file)
end

################################################################
const rootPath = pwd()
precompileDeactivator(packageName, filePath);
cd(@__DIR__)
################################################################
using SnoopCompile

### Log the compiles
data = @snoopi begin

    using Juno, Pkg

    # Use runtests.jl
    include(joinpath(dirname(dirname(pathof(Juno))), "test", "runtests.jl"))

    # Ues examples

end
################################################################
### Parse the compiles and generate precompilation scripts
pc = SnoopCompile.parcel(data)
onlypackage = Dict(package => sort(pc[package]))
SnoopCompile.write("$(pwd())/precompile",onlypackage)
################################################################
cd(rootPath)
precompileActivator(packageName, filePath)
