################################################################################
#
#   groups.jl : Interface for group parents
#
################################################################################
# Obligatory methods
################################################################################

@doc Markdown.doc"""
    elem_type(::Type{<:Group})
    elem_type(G::Group)

Alias for [`eltype(G)`](@ref).
"""
elem_type(::Type{Gr}) where {Gr <: Group} = eltype(Gr)
elem_type(G::Group) = eltype(G)

@doc Markdown.doc"""
    one(G::Group)

Return the identity element of the group $G$.
"""
Base.one(G::Group) =
    throw(InterfaceNotImplemented(:Group, "Base.one(::$(typeof(G)))"))

@doc Markdown.doc"""
    order(I::Type{Integer} = BigInt, G::Group)

Return the order of $G$ as an instance of `I`. If $G$ is of infinite order,
`GroupsCore.InfiniteOrder` exception will be thrown.

!!! warning

    Only arbitrary sized integers are required to return a mathematically
    correct answer.
"""
function order(::Type{<:Integer}, G::Group)
    if !isfinite(G)
        throw(InfiniteOrder(G))
    end
    throw(
        InterfaceNotImplemented(
            :Group,
            "GroupsCore.order(::Type{<:Integer}, ::$(typeof(G)))",
        )
    )
end

order(G::Group) = order(BigInt, G)

@doc Markdown.doc"""
    gens(G::Group)

Return a random-access collection of generators of $G$.

The result of this function is undefined unless `GroupsCore.hasgens(G)` returns
`true`.
"""
gens(G::Group) =
    throw(InterfaceNotImplemented(:Group, "GroupsCore.gens(::$(typeof(G)))"))

function Base.rand(
    rng::Random.AbstractRNG,
    rs::Random.SamplerTrivial{G}
) where {G <: Group}
    throw(
        InterfaceNotImplemented(
            :Random,
            "Base.rand(::Random.AbstractRNG, ::Random.SamplerTrivial{$G}))",
        ),
    )
end

################################################################################
# Iterators
################################################################################

Base.eltype(::Type{G}) where {G <: Group} =
    throw(InterfaceNotImplemented(:Iteration, "Base.eltype(::$(typeof(G)))"))

Base.iterate(G::Group) =
    throw(InterfaceNotImplemented(:Iteration, "Base.iterate(::$(typeof(G)))"))
Base.iterate(G::Group, state) = throw(
    InterfaceNotImplemented(:Iteration, "Base.iterate(::$(typeof(G)), state)"),
)

@doc Markdown.doc"""
    IteratorSize(::Type{G}) where {G <: Group}

Return size of iterator if and only if every instance of $Type{G}$ is either
finite or infinite. If not every instance can be categorized in only one of
these, it returns `SizeUnknown`.
"""
Base.IteratorSize(::Type{G}) where {G <: Group} = Base.SizeUnknown()
Base.length(G::Group) = order(Int, G)

################################################################################
# Default implementations
################################################################################

function Base.isfinite(G::Group)
    IS = Base.IteratorSize(G)
    IS isa Base.HasLength && return true
    IS isa Base.HasShape && return true
    IS isa Base.IsInfinite && return false
    # else : IS isa (Base.SizeUnknown, Base.IsInfinite, ...)
    throw(ArgumentError(
    """The finiteness of $G could not be determined based on its iterator type.
You need to implement `Base.isfinite(::$(typeof(G))) yourself."""))
end

hasgens(G::Group) = true

function gens(G::Group, i::Integer)
    hasgens(G) && return gens(G)[i]
    # TODO: throw something more specific
    throw(
        "Group does not seem to have generators. Did you alter `hasgens(::$(typeof(G)))`?",
    )
end

function ngens(G::Group)
    hasgens(G) && return length(gens(G))
    # TODO: throw something more specific
    throw(
        "Group does not seem to have generators. Did you alter `hasgens(::$(typeof(G)))`?",
    )
end

pseudo_rand(G::Group, args...) = pseudo_rand(Random.default_rng(), G, args...)
pseudo_rand(rng::Random.AbstractRNG, G::Group, args...) = rand(rng, G, args...)
