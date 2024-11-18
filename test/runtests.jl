using GroupsCore
using Test

include("conformance_test.jl")

include("cyclic.jl")
include("infinite_cyclic.jl")
include("cyclic_monoid.jl")

@testset "GroupsCore.jl" begin
    include("test_notsatisfied.jl")

    @testset "Cyclic(1)" begin
        G = CyclicGroup(1)
        test_GroupsCore_interface(G)
    end

    @testset "Cyclic(12)" begin
        G = CyclicGroup(12)
        test_GroupsCore_interface(G)
    end

    @testset "CyclicMonoid(5)" begin
        G = CyclicGroup(12)
        test_GroupsCore_interface(G)
    end

    @testset "InfCyclic" begin
        G = InfCyclicGroup()
        test_GroupsCore_interface(G)
    end

    include("extensions.jl")
end
