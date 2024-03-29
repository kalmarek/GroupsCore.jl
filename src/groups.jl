################################################################################
#
#   groups.jl : Interface for group parents
#
################################################################################
# Obligatory methods
################################################################################

function Base.one(G::Group)
    throw(InterfaceNotImplemented(:Group, "Base.one(::$(typeof(G)))"))
end

"""
    order([::Type{T} = BigInt, ]G::Group) where T
Return the order of `G` as an instance of `T`. If `G` is of infinite order,
`GroupsCore.InfiniteOrder` exception will be thrown.

!!! warning
    Only arbitrary sized integers are required to return a mathematically
    correct answer.
"""
function order(::Type{T}, G::Group) where {T}
    if !isfinite(G)
        throw(InfiniteOrder(G))
    end
    throw(
        InterfaceNotImplemented(
            :Group,
            "GroupsCore.order(::Type{$T}, ::$(typeof(G)))",
        ),
    )
end
order(G::Group) = order(BigInt, G)

"""
    gens(G::Group)
Return a random-access collection of generators of `G`.
"""
gens(G::Group) =
    throw(InterfaceNotImplemented(:Group, "GroupsCore.gens(::$(typeof(G)))"))

################################################################################
# Iterators
################################################################################

function Base.eltype(::Type{Gr}) where {Gr<:Group}
    throw(InterfaceNotImplemented(:Iteration, "Base.eltype(::Type{$Gr})"))
end

function Base.iterate(G::Group)
    hasgens(G) && throw(
        InterfaceNotImplemented(:Iteration, "Base.iterate(::$(typeof(G)))"),
    )
    throw(ArgumentError("Group does not have assigned generators."))
end

function Base.iterate(G::Group, state)
    hasgens(G) && throw(
        InterfaceNotImplemented(
            :Iteration,
            "Base.iterate(::$(typeof(G)), state)",
        ),
    )
    throw(ArgumentError("Group does not have assigned generators."))
end

"""
    IteratorSize(::Type{Gr}) where {Gr <: Group}
Given the type of a group, return one of the following values:
 * `Base.IsInfinite()` if all instances of groups of type `Gr` are infinite.
 * `Base.HasLength()` or `Base.HasShape{N}()` if all instances are finite.
 * `Base.SizeUnknown()` otherwise, [the default].
"""
Base.IteratorSize(::Type{<:Group}) = Base.SizeUnknown()

# NOTE: cheating here, not great, but nobody should use this function except
# iteration.
function Base.length(G::Group)
    return isfinite(G) ? order(Int, G) :
           throw(
        """You're trying to iterate over an infinite group.
        If you know what you're doing, choose an appropriate integer and redefine
        `Base.length(::$(typeof(G)))::Int`.""",
    )
end

################################################################################
# Default implementations
################################################################################

"""
    isfinite(G::Group)
Test whether group `G` is finite.

The default implementation is based on `Base.IteratorSize`. Only groups of
returning `Base.SizeUnknown()` should extend this method.
"""
function Base.isfinite(G::Group)
    IS = Base.IteratorSize(G)
    IS isa Base.HasLength && return true
    IS isa Base.HasShape && return true
    IS isa Base.IsInfinite && return false
    # else : IS isa Base.SizeUnknown
    throw(
        ArgumentError(
            """The finiteness of $G could not be determined based on its iterator type.
            You need to implement `Base.isfinite(::$(typeof(G))) yourself.""",
        ),
    )
end

"""
    istrivial(G::Group)
Test whether group `G` is trivial.

The default implementation is based on `isfinite` and `order`.
"""
function istrivial(G::Group)
    hasgens(G) && all(isone, gens(G)) && return true
    isfinite(G) && return isone(order(G))
    return false
end

hasgens(G::Group) = true

function gens(G::Group, i::Integer)
    hasgens(G) && return gens(G)[i]
    throw(ArgumentError("Group does not have assigned generators."))
end

function ngens(G::Group)
    hasgens(G) && return length(gens(G))
    # TODO: throw something more specific
    throw("Group does not have assigned generators.")
end
