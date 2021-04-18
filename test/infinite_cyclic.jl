struct InfCyclicGroup <: GroupsCore.Group end

struct InfCyclicGroupElement <: GroupsCore.GroupElement
    val::BigInt # not isbits
    InfCyclicGroupElement(i::Integer) = new(convert(BigInt, i))
end

Base.one(C::InfCyclicGroup) = InfCyclicGroupElement(0)

Base.eltype(::Type{InfCyclicGroup}) = InfCyclicGroupElement
Base.iterate(C::InfCyclicGroup) = one(C), 0
function Base.iterate(C::InfCyclicGroup, state)
    state > 0 && return InfCyclicGroupElement(-state), -state
    return InfCyclicGroupElement(state+1), state+1
end
Base.IteratorSize(::Type{InfCyclicGroup}) = Base.IsInfinite()

GroupsCore.gens(C::InfCyclicGroup) = [InfCyclicGroupElement(1)]

function Base.rand(
    rng::Random.AbstractRNG,
    rs::Random.SamplerTrivial{<:InfCyclicGroup},
)
    return InfCyclicGroupElement(rand(Int))
end

GroupsCore.parent(c::InfCyclicGroupElement) = InfCyclicGroup()
GroupsCore.parent_type(::Type{InfCyclicGroupElement}) = InfCyclicGroup
Base.:(==)(g::InfCyclicGroupElement, h::InfCyclicGroupElement) = g.val == h.val

# since InfCyclicGroupElement is NOT isbits, we need to define
Base.deepcopy_internal(g::InfCyclicGroupElement, ::IdDict) =
    InfCyclicGroupElement(deepcopy(g.val))

Base.inv(g::InfCyclicGroupElement) = InfCyclicGroupElement(-g.val)

Base.:(*)(g::InfCyclicGroupElement, h::InfCyclicGroupElement) =
    InfCyclicGroupElement(g.val + h.val)

GroupsCore.isfiniteorder(g::InfCyclicGroupElement) = isone(g) ? true : false

# Some eye-candy if you please
Base.show(io::IO, C::InfCyclicGroup) = print(io, "Infinite cyclic group")
Base.show(io::IO, c::InfCyclicGroupElement) = print(io, c.val)
