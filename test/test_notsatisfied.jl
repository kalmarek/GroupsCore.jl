struct SomeGroup <: Group end

struct SomeGroupElement <: GroupElement end

@testset "SomeGroup: No interface implemented" begin

    @testset "InterfaceNotImplemented exception" begin
        @test GroupsCore.InterfaceNotImplemented(
            :Castle,
            "Aaaaarghhhhh....",
        ) isa Exception
        ex = GroupsCore.InterfaceNotImplemented(:Castle, "Aaaaarghhhhh....")
        @test ex isa GroupsCore.InterfaceNotImplemented

        @test sprint(showerror, ex) ==
              "Missing method from Castle interface: `Aaaaarghhhhh....`"
    end

    INI = GroupsCore.InterfaceNotImplemented

    @testset "Group Interface" begin

        G = SomeGroup()

        # Iteration
        @test_throws INI eltype(G)
        @test_throws INI iterate(G)
        @test_throws INI iterate(G, 1)

        # Assumption 1: Groups are finite unless claimed otherwise
        @test Base.IteratorSize(G) == Base.HasLength()
        @test Base.isfinite(G)

        Base.IteratorSize(::Type{SomeGroup}) = Base.HasShape{1}()
        @test Base.isfinite(G)

        Base.IteratorSize(::Type{SomeGroup}) = Base.SizeUnknown()
        @test !Base.isfinite(G)

        Base.IteratorSize(::Type{SomeGroup}) = Base.IsInfinite()
        @test !Base.isfinite(G)

        # return to the default:
        Base.IteratorSize(::Type{SomeGroup}) = Base.HasLength()

        # Assumption 2: Groups have generators:
        @test hasgens(G)

        # Group Interface
        @test_throws INI one(G)
        @test_throws INI order(G)
        @test_throws INI gens(G)

        Base.eltype(::Type{SomeGroup}) = SomeGroupElement
        @test_throws INI rand(G, 2)

        @test_throws INI gens(G, 1)
        @test_throws INI ngens(G)

        @test_throws INI GroupsCore.pseudo_rand(G, 2, 2)
    end

    @testset "GroupElem Interface" begin

        g = SomeGroupElement()

        @test_throws INI parent(g)
        @test_throws INI istrulyequal(g, g)

        @test_throws INI hasorder(g)
        @test_throws INI inv(g)
        @test_throws INI g * g
    end

end
