## `GroupElement` interface

### Obligatory methods for `GroupElement`

AbstractAlgebra.parent(g::GroupElement) = throw(
    InterfaceNotSatisfied(:Group, "AbstractAlgebra.parent(::$(typeof(g)))"),
)

# TODO: Do we actually need this?
AbstractAlgebra.parent_type(GEl::Type{<:GroupElement}) = throw(
    InterfaceNotSatisfied(:Group, "AbstractAlgebra.parent_type(::$GEl)"),
)
"""
    istrulyequal(g::GEl, h::GEl) where {GEl<:GroupElement}
Return the mathematical equality of group elements.

This function may not return due to e.g. unsolvable word problem in groups.
"""
istrulyequal(g::GEl, h::GEl) where {GEl<:GroupElement} =
    throw(InterfaceNotSatisfied(:Group, "istrulyequal(::$GEl, ::$GEl)"))

"""
    hasorder(g::GroupElement)
Return `true` if `g` has finite order (without computing it).
"""
hasorder(g::GroupElement) =
    throw(InterfaceNotSatisfied(:Group, "hasorder(::$(typeof(g)))"))

#=
"""
    Base.deepcopy_internal(g::GroupElement, ::IdDict)
Return a completely intependent copy of a group element `g` without copying its parent.

That is `parent(g) === parent(deepcopy(g))` must be satisfied. It is not necessary to implement this method if `parent(g)` can be reconstructed exactly from `g`.
"""
Base.deepcopy_internal(g::GroupElement, stackdict::IdDict) = throw(
    InterfaceNotSatisfied(
        :Group,
        "Base.deepcopy_internal(::$(typeof(g)), ::IdDict)",
    ),
)
=#

Base.inv(g::GroupElement) =
    throw(InterfaceNotSatisfied(:Group, "Base.inv(::$(typeof(g)))"))

### Default implementations for `GroupElement`

#### Modification not recommended
Base.one(g::GroupElement) = one(parent(g))

AbstractAlgebra.order(g::GroupElement) = order(BigInt, g)

"""
    Base.conj(g::GEl, h::GEl) where {GEl<:GroupElement}
Return conjugation of `g` by `h`, i.e. `h¯¹gh`.
See also the in-place version `conj!`
"""
Base.conj(g::GEl, h::GEl) where {GEl<:GroupElement} = conj!(similar(g), g, h)
comm(g::GEl, h::GEl) where {GEl<:GroupElement} = comm!(similar(g), g, h, tmp=similar(g))

Base.literal_pow(typeof(^), g::GroupElement, ::Val{-1}) = inv(g)

Base.:(/)(g::GEl, h::GEl) where GEl<:GroupElement = mul!(similar(g), g, inv(h))

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

# aliasing of g and h with out is allowed;
div_right!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement} = mul!(out, g, inv(h))

# aliasing of g and h with out is allowed;
function div_left!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    out = (out === g || out === h ? inv(h), inv!(out, h))
    return mul!(out, out, g)
end

#### Modification RECOMMENDED for performance reasons

function AbstractAlgebra.order(::Type{I}, g::GroupElement) where {I<:Integer}
    hasorder(g) || throw("$g does not seem to have finite order")
    isone(m) && return I(1)
    o = I(1)
    _one = one(g)
    mm = deepcopy(m)
    while mm != _one
        o += I(1)
        mm *= m
    end
    return o
end

Base.hash(g::GroupElement, h::UInt) = hash(typeof(g), h)

##### Mutable API

one!(g::GroupElement) = one(parent(g))
# aliasing of g with out is allowed
AbstractAlgebra.inv!(out::GEl, g::GEl) where {GEl<:GroupElement} = inv(g)

# aliasing of g and h with out is allowed
AbstractAlgebra.mul!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement} = g*h

# aliasing of g and h with out is allowed
function conj!(out::GEl, g::GEl, h::GEl) where {GEl<:GroupElement}
    out = (out === g || out === h ? inv(h), inv!(out, h))
    out = mul!(out, out, g)
    return mul!(out, out, h)
end

# aliasing of g and h with out is allowed;
# aliasing with tmp is NOT allowed → there is a 3 argument version (allocates 1 element)
# TODO: can we make comm! with 3 arguments without allocation??
function comm!(out::GEl, g::GEl, h::GEl; tmp::GEl=similar(out)) where {GEl<:GroupElement}
    tmp = conj!(tmp, g, h)
    out = inv!(out, g)
    return mul!(out, out, tmp)
end
