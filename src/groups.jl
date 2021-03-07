## Iterator protocol for `Group`

Base.eltype(::Type{G}) where {G<:Group} =
    throw(InterfaceNotSatisfied(:Iteration, "Base.eltype(::Type{$G})"))
Base.iterate(G::Group) =
    throw(InterfaceNotSatisfied(:Iteration, "Base.iterate(::$(typeof(G)))"))
Base.iterate(G::Group, state) = throw(
    InterfaceNotSatisfied(:Iteration, "Base.iterate(::$(typeof(G)), state)"),
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

Base.one(G::Group) =
    throw(InterfaceNotSatisfied(:Group, "Base.one(::$(typeof(G)))"))

AbstractAlgebra.order(::Type{<:Integer}, G::Group) = throw(
    InterfaceNotSatisfied(
        :Group,
        "AbstractAlgebra.order(::Type{<:Integer}, ::$(typeof(G)))",
    ),
)

AbstractAlgebra.gens(G::Group) =
    throw(InterfaceNotSatisfied(:Group, "AbstractAlgebra.gens(::$(typeof(G)))"))

function Base.rand(
    rng::Random.AbstractRNG,
    rs::Random.SamplerTrivial{G},
) where {G<:Group}
    throw(
        InterfaceNotSatisfied(
            :Random,
            "Base.rand(::Random.AbstractRNG, ::Random.SamplerTrivial{$G}))",
        ),
    )
end

### Default implementations for `Group`

function Base.isfinite(G::Group)
    IS = Base.IteratorSize(typeof(G))
    IS isa Base.HasLength && return true
    IS isa Base.HasShape && return true
    # else : IS isa (Base.SizeUnknown, Base.IsInfinite, ...)
    return false
end

hasgens(G::Group) = true

AbstractAlgebra.order(G::Group) = order(BigInt, G)
AbstractAlgebra.elem_type(G::Type{<:Group}) = eltype(typeof(G))

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
