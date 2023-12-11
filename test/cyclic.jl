using Random

struct CyclicGroup <: GroupsCore.Group
    order::UInt
end

struct CyclicGroupElement <: GroupsCore.GroupElement
    residual::UInt
    parent::CyclicGroup
    CyclicGroupElement(n::Integer, C::CyclicGroup) = new(n % C.order, C)
end

Base.one(C::CyclicGroup) = CyclicGroupElement(0, C)

Base.eltype(::Type{CyclicGroup}) = CyclicGroupElement
Base.iterate(C::CyclicGroup) = one(C), 1
function Base.iterate(C::CyclicGroup, state)
    return (
        state < C.order ? (CyclicGroupElement(state, C), state + 1) : nothing
    )
end
Base.IteratorSize(::Type{CyclicGroup}) = Base.HasLength()

GroupsCore.order(::Type{T}, C::CyclicGroup) where {T<:Integer} = T(C.order)
GroupsCore.gens(C::CyclicGroup) = [CyclicGroupElement(1, C)]

GroupsCore.parent(c::CyclicGroupElement) = c.parent
function Base.:(==)(g::CyclicGroupElement, h::CyclicGroupElement)
    return parent(g) === parent(h) && g.residual == h.residual
end

function Base.inv(g::CyclicGroupElement)
    return (C = parent(g); CyclicGroupElement(order(UInt, C) - g.residual, C))
end

function Base.:(*)(g::CyclicGroupElement, h::CyclicGroupElement)
    @assert parent(g) === parent(h)
    C = parent(g)
    return CyclicGroupElement(g.residual + h.residual, C)
end

################## Implementing Group Interface Done!

#=
### Possible performance modifications:

NOTE: Since CyclicGroupElement is immutable there is no need to implement in-place mutable arithmetic.

Base.isone(g::CyclicGroupElement) = iszero(g.residual)

function GroupsCore.order(::Type{I}, g::CyclicGroupElement) where {I<:Integer}
    isone(g) && return one(I)
    o = order(I, parent(g))
    return div(o, gcd(I(g.residual), o))
end

Base.hash(g::CyclicGroupElement, h::UInt) = hash(g.residual, hash(parent(g), h))

=#

### end of Group[Element] methods

# Some eye-candy if you please
function Base.show(io::IO, C::CyclicGroup)
    return print(io, "Group of residues modulo $(order(Int, C))")
end
function Base.show(io::IO, c::CyclicGroupElement)
    return print(io, Int(c.residual), " (mod ", order(Int, parent(c)), ")")
end
