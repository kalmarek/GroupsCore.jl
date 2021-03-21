# Group elements

#### Obligatory methods
 * `Base.parent(g::GroupElement)`: return the parent object of a given group
element. Parent objects of the elements of the same group must be **identical**
(i.e. `===`).
 * `GroupsCore.parent_type(::Type{<:GroupElement})`: given the type of an
element return the type of its parent.
 * `GroupsCore.:(==)(g::GEl, h::GEl) where GEl<:GroupElement`: return the
mathematical equality of group elements;
 * `GroupsCore.isfiniteorder(g::GroupElement)`: return `true` if `g` has finite
order (possibly without computing it). If `isfiniteorder(g)` returns `false`,
`order(g)` is required to throw `GroupsCore.InfiniteOrder` exception.
 * `Base.deepcopy_internal(g::GroupElement, ::IdDict)`: return a completely
intependent copy of group element `g` **without copying its parent**; `isbits`
subtypes of `GroupElement` need not to implement this method.
 * `Base.inv(g::GroupElement)`: return the group inverse of `g`.
 * `Base.:(*)(g::GEl, h::GEl) where GEl<:GroupElement`: the group binary
operation on `g` and `h`.

No further methods are strictly necessary.

### Implemented methods
Based on these methods only, the following functions in `GroupsCore` are
implemented:
 * `Base.one(g::GroupElement)` → `one(parent(g))`
 * `GroupsCore.order(g)`, `order(I::Type{<:Integer}, g)` (naive implementation)
 * `Base.literal_pow(::typeof(^), g, Val{-1})` → `inv(g)`
 * `Base.:(/)(g, h)` → `g*h^-1`
 * `Base.conj(g, h)`, `Base.:(^)(g, h)` → `h^-1*g*h`
 * `Base.comm(g, h)` → `g^-1*h^-1*g*h` and its `Vararg` (`foldl`) version.
 * `Base.isequal(g,h)` → `g == h` (a weaker/cheaper equality)
 * `Base.:(^)(g, n::Integer)` → powering by squaring.

#### Performance modifications
For performance reasons one may alter any of the following methods.

 * `Base.similar(g::GroupElement)[ = one(g)]`: return an arbitrary (and possibly
uninitialized) group element sharing the parent with `g`.
 * `Base.isone(g::GroupElement)[ = g == one(g)]`: to avoid the unnecessary
construction of `one(g)`.
 * `Base.isequal(g::GEl, h::GEl) where GEl<:GroupElement[ = g == h]`: to provide
cheaper "best effort" equality for group elements.
 * `Base.:^(g::GroupElement, n::Integer) = Base.power_by_squaring(g, n)`
 * `GroupsCore.order(::Type{I}, g::GroupElement)`: to replace the naive
implementation.
 * `Base.hash(g::GroupElement, h::UInt)[ = hash(typeof(g), h)]`: a more specific
hash function will lead to smaller numer of conflicts.

#### Mutable API

**Work in progress**

Additionally, for the purpose of mutable arithmetic the following methods may be
overloaded to provide more tailored versions for a given type and reduce the
allocations. These functions should be used when writing libraries, in
performance critical sections. However one should only **use the returned value**
and there are no guarantees on in-place modifications actually happening.

All of these functions (possibly) alter only the first argument, and must unalias
their arguments when necessary.

 * `GroupsCore.one!(g::GroupElement)`: return `one(g)`, possibly modifying `g`.
 * `GroupsCore.inv!(out::GEl, g::GEl) where GEl<:GroupElement`: return `g^-1`,
possibly modifying `out`. Aliasing of `g` with `out` is allowed.
 * `GroupsCore.mul!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return
`g*h`, possibly modifying `out`. Aliasing of `g` or `h` with `out` is allowed.
 * `GroupsCore.div_left!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`:
return `h^-1*g`, possibly modifying `out`. Aliasing of `g` or `h` with `out` is
allowed.
 * `GroupsCore.div_right!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`:
return `g*h^-1`, possibly modifying `out`. Aliasing of `g` or `h` with `out` is
allowed.
 * `GroupsCore.conj!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return
`h^-1*g*h, `possibly modifying `out`. Aliasing of `g` or `h` with `out` is
allowed.
 * `GroupsCore.comm!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return
`g^-1*h^-1*g*h`, possibly modifying `out`. Aliasing of `g` or `h` with `out` is
allowed.
