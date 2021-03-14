@testset "Functions to extend" begin

    @testset "predicates" begin
        @test GroupsCore.isabelian isa Function
        @test GroupsCore.issolvable isa Function
        @test GroupsCore.isnilpotent isa Function
        @test GroupsCore.isperfect isa Function
    end

    @testset "generic constructions" begin
        @test GroupsCore.derivedsubgroup isa Function
        @test GroupsCore.center isa Function
        @test GroupsCore.socle isa Function
        @test GroupsCore.sylowsubgroup isa Function
    end

    @testset "general subgroups" begin
        @test GroupsCore.centralizer isa Function
        @test GroupsCore.normalizer isa Function
        @test GroupsCore.stabilizer isa Function
    end
end
