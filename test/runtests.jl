using GroupsCore
using Test

include("conformance_test.jl")

@testset "GroupsCore.jl" begin
    include("cyclic.jl")
    include("symmetric.jl")
end
