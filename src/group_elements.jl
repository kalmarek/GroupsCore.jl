## `GroupElement` interface

### Obligatory methods for `GroupElement`

Base.parent(g::GroupElement) =
    throw(InterfaceNotImplemented(:Group, "Base.parent(::$(typeof(g)))"))

"""
    parent_type(element_type)
Given the type of an element return the type of its parent.
"""
AbstractAlgebra.parent_type(GEl::Type{<:GroupElement}) = throw(
    InterfaceNotImplemented(:Group, "GroupsCore.parent_type(::Type{$GEl})"),
)

"""
    istrulyequal(g::GEl, h::GEl) where {GEl<:GroupElement}
Return the mathematical equality of group elements.

This function may not return due to e.g. unsolvable word problem in groups.
"""
istrulyequal(g::GEl, h::GEl) where {GEl<:GroupElement} = throw(
    InterfaceNotImplemented(:Group, "GroupsCore.istrulyequal(::$GEl, ::$GEl)"),
)

"""
    hasorder(g::GroupElement)
Return `true` if `g` has finite order (without computing it).
"""
hasorder(g::GroupElement) = throw(
    InterfaceNotImplemented(:Group, "GroupsCore.hasorder(::$(typeof(g)))"),
)

"""
    deepcopy_internal(g::GroupElement, ::IdDict)
Return a completely intependent copy of group element `g` **without copying its parent**.

That is `parent(g) === parent(deepcopy(g))` must be satisfied. There is no need to implement this method if `g` is `isbits`.
"""
Base.deepcopy_internal(g::GroupElement, stackdict::IdDict) = throw(
    InterfaceNotImplemented(
        :Group,
        "Base.deepcopy_internal(::$(typeof(g)), ::IdDict)",
    ),
)
# TODO: Technically, it is not necessary to implement `deepcopy_internal` method if `parent(g)` can be reconstructed exactly from `g` (i.e. either it's cached, or a singleton). However by defining this fallback we force everybody to implement it, except isbits group elements.
"""
    inv(g::GroupElement)
Return the group inverse of `g`
"""
Base.inv(g::GroupElement) =
    throw(InterfaceNotImplemented(:Group, "Base.inv(::$(typeof(g)))"))
"""
    (*)(g::GEl, h::GEl) where GEl<:GroupElement
Return the result of group binary operation on `g` and `h`.
"""
Base.:(*)(g::GEl, h::GEl) where {GEl<:GroupElement} = throw(
    InterfaceNotImplemented(
        :Group,
        "Base.:(*)(::$(typeof(g)), ::$(typeof(g)))",
    ),
)

### Default implementations for `GroupElement`

#### Modification not recommended
"""
    one(g::GroupElement)
Return the identity element of the parent group of `g`.
"""
Base.one(g::GroupElement) = one(parent(g))

"""
    order([BigInt, ]g::GroupElement)
    order(I::Type{<:Integer}, g::GroupElement)
Return the order of `g` as an instance of `I`.

Only arbitrary size integers are required to return mathematically correct answer.
"""
AbstractAlgebra.order(g::GroupElement) = order(BigInt, g)

"""
    conj(g::GEl, h::GEl) where {GEl<:GroupElement}
Return conjugation of `g` by `h`, i.e. `h^-1*g*h`.
"""
Base.conj(g::GEl, h::GEl) where {GEl<:GroupElement} = conj!(similar(g), g, h)

"""
    ^(g::GEl, h::GEl) where {GEl<:GroupElement}
Conjugation action of `h` on `g`. See `conj`.
"""
Base.:(^)(g::GEl, h::GEl) where {GEl<:GroupElement} = conj(g, h)

"""
    comm(g::GEl, h::GEl[, Vararg{GEl}...) where GEl<:GroupElement
Return the commutator `inv(g)*inv(h)*g*h` of `g` and `h`.

The `Vararg` version returns the repeated (`foldl`) commutator, i.e.
`comm(g, h, k) == comm(comm(g, h), k)`.
"""
comm(g::GEl, h::GEl) where {GEl<:GroupElement} = comm!(similar(g), g, h)

function comm(args::Vararg{GEl,N}) where {GEl<:GroupElement,N}
    N == 0 && throw("Commutator of empty collection is undefined")
    N == 1 && return one(first(args))
    @assert N > 2
    a, b, args = args
    comm(comm(a, b), args)
end

Base.literal_pow(::typeof(^), g::GroupElement, ::Val{-1}) = inv(g)

Base.:(/)(g::GEl, h::GEl) where {GEl<:GroupElement} =
    div_right!(similar(g), g, h)

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

function AbstractAlgebra.order(::Type{I}, g::GroupElement) where {I<:Integer}
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
