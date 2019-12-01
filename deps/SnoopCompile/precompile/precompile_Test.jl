function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Test.get_test_result), Expr, LineNumberNode})
    precompile(Tuple{typeof(Test.eval_test), Expr, Expr, LineNumberNode, Bool})
    precompile(Tuple{typeof(Test.get_testset)})
    precompile(Tuple{typeof(Test.scrub_backtrace), Array{Union{Ptr{Nothing}, Base.InterpreterIP}, 1}})
    precompile(Tuple{typeof(Test.do_test_throws), Test.Threw, Int, Int})
    isdefined(Test, Symbol("#@test_throws")) && precompile(Tuple{getfield(Test, Symbol("#@test_throws")), LineNumberNode, Module, Int, Int})
    isdefined(Test, Symbol("#@test")) && precompile(Tuple{getfield(Test, Symbol("#@test")), LineNumberNode, Module, Int, Int})
    precompile(Tuple{typeof(Test.record), Test.DefaultTestSet, Test.Fail})
    precompile(Tuple{typeof(Test.do_test), Test.Returned, Expr})
    precompile(Tuple{typeof(Test.test_expr!), String, Expr})
    precompile(Tuple{typeof(Test.record), Test.FallbackTestSet, Test.Fail})
end
