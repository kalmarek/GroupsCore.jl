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

GroupsCore.parent(c::InfCyclicGroupElement) = InfCyclicGroup()
Base.:(==)(g::InfCyclicGroupElement, h::InfCyclicGroupElement) = g.val == h.val

Base.inv(g::InfCyclicGroupElement) = InfCyclicGroupElement(-g.val)

Base.:(*)(g::InfCyclicGroupElement, h::InfCyclicGroupElement) =
    InfCyclicGroupElement(g.val + h.val)

GroupsCore.isfiniteorder(g::InfCyclicGroupElement) = isone(g) ? true : false

# Some eye-candy if you please
Base.show(io::IO, C::InfCyclicGroup) = print(io, "Infinite cyclic group")
Base.show(io::IO, c::InfCyclicGroupElement) = print(io, c.val)
