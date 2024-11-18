using GroupsCore
using Test

# these are for backwards compatibility:
test_Group_interface(G::Group) = test_GroupsCore_interface(G)
function test_GroupElement_interface(g::El, h::El) where {El<:GroupElement}
    return test_GroupsCore_interface(g, h)
end

function test_GroupsCore_interface(M::Monoid)
    @testset "Monoid interface" begin
        @testset "Iteration protocol" begin
            IS = Base.IteratorSize(typeof(M))
            if IS isa Base.IsInfinite
                @test isfinite(M) == false
            else
                isfiniteM = false
                if IS isa Base.HasLength || IS isa Base.HasShape
                    @test isfinite(M) == true
                    isfiniteM = true
                else
                    @test IS isa Base.SizeUnknown
                    try
                        @test isfinite(M) isa Bool
                        isfiniteM = isfinite(M)
                    catch e
                        @test e isa GroupsCore.InfiniteOrder
                        isfiniteM = false
                    end
                end

                if isfiniteM
                    @test length(M) isa Int
                    @test length(M) > 0

                    @test eltype(M) <: MonoidElement
                    if M isa Group
                        @test eltype(M) <: GroupElement
                    end
                    @test one(M) isa eltype(M)

                    if GroupsCore.hasgens(M)
                        @test first(iterate(M)) isa eltype(M)
                        _, s = iterate(M)
                        if GroupsCore.istrivial(M) == 1
                            @test isnothing(iterate(M, s))
                        else
                            @test first(iterate(M, s)) isa eltype(M)
                        end
                        @test isone(first(M))
                    end
                end
            end
        end

        @testset "Monoid generators" begin
            @test GroupsCore.hasgens(M) isa Bool

            if GroupsCore.hasgens(M)
                @test ngens(M) isa Int
                @test collect(gens(M)) isa AbstractVector{eltype(M)}
                @test length(gens(M)) == ngens(M)
                if ngens(M) > 0
                    @test first(gens(M)) == gens(M, 1)
                    @test last(gens(M)) == gens(M, ngens(M))
                end
            else
                # TODO: throw something more specific
                @test_throws ErrorException gens(M)
                @test_throws ErrorException ngens(M)
            end
        end

        @testset "order, rand" begin
            if isfinite(M)
                @test order(Int16, M) isa Int16
                @test order(BigInt, M) isa BigInt
                @test order(M) >= 1
                @test istrivial(M) == (order(M) == 1)
            else
                @test_throws GroupsCore.InfiniteOrder order(M)
                @test !istrivial(M)
            end

            @test rand(M) isa eltype(M)
            @test rand(M, 2) isa AbstractVector{eltype(M)}
            g, h = rand(M, 2)
            @test parent(g) === parent(h) === M
        end

        test_GroupsCore_interface(rand(M, 2)...)

    end
end

function test_GroupsCore_interface(g::El, h::El) where {El<:MonoidElement}
    isgroup = El <: GroupElement
    @testset "MonoidElement interface" begin
        @testset "Parent methods & deepcopy" begin
            @test parent(g) isa Monoid
            if isgroup
                @test parent(g) isa Group
            end
            @test parent(g) === parent(h)
            G = parent(g)

            @test eltype(G) == typeof(g)

            @test one(g) isa eltype(G)

            @test one(G) == one(g) == one(h)

            @test isone(one(G))

            @test ==(g, h) isa Bool
            @test ==(h, h)

            @test deepcopy(g) isa typeof(g)
            @test deepcopy(g) == g
            k = deepcopy(g)
            @test parent(k) === parent(g)
            @test hash(g) isa UInt
            @test hash(g) == hash(k)

            if g == h
                @test hash(g) == hash(h)
            end
        end

        @testset "Group/Monoid operations" begin
            old_g, old_h = deepcopy(g), deepcopy(h)

            # check that the default operations don't mutate their arguments
            @test g * h isa typeof(g)
            @test (g, h) == (old_g, old_h)

            @test g^2 == g * g
            @test (g, h) == (old_g, old_h)

            pow(g, n) = g^n

            @test pow(g, 6) isa El
            @test pow(g, 1) isa El
            @test (g, h) == (old_g, old_h)

            @test (g * h) * g == g * (h * g)
            @test (g, h) == (old_g, old_h)

            if isgroup
                @test inv(g) isa typeof(g)
                @test (g, h) == (old_g, old_h)

                @test g^-3 == inv(g) * inv(g) * inv(g)
                @test (g, h) == (old_g, old_h)

                @test (g * h)^-1 == inv(h) * inv(g)
                @test (g, h) == (old_g, old_h)

                @test conj(g, h) == inv(h) * g * h
                @test (g, h) == (old_g, old_h)

                @test ^(g, h) == inv(h) * g * h
                @test (g, h) == (old_g, old_h)

                @test commutator(g, h) == g^-1 * h^-1 * g * h
                @test (g, h) == (old_g, old_h)

                @test commutator(g, h, g) ==
                      conj(inv(g), h) * conj(conj(g, h), g)
                @test (g, h) == (old_g, old_h)

                @test isone(g * inv(g)) && isone(inv(g) * g)
                @test (g, h) == (old_g, old_h)

                @test g / h == g * inv(h)
                @test (g, h) == (old_g, old_h)
            end
        end

        @testset "Misc Element methods" begin
            @test one(g) isa typeof(g)
            @test isone(g) isa Bool
            @test isone(one(g))

            @test isfiniteorder(g) isa Bool

            if isfiniteorder(g)
                @test order(Int16, g) isa Int16
                @test order(BigInt, g) isa BigInt
                @test order(g) >= 1
                if isfinite(parent(g)) && isgroup
                    @test iszero(order(parent(g)) % order(g))
                end
                if !isone(g) && !isone(g^2)
                    @test order(g) ≥ 2
                end
                isgroup && @test order(inv(g)) == order(g)
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

            if isgroup
                @test inv!(out, g) == inv(old_g)
                @test g == old_g
                @test inv!(out, g) == inv(old_g)
                g = deepcopy(old_g)
            end

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

            if isgroup
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
end
