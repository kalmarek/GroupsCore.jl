################################################################################
#
#   monoids_groups.jl : Interface for group and monoid parents
#
################################################################################
# Obligatory methods
################################################################################

function Base.one(M::Monoid)
    throw(InterfaceNotImplemented(:Monoid, "Base.one(::$(typeof(M)))"))
end

"""
    order([::Type{T} = BigInt, ]M::Monoid) where T
Return the order of `M` as an instance of `T`. If `M` is of infinite order,
`GroupsCore.InfiniteOrder` exception will be thrown.

!!! warning
    Only arbitrary sized integers are required to return a mathematically
    correct answer.
"""
function order(::Type{T}, M::Monoid) where {T}
    if !isfinite(M)
        throw(InfiniteOrder(M))
    end
    throw(
        InterfaceNotImplemented(
            :Monoid,
            "GroupsCore.order(::Type{$T}, ::$(typeof(M)))",
        ),
    )
end
order(M::Monoid) = order(BigInt, M)

"""
    gens(M::Monoid)
Return a random-access collection of generators of `G`.
"""
function gens(M::Monoid)
    throw(InterfaceNotImplemented(:Monoid, "GroupsCore.gens(::$(typeof(M)))"))
end

################################################################################
# Iterators
################################################################################

function Base.eltype(::Type{M}) where {M<:Monoid}
    throw(InterfaceNotImplemented(:Iteration, "Base.eltype(::Type{$M})"))
end

function Base.iterate(M::Monoid)
    hasgens(M) && throw(
        InterfaceNotImplemented(:Iteration, "Base.iterate(::$(typeof(M)))"),
    )
    throw(ArgumentError("Monoid does not have assigned generators."))
end

function Base.iterate(M::Monoid, state)
    hasgens(M) && throw(
        InterfaceNotImplemented(
            :Iteration,
            "Base.iterate(::$(typeof(M)), state)",
        ),
    )
    throw(ArgumentError("Monoid does not have assigned generators."))
end

"""
    IteratorSize(::Type{M}) where {M <: Monoid}
Given the type of a monoid, return one of the following values:
 * `Base.IsInfinite()` if all instances of groups of type `M` are infinite.
 * `Base.HasLength()` or `Base.HasShape{N}()` if all instances are finite.
 * `Base.SizeUnknown()` otherwise, [the default].
"""
Base.IteratorSize(::Type{<:Monoid}) = Base.SizeUnknown()

# NOTE: cheating here, not great, but nobody should use this function except
# iteration.
function Base.length(M::Monoid)
    return isfinite(M) ? order(Int, M) :
           throw(
        """You're trying to iterate over an infinite group.
        If you know what you're doing, choose an appropriate integer and redefine
        `Base.length(::$(typeof(M)))::Int`.""",
    )
end

################################################################################
# Default implementations
################################################################################

"""
    isfinite(M::Monoid)
Test whether monoid `M` is finite.

The default implementation is based on `Base.IteratorSize`. Only groups of
returning `Base.SizeUnknown()` should extend this method.
"""
function Base.isfinite(M::Monoid)
    IS = Base.IteratorSize(M)
    IS isa Base.HasLength && return true
    IS isa Base.HasShape && return true
    IS isa Base.IsInfinite && return false
    # else : IS isa Base.SizeUnknown
    throw(
        ArgumentError(
            """The finiteness of $M could not be determined based on its iterator type.
            You need to implement `Base.isfinite(::$(typeof(M))) yourself.""",
        ),
    )
end

"""
    istrivial(M::Monoid)
Test whether monoid `M` is trivial.

The default implementation is based on `isfinite` and `order`.
"""
function istrivial(M::Monoid)
    hasgens(M) && all(isone, gens(M)) && return true
    isfinite(M) && return isone(order(M))
    return false
end

hasgens(::Monoid) = true

function gens(M::Monoid, i::Integer)
    hasgens(M) && return gens(M)[i]
    throw(ArgumentError("Monoid does not have assigned generators."))
end

function ngens(M::Monoid)
    hasgens(M) && return length(gens(M))
    # TODO: throw something more specific
    throw(ArgumentError("Monoid does not have assigned generators."))
end
