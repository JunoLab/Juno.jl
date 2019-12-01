function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Logging.default_metafmt), Base.CoreLogging.LogLevel, Module, String, Symbol, String, Int64})
end
