using GroupsCore
using Test
using AbstractAlgebra

include("conformance_test.jl")

@testset "GroupsCore.jl" begin
    G = SymmetricGroup(5)
    conformance_Group_interface(G)
    conformance_GroupElement_interface(rand(G, 2)...)
end
