# GroupsCore

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kalmar@amu.edu.pl.github.io/GroupsCore.jl/stable) -->
<!-- [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kalmar@amu.edu.pl.github.io/GroupsCore.jl/dev) -->
[![codecov](https://codecov.io/gh/kalmarek/GroupsCore.jl/branch/main/graph/badge.svg?token=EW7jGqK5iY)](https://codecov.io/gh/kalmarek/GroupsCore.jl)
[![Build Status](https://github.com/kalmarek/GroupsCore.jl/workflows/CI/badge.svg)](https://github.com/kalmarek/GroupsCore.jl/actions?query=workflow%3ACI)

An Experimental `Group Interface` for the `Oscar`/`AbstractAlgebra` project.

The protocol consists of two parts:
  * `Group` (parent object) methods
  * `GroupElement` methods.

Due to the fact that hardly any information can be encoded in `Type`, we rely on
`parent` objects that represent groups, as well as ordinary group elements. It
is assumed that all elements of a group have **identical** (ie. `===`) parent,
i.e. parent objects behave locally as singletons.

## `Group` methods

### Assumptions

`GroupsCore` implement the following methods with default values, which may not
be generally true for all groups.
The intent of those functions is to limit the extent of the required interface.
**Special care is needed** when implementing groups to override those which may
be incorrect.
 * `GroupsCore.hasgens(::Group) = true` (this is based on the assumption that
reasonably generic functions manipulating groups can be implemented only with
access to a generating set)
 * `Base.length(G) = order(Int, G)` (for finite groups only). If this value is
incorrect, one needs to redefine it e.g. setting
`Base.length(G) = convert(Int, order(G))`. See notes on `length` below.

#### Obligatory methods
 * `Base.one(G::Group)`: return the identity of the group
 * `GroupsCore.order(::Type{I}, G::Group) where I`: the order of `G`
returned as an instance of `I`; only arbitrary size integers are required to
return mathematically correct answer. An infinite group must throw
`GroupsCore.InfiniteOrder` exception.
 * `GroupsCore.gens(G::Group)`: return a random-accessed collection of
generators of `G`; if a group does not come with a generating set (or it may be
prohibitively expensive to compute, or if the group is not finitely generated,
or... when it doesn't make sense to ask for generators), one needs to redefine
`GroupsCore.hasgens(::Group)`.
 * `Base.rand(rng::Random.AbstractRNG, rs::Random.Sampler{GT}) where GT<:Group`:
to enable asking for random group elements treating group as a collection, i.e.
calling `rand(G, 2, 2)`.

#### Iteration
 * `Base.eltype(G::Group)`: return the type of elements of `G`

If `GroupsCore.hasgens(::Gr) where Gr<:Group` returns true (the default), one
needs to implement the iterator interface:

 * `Base.iterate(G::Group[, state])`: iteration functionality
 * `Base.IteratorSize(::Type{Gr}) where {Gr<:Group} [= Base.SizeUnknown()]`
 * should be modified to return the following only if **all instances of `Gr`**
   - are finite: `Base.HasLength()` / `Base.HasShape{N}()`,
   - are infinite: `Base.IsInfinite()`.
 * Note: if iterator size is `HasShape{N}()` one needs to implement `size(G::Group)` as well. For `HasLength()` we provide the default `length(G::Group) = order(Int, G).`
!!! warning
`Base.length(G::Group)::Int` should be used only for iteration purposes.
The intention is to provide a "best effort", cheap computation of length of the
group iterator. This might or might not be the correct length (as computed with
multiprecision integers).
To obtain the correct answer `GroupsCore.order(::Group)` should be used.

For practical reasons the largest group you could iterate over in your lifetime
is of order that fits into an Int (`factorial(20)` nanoseconds comes to ~77
years), therefore `typemax(Int)` is a reasonable value, even for infinite groups.


Additionally the following assumptions are placed on the iteration:
 * `first(G::Group)` must be the identity
 * iteration over a finitely generated group should exhaust every fixed radius
ball (in word-length metric) around the identity in finite time.

## `GroupElement` methods
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
 * `GroupsCore.order(g)`, `order(::Type{T}, g)` (naive implementation)
 * `Base.literal_pow(::typeof(^), g, Val{-1})` → `inv(g)`
 * `Base.:(/)(g, h)` → `g*h^-1`
 * `Base.conj(g, h)`, `Base.:(^)(g, h)` → `h^-1*g*h`
 * `Base.commutator(g, h)` → `g^-1*h^-1*g*h` and its `Vararg` (`foldl`) version.
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
 * `GroupsCore.commutator!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return
`g^-1*h^-1*g*h`, possibly modifying `out`. Aliasing of `g` or `h` with `out` is
allowed.

#### Extensions

The following functions are defined in `GroupsCore` only to be extended
externally:
```julia
function isabelian end
function issolvable end
function isnilpotent end
function isperfect end

function derivedsubgroup end
function center end
function socle end
function sylowsubgroup end

function centralizer end
function normalizer end
function stabilizer end

function index end
function left_coset_representatives end
function right_coset_representatives end
```
