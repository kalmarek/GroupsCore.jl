################################################################################
#
#   group_elements.jl : Interface for group elements
#
################################################################################
# Obligatory methods
################################################################################

@doc Markdown.doc"""
    parent(g::GroupElement)

Return the parent of the group element.
"""
Base.parent(g::GroupElement) =
    throw(InterfaceNotImplemented(:Group, "Base.parent(::$(typeof(g)))"))

@doc Markdown.doc"""
    parent_type(::Type{<:GroupElement})
    parent_type(g::GroupElement)

Return the type of parent of a subtype of `GroupElement`.
A shortcut `parent_type(g) = parent_type(typeof(g))` is provided for convenience.
"""
parent_type(::Type{GEl}) where {GEl <: GroupElement} =
    throw(InterfaceNotImplemented(
        :Group,
        "GroupsCore.parent_type(::Type{$GEl})"
       ))
parent_type(g::GroupElement) = parent_type(typeof(g))

@doc Markdown.doc"""
    ==(g::GEl, h::GEl) where {GEl <: GroupElement}

Return `true` if and only if the mathematical equality $g = h$ holds.

!!! note

    This function may not return, due to unsolvable word problem.
"""
Base.:(==)(g::GEl, h::GEl) where {GEl <: GroupElement} = throw(
    InterfaceNotImplemented(:Group, "Base.:(==)(::$GEl, ::$GEl)"),
)

@doc Markdown.doc"""
    isfiniteorder(g::GroupElement)

Return `true` if $g$ is of finite order, possibly without computing it.
"""
function isfiniteorder(g::GroupElement)
    isfinite(parent(g)) && return true
    throw(
        InterfaceNotImplemented(:Group, "GroupsCore.isfiniteorder(::$(typeof(g)))"),
    )
end

Base.deepcopy_internal(g::GroupElement, stackdict::IdDict) = throw(
    InterfaceNotImplemented(
        :Group,
        "Base.deepcopy_internal(::$(typeof(g)), ::IdDict)",
    ),
)
# TODO: Technically, it is not necessary to implement `deepcopy_internal` method
# if `parent(g)` can be reconstructed exactly from `g` (i.e. either it's cached,
# or a singleton). However by defining this fallback we force everybody to
# implement it, except isbits group elements.

@doc Markdown.doc"""
    inv(g::GroupElement)

Return $g^{-1}$, the group inverse.
"""
Base.inv(g::GroupElement) =
    throw(InterfaceNotImplemented(:Group, "Base.inv(::$(typeof(g)))"))

@doc Markdown.doc"""
    *(g::GEl, h::GEl) where {GEl <: GroupElement}

Return $g h$, the result of group binary operation.
"""
Base.:(*)(g::GEl, h::GEl) where {GEl <: GroupElement} = throw(
    InterfaceNotImplemented(
        :Group,
        "Base.:(*)(::$(typeof(g)), ::$(typeof(g)))",
    ),
)

################################################################################
# Default implementations
################################################################################

@doc Markdown.doc"""
    one(g::GroupElement)

Return the identity element in the group of $g$.
"""
Base.one(g::GroupElement) = one(parent(g))

@doc Markdown.doc"""
    order(::Type{I} = BigInt, g::GroupElement) where {I <: Integer}

Return the order of $g$ as an instance of `I`. If $g$ is of infinite order
`GroupsCore.InfiniteOrder` exception will be thrown.

!!! warning

    Only arbitrary sized integers are required to return a mathematically
    correct answer.
"""
function order(::Type{I}, g::GroupElement) where {I<:Integer}
    isfiniteorder(g) || throw(InfiniteOrder(g))
    o = one(I)
    isone(g) && return o
    oo = one(I)
    gg = MA.copy_if_mutable(g)
    while !isone(gg)
        oo = MA.add!(oo, o)
        gg = MA.mul!(gg, g)
    end
    return oo
end
order(g::GroupElement) = order(BigInt, g)

@doc Markdown.doc"""
    mul_left(g::GEl, h::GEl) where {GEl <: GroupElement}

Return $h g$.
"""
mul_left(g::GEl, h::GEl) where {GEl <: GroupElement} = h * g

function _conj_fallback(::MA.IsMutable, g::GEl, h::GEl) where {GEl <: GroupElement}
    return MA.mutable_operate_to!(similar(g), conj, g, h)
end
function _conj_fallback(::MA.NotMutable, g::GEl, h::GEl) where {GEl <: GroupElement}
    return inv(h) * g * h
end

@doc Markdown.doc"""
    conj(g::GEl, h::GEl) where {GEl <: GroupElement}

Return conjugation of $g$ by $h$, i.e. $h^{-1} g h$.
"""
function Base.conj(g::GEl, h::GEl) where {GEl <: GroupElement}
    _conj_fallback(MA.mutability(GEl), g, h)
end

@doc Markdown.doc"""
    ^(g::GEl, h::GEl) where {GEl <: GroupElement}

Alias for [`conj`](@ref GroupsCore.conj).
"""
Base.:(^)(g::GEl, h::GEl) where {GEl <: GroupElement} = conj(g, h)

function _comm_fallback(::MA.IsMutable, g::GEl, h::GEl, k::GEl...) where {GEl <: GroupElement}
    return MA.mutable_operate_to!(similar(g), comm, g, h, k...)
end
function _comm_fallback(::MA.NotMutable, g::GEl, h::GEl, k::GEl...) where {GEl <: GroupElement}
    return comm(inv(g) * inv(h) * g * h, k...)
end

@doc Markdown.doc"""
    comm(g::GEl, h::GEl, k::GEl...) where {GEl <: GroupElement}

Return the left associative iterated commutator $[[g, h], ...]$, where
$[g, h] = g^{-1} h^{-1} g h$.
"""
function comm(g::GEl, h::GEl, k::GEl...) where {GEl <: GroupElement}
    return _comm_fallback(MA.mutability(GEl), g, h, k...)
end
comm(g::GroupElement) = g

Base.literal_pow(::typeof(^), g::GroupElement, ::Val{-1}) = inv(g)

Base.:(/)(g::GEl, h::GEl) where {GEl <: GroupElement} =
    div_right!(similar(g), g, h)

################################################################################
# Default implementations that (might) need performance modification
################################################################################

@doc Markdown.doc"""
    similar(g::GroupElement)

Return a group element sharing the parent with $g$. Might be arbitrary and
possibly uninitialized.
"""
Base.similar(g::GroupElement) = one(g)

@doc Markdown.doc"""
    isone(g::GroupElement)

Return true if $g$ is the identity element.
"""
Base.isone(g::GroupElement) = g == one(g)

@doc Markdown.doc"""
    isequal(g::GEl, h::GEl) where {GEl <: GroupElement}

Return the "best effort" equality for group elements.

The implication `isequal(g, h)` → $g = h$, must be always satisfied, i.e.
`isequal(g, h)` might return `false` even if `g == h` holds (i.e. $g$ and $h$
are mathematically equal).

For example, in a finitely presented group, `isequal` may return the equality
of words.
"""
Base.isequal(g::GEl, h::GEl) where {GEl <: GroupElement} = g == h

function Base.:^(g::GroupElement, n::Integer)
    n == 0 && return one(g)
    n < 0 && return inv(g)^-n
    return Base.power_by_squaring(g, n)
end

# NOTE: Modification RECOMMENDED for performance reasons
Base.hash(g::GroupElement, h::UInt) = hash(typeof(g), h)

################################################################################
# Mutable API where modifications are recommended for performance reasons
################################################################################

@doc Markdown.doc"""
    div_right(g::GEl, h::GEl) where {GEl <: GroupElement}

Return $g h^{-1}$.
"""
div_right(g::GEl, h::GEl) where {GEl <: GroupElement} = g * inv(h)
function MA.mutable_operate_to!(out::GEl, ::typeof(div_right), g::GEl, h::GEl) where {GEl <: GroupElement}
    MA.mutable_operate_to!(out, inv, h)
    return MA.mutable_operate!(mul_left, out, g)
end

@doc Markdown.doc"""
    div_left(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}

Return $h^{-1} g$.
"""
div_left(g::GEl, h::GEl) where {GEl <: GroupElement} = inv(h) * g
function MA.mutable_operate_to!(out::GEl, ::typeof(div_left), g::GEl, h::GEl) where {GEl <: GroupElement}
    MA.mutable_operate_to!(out, inv, h)
    return MA.mutable_operate!(*, out, g)
end

@doc Markdown.doc"""
    conj!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}

Return $h^{-1} g h$, `possibly modifying `out`. Aliasing of `g` or `h` with
`out` is allowed.
"""
function MA.mutable_operate_to!(out::GEl, ::typeof(conj), g::GEl, h::GEl) where {GEl <: GroupElement}
    MA.mutable_operate_to!(out, inv, h)
    MA.mutable_operate!(*, out, g)
    return MA.mutable_operate!(*, out, h)
end

@doc Markdown.doc"""
    comm!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}

Return $g^{-1} h^{-1} g h$, possibly modifying `out`. Aliasing of `g` or `h`
with `out` is allowed.
"""
function MA.mutable_operate_to!(out::GEl, ::typeof(comm), g::GEl, h::GEl) where {GEl <: GroupElement}
    # TODO: can we make comm! with 3 arguments without allocation??
    MA.mutable_operate_to!(out, conj, g, h)
    MA.mutable_operate!(div_left, out, g)
    return out
end
function MA.mutable_operate_to!(out::GEl, ::typeof(comm), g::GEl, h1::GEl, h2::GEl, args::GEl...) where {GEl <: GroupElement}
    g1 = similar(g)
    MA.mutable_operate_to!(g1, comm, g, h1)
    return MA.mutable_operate_to!(out, comm, g1, h2, args...)
end

# For compatibility with `AbstractAlgebra`'s MutableArithmetics API
# and the MA API, we define these methods:
@doc Markdown.doc"""
    inv!(out::GEl, g::GEl) where {GEl <: GroupElement}
Return `inv(g)`, possibly modifying `out`. Aliasing of `g` with `out` is
allowed.
"""
function AbstractAlgebra.inv!(out::GEl, g::GEl) where {GEl <: GroupElement}
    if out === g
        return MA.operate!(inv, g)
    else
        return MA.operate_to!(out, inv, g)
    end
end
function AbstractAlgebra.mul!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
    if out === g
        return MA.operate!(*, g, h)
    elseif out === h
        return MA.operate!(mul_left, h, g)
    else
        return MA.operate_to!(out, *, g, h)
    end
end

@doc Markdown.doc"""
    one!(g::GroupElement)
Return `one(g)`, possibly modifying `g`.
"""
one!(g::GroupElement) = MA.operate!(one, g)

const UNARY_FUNCTIONS = Union{typeof(one), typeof(zero), typeof(inv)}
MA.operate(::typeof(one), g) = one(g)
MA.operate(op::UNARY_FUNCTIONS, g) = inv(g)
function MA.promote_operation(::UNARY_FUNCTIONS, ::Type{GEl}) where {GEl <: GroupElement}
    return GEl
end
const BINARY_FUNCTIONS = Union{typeof(mul_left), typeof(conj), typeof(div_right), typeof(div_left)}
MA.operate(op::BINARY_FUNCTIONS, g, h) = op(g, h)
function MA.promote_operation(::BINARY_FUNCTIONS, ::Type{GEl}, ::Type{GEl}) where {GEl <: GroupElement}
    return GEl
end
function MA.promote_operation(::typeof(*), ::Type{GEl}, ::Type{GEl}) where {GEl <: GroupElement}
    return GEl
end
MA.operate(op::typeof(comm), args::GEl...) where {GEl <: GroupElement} = op(args...)
function MA.promote_operation(::typeof(comm), ::Type{GEl}...) where {GEl <: GroupElement}
    return GEl
end

MA.mutability(::Type{AbstractAlgebra.Generic.Perm{I}}) where {I} = MA.IsMutable()
MA.mutable_copy(g::AbstractAlgebra.Generic.Perm) = deepcopy(g)
function MA.mutable_operate!(::typeof(one), p::AbstractAlgebra.Generic.Perm)
    for i in eachindex(p.d)
        p.d[i] = i
    end
    p.modified = false
    #TODO what do we do with the cycles ?
    return p
end
function MA.mutable_operate!(::typeof(inv), p::AbstractAlgebra.Generic.Perm{I}) where I
    return inv!(p)
end
function MA.mutable_operate_to!(out::AbstractAlgebra.Generic.Perm{I}, ::typeof(inv), p::AbstractAlgebra.Generic.Perm{I}) where I
    for i in eachindex(p.d)
        out.d[p[i]] = i
    end
    out.modified = true
    #TODO what do we do with the cycles ?
    return out
end
function _copy_to(p::AbstractAlgebra.Generic.Perm{I}, q::AbstractAlgebra.Generic.Perm{I}) where {I}
    p.d = q.d
    p.modified = q.modified
    if isdefined(q, :cycles)
        p.cycles = q.cycles
    end
    return p
end
function MA.mutable_operate!(op::Union{typeof(*), typeof(mul_left), typeof(div_right), typeof(div_left), typeof(conj)}, g::GEl, h::GEl) where {GEl <: GroupElement}
    a = op(g, h)
    return _copy_to(g, op(g, h))
end
function MA.mutable_operate!(::typeof(comm), args::GEl...) where {GEl <: GroupElement}
    return _copy_to(args[1], comm(args...))
end

@doc Markdown.doc"""
    div_right!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return $g h^{-1}$, possibly modifying `out`. Aliasing of `g` or `h` with `out`
is allowed.
"""
function div_right!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
    if g === out
        return MA.operate!(div_right, g, h)
    elseif h === out
        return g * MA.operate!(inv, h)
    else
        return MA.operate_to!(out, div_right, g, h)
    end
end

@doc Markdown.doc"""
    div_left!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return $h^{-1} g$, possibly modifying `out`. Aliasing of `g` or `h` with `out`
is allowed.
"""
function div_left!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
    if g === out
        return MA.operate!(div_left, g, h)
    elseif h === out
        return MA.operate!(inv, h) * g
    else
        return MA.operate_to!(out, div_left, g, h)
    end
end

@doc Markdown.doc"""
    conj!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return $h^{-1} g h$, `possibly modifying `out`. Aliasing of `g` or `h` with
`out` is allowed.
"""
function conj!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
    if out === g
        return MA.operate!(conj, g, h)
    elseif out === h
        gh = g * h
        return MA.operate!(*, MA.operate!(inv, h), gh)
    else
        return MA.operate_to!(out, conj, g, h)
    end
end

@doc Markdown.doc"""
    comm!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
Return $g^{-1} h^{-1} g h$, possibly modifying `out`. Aliasing of `g` or `h`
with `out` is allowed.
"""
function comm!(out::GEl, g::GEl, h::GEl) where {GEl <: GroupElement}
    if out === g
        return MA.operate!(comm, g, h)
    elseif out === h
        out = conj!(out, g, h)
        return MA.operate!(div_left, out, g)
    else
        return MA.operate_to!(out, comm, g, h)
    end
    # TODO: can we make comm! with 3 arguments without allocation??
    out = conj!(out, g, h)
    return div_left!(out, out, g)
end
