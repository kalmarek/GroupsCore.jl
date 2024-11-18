################################################################################
#
#   elements.jl : Interface for monoid nad group elements
#
################################################################################
# Obligatory methods
################################################################################

"""
    parent(g::MonoidElement)
Return the parent object of the group element.
"""
function Base.parent(g::MonoidElement)
    throw(InterfaceNotImplemented(:Monoid, "Base.parent(::$(typeof(g)))"))
end

"""
    ==(g::El, h::El) where {El <: MonoidElement}
Return the _best effort_ equality for monoid elements.

If `==(g, h)` returns `true`` then the mathematical equality `g == h` holds.
However `==(g, h)` may return `false` even if `g` and `h` represent
mathematically equal group elements.

For example, in a finitely presented group, `==` may return the equality
of words.

!!! note
    This function may not return due to unsolvable word problem.
"""
function Base.:(==)(::El, ::El) where {El<:MonoidElement}
    throw(InterfaceNotImplemented(:Monoid, "Base.:(==)(::$El, ::$El)"))
end

Base.copy(g::MonoidElement) = deepcopy(g)

function Base.:(*)(::El, ::El) where {El<:MonoidElement}
    throw(InterfaceNotImplemented(:Monoid, "Base.:(*)(::$El, ::$El)"))
end

"""
    isfiniteorder(m::MonoidElement)
Return `true` if `m` is of finite order, possibly without computing it.

!!! note
    If finiteness of a group or monoid can be decided based on its type there
    is no need to extend `isfiniteorder` for its elements.
"""
function isfiniteorder(m::MonoidElement)
    isfinite(parent(m)) && return true
    throw(
        InterfaceNotImplemented(
            :Monoid,
            "GroupsCore.isfiniteorder(::$(typeof(m)))",
        ),
    )
end

# ---- group elements methods

function Base.inv(g::GroupElement)
    throw(InterfaceNotImplemented(:Group, "Base.inv(::$(typeof(g)))"))
end

################################################################################
# Default implementations
################################################################################

Base.one(m::MonoidElement) = one(parent(m))

"""
    order(m::MonoidElement)
    order(::Type{T}, m::MonoidElement) where T
Return the order of `m` as an instance of `T`. If `m` is of infinite order
`GroupsCore.InfiniteOrder` exception will be thrown.

!!! warning
    Only arbitrary sized integers are required to return a mathematicaly
    correct answer.
"""
function order(::Type{T}, m::MonoidElement) where {T}
    isfiniteorder(m) || throw(InfiniteOrder(m))
    isone(m) && return T(1)
    o = T(1)
    mm = m^2
    while mm ≠ m
        o += T(1)
        mm *= m
    end
    return o
end
order(m::MonoidElement) = order(BigInt, m)

# ---- group elements methods

"""
    conj(g::El, h::El) where {El <: GroupElement}
Return the conjugation of `g` by `h`, i.e. `inv(h)*g*h`.
"""
Base.conj(g::El, h::El) where {El<:GroupElement} = conj!(similar(g), g, h)

"""
    ^(g::El, h::El) where {El <: GroupElement}
Alias for [`conj`](@ref GroupsCore.conj).
"""
Base.:(^)(g::El, h::El) where {El<:GroupElement} = conj(g, h)

"""
    commutator(g::El, h::El, k::El...) where {El <: GroupElement}
Return the left associative iterated commutator ``[[g, h], ...]``, where
``[g, h] = g^{-1} h^{-1} g h``.
"""
function commutator(g::El, h::El, k::El...) where {El<:GroupElement}
    res = commutator!(similar(g), g, h)
    for l in k
        res = commutator!(res, res, l)
    end
    return res
end

Base.literal_pow(::typeof(^), g::GroupElement, ::Val{-1}) = inv(g)

function Base.:(/)(g::El, h::El) where {El<:GroupElement}
    return div_right!(similar(g), g, h)
end

################################################################################
# Default implementations that (might) need performance modification
################################################################################

Base.similar(g::MonoidElement) = one(g)
Base.isone(g::MonoidElement) = g == one(g)

function Base.:(^)(m::MonoidElement, n::Integer)
    n < 0 && return inv(m)^-n
    return Base.power_by_squaring(m, n)
end

function Base.hash(m::MonoidElement, h::UInt)
    h = hash(typeof(m), h)
    for fn in fieldnames(typeof(m))
        h = hash(getfield(m, fn), h)
    end
    return h
end

################################################################################
# Mutable API where modifications are recommended for performance reasons
################################################################################

"""
    one!(m::MonoidElement)
Return `one(m)`, possibly modifying `m`.
"""
one!(m::MonoidElement) = one(parent(m))

"""
    mul!(out::El, g::El, h::El) where {El <: MonoidElement}
Return `g*h`, possibly modifying `out`. Aliasing of `g` or `h` with `out` is
allowed.
"""
mul!(out::El, g::El, h::El) where {El<:MonoidElement} = g * h

# ---- group elements methods

"""
    inv!(out::El, g::El) where {El <: GroupElement}
Return `inv(g)`, possibly modifying `out`. Aliasing of `g` with `out` is
allowed.
"""
inv!(out::El, g::El) where {El<:GroupElement} = inv(g)

"""
    div_right!(out::El, g::El, h::El) where {El <: GroupElement}
Return `g*inv(h)`, possibly modifying `out`. Aliasing of `g` or `h` with `out`
is allowed.
"""
function div_right!(out::El, g::El, h::El) where {El<:GroupElement}
    return mul!(out, g, inv(h))
end

"""
    div_left!(out::El, g::El, h::El) where {El <: GroupElement}
Return `inv(h)*g`, possibly modifying `out`. Aliasing of `g` or `h` with `out`
is allowed.
"""
function div_left!(out::El, g::El, h::El) where {El<:GroupElement}
    out = (out === g || out === h) ? inv(h) : inv!(out, h)
    return mul!(out, out, g)
end

"""
    conj!(out::El, g::El, h::El) where {El <: GroupElement}
Return `inv(h)*g*h`, possibly modifying `out`. Aliasing of `g` or `h` with
`out` is allowed.
"""
function conj!(out::El, g::El, h::El) where {El<:GroupElement}
    out = (out === g || out === h) ? inv(h) : inv!(out, h)
    out = mul!(out, out, g)
    return mul!(out, out, h)
end

"""
    commutator!(out::El, g::El, h::El) where {El <: GroupElement}
Return `inv(g)*inv(h)*g*h`, possibly modifying `out`. Aliasing of `g` or `h`
with `out` is allowed.
"""
function commutator!(out::El, g::El, h::El) where {El<:GroupElement}
    # TODO: can we make commutator! with 3 arguments without allocation??
    out = conj!(out, g, h)
    return div_left!(out, out, g)
end
