using GroupsCore
using Test

include("conformance_test.jl")

include("cyclic.jl")
include("infinite_cyclic.jl")
include("symmetric.jl")

@testset "GroupsCore.jl" begin

    include("test_notsatisfied.jl")

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

    @testset "Symmetric(5)" begin
        G = AbstractAlgebra.SymmetricGroup(5)
        test_Group_interface(G)
        test_GroupElement_interface(rand(G, 2)...)
    end

    include("extensions.jl")
end

@testset "GroupConstructions" begin

    @testset "DirectProduct" begin
        GH =
            let G = AbstractAlgebra.SymmetricGroup(3),
                H = AbstractAlgebra.SymmetricGroup(4)

                GroupsCore.Constructions.DirectProduct(G, H)
            end
        test_Group_interface(GH)
        test_GroupElement_interface(rand(GH, 2)...)
    end

    @testset "DirectPower" begin
        GGG = GroupsCore.Constructions.DirectPower{3}(
            AbstractAlgebra.SymmetricGroup(3),
        )
        test_Group_interface(GGG)
        test_GroupElement_interface(rand(GGG, 2)...)
    end
    @testset "WreathProduct" begin
        W =
            let G = AbstractAlgebra.SymmetricGroup(2),
                P = AbstractAlgebra.SymmetricGroup(4)

                GroupsCore.Constructions.WreathProduct(G, P)
            end
        test_Group_interface(W)
        test_GroupElement_interface(rand(W, 2)...)
    end
end
