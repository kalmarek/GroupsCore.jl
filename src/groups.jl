## Iterator protocol for `Group`

Base.eltype(::Type{G}) where {G<:Group} =
    throw(InterfaceNotImplemented(:Iteration, "Base.eltype(::Type{$G})"))
Base.iterate(G::Group) =
    throw(InterfaceNotImplemented(:Iteration, "Base.iterate(::$(typeof(G)))"))
Base.iterate(G::Group, state) = throw(
    InterfaceNotImplemented(:Iteration, "Base.iterate(::$(typeof(G)), state)"),
)

#=
TODO: This is a convention; cannot define length unless Base.IteratorSize returns HasLength or HasShape!

You need to override the default
> `Base.IteratorSize(::Type{MyGroup}) = Base.HasLength()`
by
> `Base.IteratorSize(::Type{MyGroup}) = Base.IsInfinite()`
if your group is always infinite, or by
> `Base.IteratorSize(::Type{MyGroup}) = Base.SizeUnknown()`
if finiteness can not be easily established.

otherwise define

Base.length(G::MyGroup) = order(Int, G)

which is "best effort", cheap computation of length of the group iterator. For practical reasons the largest group you could iterate over in your lifetime is of order ~factorial(19) (assuming 10ns per element).
=#


## `Group` interface

### Obligatory methods for `Group`
@doc Markdown.doc"""
    one(G::Group)
Return the identity of the group.
"""
Base.one(G::Group) =
    throw(InterfaceNotImplemented(:Group, "Base.one(::$(typeof(G)))"))

@doc Markdown.doc"""
    order([BigInt, ]G::Group)
    order(I::Type{<:Integer}, g::Group)
Return the order of `g` as an instance of `I`.

Only arbitrary size integers are required to return mathematically correct answer.
"""
function AbstractAlgebra.order(::Type{<:Integer}, G::Group)
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

@doc Markdown.doc"""
    gens(G::Group)

Return a random-accessed collection of generators of `G`.

If a group does not come with a generating set (or it may be prohibitively expensive to compute), one needs to alter `GroupsCore.hasgens(::Group) = false`.
"""
AbstractAlgebra.gens(G::Group) =
    throw(InterfaceNotImplemented(:Group, "GroupsCore.gens(::$(typeof(G)))"))

function Base.rand(
    rng::Random.AbstractRNG,
    rs::Random.SamplerTrivial{G},
) where {G<:Group}
    throw(
        InterfaceNotImplemented(
            :Random,
            "Base.rand(::Random.AbstractRNG, ::Random.SamplerTrivial{$G}))",
        ),
    )
end

### Default implementations for `Group`

function Base.isfinite(G::Group)
    IS = Base.IteratorSize(G)
    IS isa Base.HasLength && return true
    IS isa Base.HasShape && return true
    # else : IS isa (Base.SizeUnknown, Base.IsInfinite, ...)
    return false
end

hasgens(G::Group) = true

AbstractAlgebra.order(G::Group) = order(BigInt, G)

@doc Markdown.doc"""
    elem_type(parent_type)
Given the type of a parent object return the type of its elements.
"""
AbstractAlgebra.elem_type(T::Type{<:Group}) = eltype(T)

function AbstractAlgebra.gens(G::Group, i::Integer)
    hasgens(G) && return gens(G)[i]
    # TODO: throw something more specific
    throw(
        "Group does not seem to have generators. Did you alter `hasgens(::$(typeof(G)))`?",
    )
end

function AbstractAlgebra.ngens(G::Group)
    hasgens(G) && return length(gens(G))
    # TODO: throw something more specific
    throw(
        "Group does not seem to have generators. Did you alter `hasgens(::$(typeof(G)))`?",
    )
end

pseudo_rand(G::Group, args...) = pseudo_rand(Random.default_rng(), G, args...)
pseudo_rand(rng::Random.AbstractRNG, G::Group, args...) = rand(rng, G, args...)
