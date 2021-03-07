using GroupsCore
using Test

include("conformance_test.jl")

include("cyclic.jl")
include("symmetric.jl")

@testset "GroupsCore.jl" begin

    @testset "Cyclic(12)" begin
        G = CyclicGroup(12)
        conformance_Group_interface(G)
        conformance_GroupElement_interface(rand(G, 2)...)
    end

    @testset "Symmetric(5)" begin
        G = AbstractAlgebra.SymmetricGroup(5)
        conformance_Group_interface(G)
        conformance_GroupElement_interface(rand(G, 2)...)
    end
end
