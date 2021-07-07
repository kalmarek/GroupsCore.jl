import AbstractAlgebra.Generic: Perm, SymmetricGroup

# disambiguation
GroupsCore.order(::Type{I}, G::SymmetricGroup) where {I<:Integer} =
    convert(I, factorial(G.n))

# disambiguation
GroupsCore.order(::Type{I}, g::Perm) where {I<:Integer} =
    convert(I, foldl(lcm, length(c) for c in AbstractAlgebra.cycles(g)))

# correct the AA length:
Base.length(G::SymmetricGroup) = order(Int, G)

# genuinely new methods:
Base.IteratorSize(::Type{<:AbstractAlgebra.AbstractPermutationGroup}) = Base.HasLength()

function GroupsCore.gens(G::SymmetricGroup{I}) where {I}
    G.n == 1 && return eltype(G)[]
    if G.n == 2
        a = one(G)
        a.d[1], a.d[2] = 2, 1
        return [a]
    end
    a, b = one(G), one(G)
    circshift!(a.d, b.d, -1)
    b.d[1], b.d[2] = 2, 1
    return [a, b]
end

Base.deepcopy_internal(g::Perm, stackdict::IdDict) =
    Perm(Base.deepcopy_internal(g.d, stackdict), false)
