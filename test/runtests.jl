using GroupsCore
using Test

include("conformance_test.jl")

include("cyclic.jl")
include("infinite_cyclic.jl")

@testset "GroupsCore.jl" begin

    include("test_notsatisfied.jl")

    @testset "Cyclic(1)" begin
        G = CyclicGroup(1)
        test_Group_interface(G)
        test_GroupElement_interface(rand(G, 2)...)
    end

    @testset "Cyclic(12)" begin
        G = CyclicGroup(12)
        test_Group_interface(G)
        test_GroupElement_interface(rand(G, 2)...)
    end

    @testset "InfCyclic" begin
        G = InfCyclicGroup()
        test_Group_interface(G)
        test_GroupElement_interface(rand(G, 2)...)
    end

    include("extensions.jl")
end
