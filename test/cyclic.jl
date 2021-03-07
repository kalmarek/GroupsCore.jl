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
Base.iterate(C::CyclicGroup, state) =
    (state < C.order ? (CyclicGroupElement(state, C), state + 1) : nothing)
Base.length(C::CyclicGroup) = C.order

GroupsCore.order(::Type{T}, C::CyclicGroup) where {T<:Integer} = T(C.order)
GroupsCore.gens(C::CyclicGroup) = [CyclicGroupElement(1, C)]

function Base.rand(
    rng::Random.AbstractRNG,
    rs::Random.SamplerTrivial{<:CyclicGroup},
)
    C = rs[]
    return CyclicGroupElement(rand(0:C.order-1), C)
end

GroupsCore.parent(c::CyclicGroupElement) = c.parent
GroupsCore.parent_type(::Type{CyclicGroupElement}) = CyclicGroup
GroupsCore.istrulyequal(g::CyclicGroupElement, h::CyclicGroupElement) =
    parent(g) === parent(h) && g.residual == h.residual

GroupsCore.hasorder(g::CyclicGroupElement) = true

# since CyclicGroupElement is isbits, there is no need to define
# Base.deepcopy_internal(g::CyclicGroupElement, ::IdDict) =
#     CyclicGroupElement(deepcopy(g.residual), parent(g))

Base.inv(g::CyclicGroupElement) =
    (C = parent(g); CyclicGroupElement(order(UInt, C) - g.residual, C))

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
Base.show(io::IO, C::CyclicGroup) =
    print(io, "Group of residuals modulo $(order(Int, C))")
Base.show(io::IO, c::CyclicGroupElement) =
    print(io, Int(c.residual), " (mod ", order(Int, parent(c)), ")")
