################################################################################
#
#   group_elements.jl : Interface for group elements
#
################################################################################
# Obligatory methods
################################################################################

"""
    parent(g::GroupElement)
Return the parent object of the group element.
"""
Base.parent(g::GroupElement) =
    throw(InterfaceNotImplemented(:Group, "Base.parent(::$(typeof(g)))"))

"""
    ==(g::GEl, h::GEl) where {GEl <: GroupElement}
Return the _best effort_ equality for group elements.

If `==(g, h)` returns `true`` then the mathematical equality `g == h` holds.
However `==(g, h)` may return `false` even if `g` and `h` represent
mathematically equal group elements.

For example, in a finitely presented group, `==` may return the equality
of words.

!!! note
    This function may not return due to unsolvable word problem.
"""
Base.:(==)(g::GEl, h::GEl) where {GEl<:GroupElement} =
    throw(InterfaceNotImplemented(:Group, "Base.:(==)(::$GEl, ::$GEl)"))

Base.copy(g::GroupElement) = deepcopy(g)

function Base.inv(g::GroupElement)
    throw(InterfaceNotImplemented(:Group, "Base.inv(::$(typeof(g)))"))
end

function Base.:(*)(g::GEl, h::GEl) where {GEl<:GroupElement}
    throw(
        InterfaceNotImplemented(
            :Group,
            "Base.:(*)(::$(typeof(g)), ::$(typeof(g)))",
        ),
    )
end

"""
    isfiniteorder(g::GroupElement)
Return `true` if `g` is of finite order, possibly without computing it.

!!! note
    If finiteness of a group can be decided based on its type there is no need
    to extend `isfiniteorder` for its elements.
"""
function isfiniteorder(g::GroupElement)
    isfinite(parent(g)) && return true
    throw(
        InterfaceNotImplemented(
            :Group,
            "GroupsCore.isfiniteorder(::$(typeof(g)))",
        ),
    )
end

################################################################################
# Default implementations
################################################################################

Base.one(g::GroupElement) = one(parent(g))

"""
    order([::Type{T} = BigInt, ]g::GroupElement) where T
Return the order of `g` as an instance of `T`. If `g` is of infinite order
`GroupsCore.InfiniteOrder` exception will be thrown.

!!! warning
    Only arbitrary sized integers are required to return a mathematically
    correct answer.
"""
function order(::Type{T}, g::GroupElement) where {T}
    isfiniteorder(g) || throw(InfiniteOrder(g))
    isone(g) && return T(1)
    o = T(1)
    gg = deepcopy(g)
    out = similar(g)
    while !isone(gg)
        o += T(1)
        gg = mul!(out, gg, g)
    end
    return o
end
order(g::GroupElement) = order(BigInt, g)

"""
    conj(g::GEl, h::GEl) where {GEl <: GroupElement}
Return the conjugation of `g` by `h`, i.e. `inv(h)*g*h`.
"""
Base.conj(g::GEl, h::GEl) where {GEl<:GroupElement} = conj!(similar(g), g, h)

"""
    ^(g::GEl, h::GEl) where {GEl <: GroupElement}
Alias for [`conj`](@ref GroupsCore.conj).
"""
Base.:(^)(g::GEl, h::GEl) where {GEl<:GroupElement} = conj(g, h)

"""
    commutator(g::GEl, h::GEl, k::GEl...) where {GEl <: GroupElement}
Return the left associative iterated commutator ``[[g, h], ...]``, where
``[g, h] = g^{-1} h^{-1} g h``.
"""
function commutator(g::GEl, h::GEl, k::GEl...) where {GEl<:GroupElement}
    res = commutator!(similar(g), g, h)
    for l in k
        res = commutator!(res, res, l)
    end
    return res
end

Base.literal_pow(::typeof(^), g::GroupElement, ::Val{-1}) = inv(g)

function Base.:(/)(g::GEl, h::GEl) where {GEl<:GroupElement}
    return div_right!(similar(g), g, h)
end

################################################################################
# Default implementations that (might) need performance modification
################################################################################

Base.similar(g::GroupElement) = one(g)
Base.isone(g::GroupElement) = g == one(g)

function Base.:(^)(g::GroupElement, n::Integer)
    n < 0 && return inv(g)^-n
    return Base.power_by_squaring(g, n)
end

function Base.hash(g::GroupElement, h::UInt)
    h = hash(typeof(g), h)
    for fn in fieldnames(typeof(g))
        h = hash(getfield(g, fn), h)
    end
    return h
end

################################################################################
# Mutable API where modifications are recommended for performance reasons
################################################################################

"""
    one!(g::GroupElement)
Return `one(g)`, possibly modifying `g`.
"""
one!(g::GroupElement) = one(parent(g))

"""
    inv!(out::GEl, g::GEl) where {GEl <: GroupElement}
Return `inv(g)`, possibly modifying `out`. Aliasing of `g` with `out` is
allowed.
"""
inv!(out::GEl, g::GEl) where {GEl<:GroupElement} = inv(g)

"""
    mul!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return `g*h`, possibly modifying `out`. Aliasing of `g` or `h` with `out` is
allowed.
"""
mul!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement} = g * h

"""
    div_right!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return `g*inv(h)`, possibly modifying `out`. Aliasing of `g` or `h` with `out`
is allowed.
"""
div_right!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement} =
    mul!(out, g, inv(h))

"""
    div_left!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return `inv(h)*g`, possibly modifying `out`. Aliasing of `g` or `h` with `out`
is allowed.
"""
function div_left!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    out = (out === g || out === h) ? inv(h) : inv!(out, h)
    return mul!(out, out, g)
end

"""
    conj!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return `inv(h)*g*h`, possibly modifying `out`. Aliasing of `g` or `h` with
`out` is allowed.
"""
function conj!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    out = (out === g || out === h) ? inv(h) : inv!(out, h)
    out = mul!(out, out, g)
    return mul!(out, out, h)
end

"""
    commutator!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return `inv(g)*inv(h)*g*h`, possibly modifying `out`. Aliasing of `g` or `h`
with `out` is allowed.
"""
function commutator!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    # TODO: can we make commutator! with 3 arguments without allocation??
    out = conj!(out, g, h)
    return div_left!(out, out, g)
end
