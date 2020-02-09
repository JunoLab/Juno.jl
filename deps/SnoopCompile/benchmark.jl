using SnoopCompile

@info "Benchmark inference time during package loading"
@snoopi_bench "Juno" using Juno

@info "Benchmark inference time during running package testsuite"
@snoopi_bench "Juno"
