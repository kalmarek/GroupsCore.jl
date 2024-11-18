struct CyclicMonoid <: GroupsCore.Monoid
    f::Vector{UInt}
    function CyclicMonoid(n::Integer)
        @assert n ≥ 1
        return new([2:n; 2])
    end
end

struct CyclicMonoidElement <: GroupsCore.MonoidElement
    images::Vector{UInt}
    parent::CyclicMonoid
    function CyclicMonoidElement(vec::AbstractVector, C::CyclicMonoid)
        l = length(C.f)
        @assert length(vec) == l
        @assert all(i -> 0 ≤ i ≤ l, vec)
        return new(vec, C)
    end
end

Base.one(C::CyclicMonoid) = CyclicMonoidElement(1:length(C.f), C)

Base.eltype(::Type{CyclicMonoid}) = CyclicMonoidElement
Base.iterate(C::CyclicMonoid) = one(C), gens(C, 1)
function Base.iterate(C::CyclicMonoid, x)
    f = gens(C, 1)
    xf = x * f
    return xf == f ? (x, nothing) : (x, xf)
end
Base.iterate(::CyclicMonoid, ::Nothing) = nothing
Base.IteratorSize(::Type{CyclicMonoid}) = Base.HasLength()

GroupsCore.order(::Type{T}, C::CyclicMonoid) where {T<:Integer} = T(length(C.f))
GroupsCore.gens(C::CyclicMonoid) = (CyclicMonoidElement(C.f, C),)

GroupsCore.parent(c::CyclicMonoidElement) = c.parent
function Base.:(==)(g::CyclicMonoidElement, h::CyclicMonoidElement)
    return parent(g) === parent(h) && g.images == h.images
end

function Base.:(*)(g::CyclicMonoidElement, h::CyclicMonoidElement)
    @assert parent(g) === parent(h)
    return CyclicMonoidElement(h.images[g.images], parent(g))
end

function Base.deepcopy_internal(g::CyclicMonoidElement, stack_dict::IdDict)
    if !haskey(stack_dict, g)
        stack_dict[g] = CyclicMonoidElement(
            Base.deepcopy_internal(g.images, stack_dict),
            parent(g),
        )
    end
    return stack_dict[g]
end

################## Implementing GroupsCore Interface Done!

#=
### Possible performance modifications:

NOTE: Since CyclicMonoidElement is immutable there is no need to implement in-place mutable arithmetic.
Base.isone(m::CyclicMonoidElement) = m.images == 1:length(m.images)

Base.hash(m::CyclicMonoidElement, h) = hash(m.images, hash(parent(m), h))
=#

### end of Monoid[Element] methods

# Some eye-candy if you please
function Base.show(io::IO, C::CyclicMonoid)
    return print(io, "Cyclic monoid on $(1:length(C.f))")
end
function Base.show(io::IO, c::CyclicMonoidElement)
    print(io, 1:length(c.images), " → ")
    join(io, c.images, ", ")
    return nothing
end
