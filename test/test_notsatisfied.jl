module TestNotImplemented

using GroupsCore
using Test

struct SomeGroup <: Group end

struct SomeGroupElement <: GroupElement
    elts::Vector{Int} # SomeGroupElement is not isbits anymore
end

@testset "Exceptions" begin
    @testset "InterfaceNotImplemented exception" begin
        @test GroupsCore.InterfaceNotImplemented(
            :Castle,
            "Aaaaarghhhhh....",
        ) isa Exception
        ex = GroupsCore.InterfaceNotImplemented(:Castle, "Aaargh...")
        @test ex isa GroupsCore.InterfaceNotImplemented

        @test sprint(showerror, ex) ==
              "Missing method from Castle interface: `Aaargh...`"
    end
    @testset "InfiniteOrder" begin
        G = SomeGroup()
        @test contains(
            sprint(showerror, GroupsCore.InfiniteOrder(G)),
            "isfinite",
        )
        g = SomeGroupElement(Int[1, 2, 3])
        @test contains(
            sprint(showerror, GroupsCore.InfiniteOrder(g)),
            "isfiniteorder",
        )
        @test contains(
            sprint(showerror, GroupsCore.InfiniteOrder(g, "Aaargh...")),
            "Aaargh...",
        )
    end
end

@testset "SomeGroup: No interface implemented" begin

    INI = GroupsCore.InterfaceNotImplemented
    InfO = GroupsCore.InfiniteOrder

    @testset "Group Interface" begin

        G = SomeGroup()

        # Iteration
        @test_throws INI eltype(G)
        @test_throws INI iterate(G)
        @test_throws INI iterate(G, 1)

        GroupsCore.hasgens(::SomeGroup) = false

        @test_throws ArgumentError iterate(G)
        @test_throws ArgumentError iterate(G, 1)
        @test_throws ArgumentError gens(G, 1)

        # revert to the default
        GroupsCore.hasgens(::SomeGroup) = true

        # Assumption 1: Groups are of unknown size
        @test Base.IteratorSize(G) == Base.SizeUnknown()
        @test_throws ArgumentError Base.isfinite(G)
        @test_throws ArgumentError order(G)

        Base.IteratorSize(::Type{SomeGroup}) = Base.HasShape{1}()
        @test Base.isfinite(G)
        @test_throws INI order(G)

        Base.IteratorSize(::Type{SomeGroup}) = Base.HasLength()
        @test Base.isfinite(G)
        @test_throws INI order(G)

        Base.IteratorSize(::Type{SomeGroup}) = Base.IsInfinite()
        @test !Base.isfinite(G)
        @test_throws InfO order(G)

        # return to the default:
        Base.IteratorSize(::Type{SomeGroup}) = Base.SizeUnknown()

        # Assumption 2: Groups have generators:
        @test hasgens(G)

        # Group Interface
        @test_throws INI one(G)
        @test_throws ArgumentError order(G)
        @test_throws INI gens(G)

        Base.eltype(::Type{SomeGroup}) = SomeGroupElement

        @test_throws INI gens(G, 1)
        @test_throws INI ngens(G)
    end

    @testset "GroupElem Interface" begin

        g = SomeGroupElement(Int[])

        @test_throws INI parent(g)
        @test_throws INI g == g
        @test_throws INI isequal(g, g)

        @test_throws INI isfiniteorder(g)

        Base.IteratorSize(::SomeGroup) = Base.HasLength()
        Base.parent(::SomeGroupElement) = SomeGroup()
        @test isfiniteorder(g)
        Base.IteratorSize(::SomeGroup) = Base.SizeUnknown()

        GroupsCore.isfiniteorder(::SomeGroupElement) = false
        @test_throws InfO order(g)
        @test_throws INI deepcopy(g)

        @test_throws INI inv(g)
        @test_throws INI g * g
    end

end

end # of module TestNotImplemented
