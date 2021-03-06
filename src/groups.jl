## Iterator protocol for `Group`

Base.eltype(::Type{G}) where {G<:Group} =
    throw(InterfaceNotSatisfied(:Iteration, "Base.eltype(::Type{$G})"))
Base.iterate(G::Group) =
    throw(InterfaceNotSatisfied(:Iteration, "Base.iterate(::$(typeof(G)))"))
Base.iterate(G::Group, state) = throw(
    InterfaceNotSatisfied(:Iteration, "Base.iterate(::$(typeof(G)), state)"),
)


#=
TODO: This is a convention; cannot define length unless Base.IteratorSize(...) = HasLength()!

either override the default
> `Base.IteratorSize(::Type{MyGroup}) = Base.HasLength()`
by
> `Base.IteratorSize(::Type{MyGroup}) = Base.IsInfinite()`

OR define

Base.length(G::MyGroup)

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

hasgens(G::Group) = true

AbstractAlgebra.order(G::Group) = order(BigInt, G)
AbstractAlgebra.elem_type(G::Type{<:Group}) = eltype(G)

function AbstractAlgebra.gens(G::Group, i::Integer)
    hasgens(G) && return gens(G)[i]
    throw(
        "Group does not seem to have generators. Did you alter `hasgens(::$(typeof(G)))`?",
    )
end

function AbstractAlgebra.ngens(G::Group)
    hasgens(G) && return length(gens(G))
    throw(
        "Group does not seem to have generators. Did you alter `hasgens(::$(typeof(G)))`?",
    )
end

rand_pseudo(G::Group) = rand_pseudo(Random.default_rng(), G)
rand_pseudo(rng::Random.AbstractRNG, G::Group) = rand(rng, G)

Base.isfinite(G::Group) =
    IS = Base.IteratorSize(typeof(G))
    IS isa Base.HasLength && return true
    IS isa Base.HasShape && return true
    # else : IS isa (Base.SizeUnknown, Base.IsInfinite, ...)
    return false
end
