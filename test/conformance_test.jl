using GroupsCore
using Test

function test_Group_interface(G::Group)
    @testset "Group interface" begin
        @testset "Iteration protocol" begin
            IS = Base.IteratorSize(typeof(G))
            if IS isa Base.IsInfinite
                @test isfinite(G) == false
            else
                isfiniteG = false
                if IS isa Base.HasLength || IS isa Base.HasShape
                    @test isfinite(G) == true
                    isfiniteG = true
                else
                    @test IS isa Base.SizeUnknown
                    try
                        @test isfinite(G) isa Bool
                        isfiniteG = isfinite(G)
                    catch e
                        @test e isa GroupsCore.InfiniteOrder
                        isfiniteG = false
                    end
                end

                if isfiniteG
                    @test length(G) isa Int
                    @test length(G) > 0

                    @test eltype(G) <: GroupElement
                    @test one(G) isa eltype(G)

                    if GroupsCore.hasgens(G)
                        @test first(iterate(G)) isa eltype(G)
                        _, s = iterate(G)
                        @test first(iterate(G, s)) isa eltype(G)
                        @test isone(first(G))
                    end
                end
            end
        end

        @testset "Group generators" begin
            @test GroupsCore.hasgens(G) isa Bool

            if GroupsCore.hasgens(G)
                @test ngens(G) isa Int
                @test gens(G) isa AbstractVector{eltype(G)}
                @test length(gens(G)) == ngens(G)
                if ngens(G) > 0
                    @test first(gens(G)) == gens(G, 1)
                    @test last(gens(G)) == gens(G, ngens(G))
                end
            else
                # TODO: throw something more specific
                @test_throws ErrorException gens(G)
                @test_throws ErrorException ngens(G)
            end
        end

        @testset "order, rand" begin
            if isfinite(G)
                @test order(Int16, G) isa Int16
                @test order(BigInt, G) isa BigInt
                @test order(G) >= 1
                @test istrivial(G) == (order(G) == 1)
            else
                @test_throws GroupsCore.InfiniteOrder order(G)
                @test !istrivial(G)
            end

            @test rand(G) isa GroupElement
            @test rand(G, 2) isa AbstractVector{eltype(G)}
            g, h = rand(G, 2)
            @test parent(g) === parent(h) === G

            @test GroupsCore.rand_pseudo(G) isa eltype(G)
            @test GroupsCore.rand_pseudo(G, 2, 2) isa AbstractMatrix{eltype(G)}

            g, h = GroupsCore.rand_pseudo(G, 2)
            @test parent(g) === parent(h) === G
        end
    end
end

function test_GroupElement_interface(g::GEl, h::GEl) where {GEl<:GroupElement}

    @testset "GroupElement interface" begin

        @testset "Parent methods" begin
            @test parent(g) isa Group
            @test parent(g) === parent(h)
            G = parent(g)

            @test eltype(G) == typeof(g)

            @test one(g) isa eltype(G)

            @test one(G) == one(g) == one(h)

            if GroupsCore._is_deepcopiable(g)
                @test one(G) !== one(g)
            end

            @test isone(one(G))
        end

        @testset "Equality, deepcopy && hash" begin
            @test (g == h) isa Bool

            @test ==(g, h) isa Bool
            @test isequal(g, g)
            @test ==(h, h)

            if g != h
                @test !isequal(g, h)
            end

            @test deepcopy(g) isa typeof(g)
            @test deepcopy(g) == g
            if GroupsCore._is_deepcopiable(g)
                @test deepcopy(g) !== g
            end
            k = deepcopy(g)
            @test parent(k) === parent(g)
            @test hash(g) isa UInt
            @test hash(g) == hash(k)

            if isequal(g, h)
                @test hash(g) == hash(h)
            end
        end

        @testset "Group operations" begin
            old_g, old_h = deepcopy(g), deepcopy(h)

            # check that the default operations don't mutate their arguments
            @test inv(g) isa typeof(g)
            @test (g, h) == (old_g, old_h)

            @test g * h isa typeof(g)
            @test (g, h) == (old_g, old_h)

            @test g^2 == g * g
            @test (g, h) == (old_g, old_h)

            @test g^-3 == inv(g) * inv(g) * inv(g)
            @test (g, h) == (old_g, old_h)

            pow(g,n) = g^n

            @test pow(g, 6) isa GroupElement
            @test pow(g, 1) isa GroupElement
            @test (g, h) == (old_g, old_h)

            @test (g * h)^-1 == inv(h) * inv(g)
            @test (g, h) == (old_g, old_h)

            @test conj(g, h) == inv(h) * g * h
            @test (g, h) == (old_g, old_h)

            @test ^(g, h) == inv(h) * g * h
            @test (g, h) == (old_g, old_h)

            @test commutator(g, h) == g^-1 * h^-1 * g * h
            @test (g, h) == (old_g, old_h)

            @test commutator(g, h, g) == conj(inv(g), h) * conj(conj(g, h), g)
            @test (g, h) == (old_g, old_h)

            @test isone(g * inv(g)) && isone(inv(g) * g)
            @test (g, h) == (old_g, old_h)

            @test g / h == g * inv(h)
            @test (g, h) == (old_g, old_h)
        end

        @testset "Misc GroupElement methods" begin
            @test one(g) isa typeof(g)
            @test isone(g) isa Bool
            @test isone(one(g))

            @test isfiniteorder(g) isa Bool

            if isfiniteorder(g)
                @test order(Int16, g) isa Int16
                @test order(BigInt, g) isa BigInt
                @test order(g) >= 1
                if isfinite(parent(g))
                    @test iszero(order(parent(g)) % order(g))
                end
                if !isone(g) && !isone(g^2)
                    @test order(g) > 2
                end
                @test order(inv(g)) == order(g)
                @test order(one(g)) == 1
            else
                @test_throws GroupsCore.InfiniteOrder order(g)
            end

            @test similar(g) isa typeof(g)
        end

        one!, inv!, mul!, conj!, commutator!, div_left!, div_right! = (
            GroupsCore.one!,
            GroupsCore.inv!,
            GroupsCore.mul!,
            GroupsCore.conj!,
            GroupsCore.commutator!,
            GroupsCore.div_left!,
            GroupsCore.div_right!,
        )

        @testset "In-place operations" begin
            old_g, old_h = deepcopy(g), deepcopy(h)
            out = similar(g)

            @test isone(one!(g))
            g = deepcopy(old_g)

            @test inv!(out, g) == inv(old_g)
            @test g == old_g
            @test inv!(out, g) == inv(old_g)
            g = deepcopy(old_g)

            @testset "mul!" begin
                @test mul!(out, g, h) == old_g * old_h
                @test (g, h) == (old_g, old_h)

                @test mul!(out, g, h) == old_g * old_h
                @test (g, h) == (old_g, old_h)

                @test mul!(g, g, h) == old_g * old_h
                @test h == old_h
                g = deepcopy(old_g)

                @test mul!(h, g, h) == old_g * old_h
                @test g == old_g
                h = deepcopy(old_h)

                @test mul!(g, g, g) == old_g * old_g
                g = deepcopy(old_g)
            end

            @testset "conj!" begin
                res = old_h^-1 * old_g * old_h
                @test conj!(out, g, h) == res
                @test (g, h) == (old_g, old_h)

                @test conj!(g, g, h) == res
                @test h == old_h
                g = deepcopy(old_g)

                @test conj!(h, g, h) == res
                @test g == old_g
                h = deepcopy(old_h)

                @test conj!(g, g, g) == old_g
                g = deepcopy(old_g)
            end

            @testset "commutator!" begin
                res = old_g^-1 * old_h^-1 * old_g * old_h

                @test commutator!(out, g, h) == res
                @test (g, h) == (old_g, old_h)

                @test commutator!(out, g, h) == res
                @test (g, h) == (old_g, old_h)

                @test commutator!(g, g, h) == res
                @test h == old_h
                g = deepcopy(old_g)

                @test commutator!(h, g, h) == res
                @test g == old_g
                h = deepcopy(old_h)
            end

            @testset "div_[left|right]!" begin
                res = g * h^-1
                @test div_right!(out, g, h) == res
                @test (g, h) == (old_g, old_h)

                @test div_right!(g, g, h) == res
                @test h == old_h
                g = deepcopy(old_g)

                @test div_right!(h, g, h) == res
                @test g == old_g
                h = deepcopy(old_h)

                @test div_right!(g, g, g) == one(g)
                g = deepcopy(old_g)


                res = h^-1 * g
                @test div_left!(out, g, h) == res
                @test (g, h) == (old_g, old_h)

                @test div_left!(g, g, h) == res
                @test h == old_h
                g = deepcopy(old_g)

                @test div_left!(h, g, h) == res
                @test g == old_g
                h = deepcopy(old_h)

                @test div_left!(g, g, g) == one(g)
                g = deepcopy(old_g)
            end
        end
    end
end
