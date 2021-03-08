################################################################################
#
# group_element.jl : `GroupElement` interface
#
################################################################################

# Creator: Marek Kaluba

################################################################################
# Data types and parent methods
################################################################################

@doc Markdown.doc"""
    parent(g::GroupElement)

Return the group that the element belongs to.
"""
Base.parent(g::GroupElement) =
    throw(InterfaceNotImplemented(:Group, "Base.parent(::$(typeof(g)))"))

@doc Markdown.doc"""
    parent_type(g::G) where {G <: GroupElement}

Return the type of `g`'s parent.
"""
AbstractAlgebra.parent_type(g::G) where {G <: GroupElement} = throw(
    InterfaceNotImplemented(:Group, "GroupsCore.parent_type(::Type{$G})")
)

################################################################################
# Comparison
################################################################################

@doc Markdown.doc"""
    istrulyequal(g::G, h::H) where {G <: GroupElement, H <: GroupElement}

Return true if $g = h$, else return false. Function may throw error, for example
if there is a unsolvable word problem in groups.
"""
istrulyequal(g::G, h::H) where {G <: GroupElement, H <: GroupElement} = throw(
    InterfaceNotImplemented(:Group, "GroupsCore.istrulyequal(::$G, ::$H)"),
)

################################################################################
# Basic manipulation
################################################################################

@doc Markdown.doc"""
    deepcopy_internal(g::GroupElement, stackdict::IdDict)

Return an independent copy of $g$ without copying its parent.
"""
function Base.deepcopy_internal(g::GroupElement, stackdict::IdDict)
  throw(InterfaceNotImplemented(
      :Group, "Base.deepcopy_internal(::$(typeof(g)), ::IdDict)",
     ))
end
# That is `parent(g) === parent(deepcopy(g))` must be satisfied. There is no
# need to implement this method if `g` is `isbits`.

# TODO: Technically, it is not necessary to implement `deepcopy_internal` method
# if `parent(g)` can be reconstructed exactly from `g` (i.e. either it's cached,
# or a singleton). However by defining this fallback we force everybody to
# implement it, except isbits group elements.

@doc Markdown.doc"""
    Base.one(g::GroupElement)

Return the identity of the group.
"""
Base.one(g::GroupElement) = one(parent(g))

@doc Markdown.doc"""
    Base.inv(g::GroupElement)

Return the inverse of $g$.
"""
function Base.inv(g::GroupElement)
  throw(InterfaceNotImplemented(:Group, "Base.inv(::$(typeof(g)))"))
end

################################################################################
# Order
################################################################################

@doc Markdown.doc"""
    hasorder(g::GroupElement)

Return true if $g$ is of finite order, else return false.
"""
hasorder(g::GroupElement) = throw(
    InterfaceNotImplemented(:Group, "GroupsCore.hasorder(::$(typeof(g)))"),
)

@doc Markdown.doc"""
    order(::Type{I} = BigInt, g::GroupElement) where {I <: Union{Integer, fmpz}}

Return the order of $g$ as an integer of type `I`.
"""
function order(::Type{I} = BigInt, g::GroupElement) where {I <: Union{Integer, fmpz}}
  hasorder(g) || throw("$g does not seem to have finite order")
  isone(g) && return I(1)
  o = I(1)
  gg = deepcopy(g)
  out = similar(g)
  while !isone(gg)
    o += I(1)
    gg = mul!(out, gg, g)
  end
  return o
end

################################################################################
# Binary operations and functions
################################################################################

@doc Markdown.doc"""
    *(g::G, h::H) where {G <: GroupElement, H <: GroupElement}

Return the result of group binary operation $g \cdot h$.
"""
function Base.:(*)(g::G, h::H) where {G <: GroupElement, H <: GroupElement}
  throw(InterfaceNotImplemented(
      :Group, "Base.:(*)(::$(typeof(g)), ::$(typeof(g)))"
     ))
end

@doc Markdown.doc"""
    conj(g::G, h::H) where {G <: GroupElement, H <: GroupElement}

Return the conjucation of $g$ by $h$, in other words $h^{-1} g h$.
"""
function Base.conj(g::G, h::H) where {G <: GroupElement, H <: GroupElement}
  conj!(similar(g), g, h)
end

@doc Markdown.doc"""
    Base.:(^)(g::G, h::H) where {G <: GroupElement, H <: GroupElement}

Alias for `conj(g, h)`.
"""
Base.:(^)(g::G, h::H) where {G <: GroupElement, H <: GroupElement} = conj(g, h)

@doc Markdown.doc"""
    comm(g::G, h::H, k::K...)

Return the commutator $g^{-1} h^{-1} ... g h$, where the $...$ implies that more
arguments can be placed.
"""
function comm(g::G, h::H, k::K...)
    where {G <: GroupElement, H <: GroupElement, K <:GroupElement}
  res = comm!(similar(g), g, h)
  for l in k
    res = comm!(res, res, l)
  end
  return res
end

Base.literal_pow(::typeof(^), g::GroupElement, ::Val{-1}) = inv(g)

@doc Markdown.doc"""
    Base.:(/)(g::G, h::H) where {G <: GroupElement, H <: GroupElement}

Return $g h^{-1}$.
"""
function Base.:(/)(g::G, h::H) where {G <: GroupElement, H <: GroupElement}
  div_right!(similar(g), g, h)
end

#### Modification possible for performance reasons

"""
    similar(g::GroupElement)
Return an arbitrary (and possibly uninitialized) group element sharing the parent with `g`.
"""
Base.similar(g::GroupElement) = one(g)
# optimization: determine triviality of `g` without constructing `one(g)`.
Base.isone(g::GroupElement) = g == one(g)

# TODO: semantic clash: isequal is weaker in julia than `==`, we need it the other way round here → istrulyequal
"""
    ==(g::GEl, h::GEl) where {GEl<:GroupElement}
The "best effort" equality for group elements.

Depending on the group this might, or might not be the correct equality, which can be obtained using `Base.isequal`. Nonetheless the implication `g == h` → `istrulyequal(g, h)` must be always satisfied, i.e. "best effort" equality might return `false` even when group elements are equal.

For example in a finitely presented group, `==` may return the equality of words.
"""
Base.:(==)(g::GEl, h::GEl) where {GEl<:GroupElement} = istrulyequal(g, h)

function Base.:^(g::GroupElement, n::Integer)
    n == 0 && return one(g)
    n < 0 && return inv(g)^-n
    return Base.power_by_squaring(g, n)
end

#### Modification RECOMMENDED for performance reasons

Base.hash(g::GroupElement, h::UInt) = hash(typeof(g), h)

##### Mutable API
"""
    one!(g::GroupElement)
Return `one(g)`, possibly modifying `g`.
"""
one!(g::GroupElement) = one(parent(g))

"""
    inv!(out::GEl, g::GEl) where GEl<:GroupElement
Return `inv(g)`, possibly modifying `out`.

Aliasing of `g` with `out` is allowed.
"""
AbstractAlgebra.inv!(out::GEl, g::GEl) where {GEl<:GroupElement} = inv(g)

"""
    mul!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement
Return `g*h`, possibly modifying `out`.

Aliasing of `g` or `h` with `out` is allowed.
"""
AbstractAlgebra.mul!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement} = g * h

"""
    div_right!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement
Return `g*h^-1`, possibly modifying `out`.

Aliasing of `g` or `h` with `out` is allowed;
"""
div_right!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement} =
    mul!(out, g, inv(h))

"""
    div_left!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement
Return `h^-1*g`, possibly modifying `out`.

Aliasing of `g` or `h` with `out` is allowed;
"""
function div_left!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    out = (out === g || out === h) ? inv(h) : inv!(out, h)
    return mul!(out, out, g)
end
"""
    conj!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement
Return `h^-1*g*h, `possibly modifying `out`.

Aliasing of `g` or `h` with `out` is allowed.
"""
function conj!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    out = (out === g || out === h) ? inv(h) : inv!(out, h)
    out = mul!(out, out, g)
    return mul!(out, out, h)
end

"""
    comm!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement
Return `g^-1*h^-1*g*h, `possibly modifying `out`.

Aliasing of `g` or `h` with `out` is allowed.
"""
# TODO: can we make comm! with 3 arguments without allocation??
function comm!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    out = conj!(out, g, h)
    return div_left!(out, out, g)
end
