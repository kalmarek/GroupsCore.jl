# GroupsCore

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kalmar@amu.edu.pl.github.io/GroupsCore.jl/stable) -->
<!-- [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kalmar@amu.edu.pl.github.io/GroupsCore.jl/dev) -->
[![codecov](https://codecov.io/gh/kalmarek/GroupsCore.jl/branch/main/graph/badge.svg?token=EW7jGqK5iY)](https://codecov.io/gh/kalmarek/GroupsCore.jl)
[![Build Status](https://github.com/kalmarek/GroupsCore.jl/workflows/CI/badge.svg)](https://github.com/kalmarek/GroupsCore.jl/actions?query=workflow%3ACI)

An Experimental `Group Interface` for the `Oscar`/`AbstractAlgebra` project.

The protocol consists of two parts:
  * `Group` (parent object) methods
  * `GroupElement` methods.

Due to the fact that hardly any information can be encoded in `Type`, we rely on `parent` objects that represent groups, as well as ordinary group elements. It is assumed that all elements of a group have **identical** (ie. `===`) parent, i.e. parent objects behave locally as singletons.

## `Group` methods

##### Iteration
 * `Base.eltype(::Type{G}) where G<:Group`: return the type of elements
 * `Base.iterate(G::Group[, state])`: iteration functionality
 * `first(G)` must be the identity
 * If finiteness can not be easily established one needs to override the default
   > `Base.IteratorSize(::Type{Group}) = Base.HasLength()`

   by
   > `Base.IteratorSize(::Type{Group}) = Base.IsInfinite()`

   if instances of the type are always infinite, or by
   > `Base.IteratorSize(::Type{Group}) = Base.SizeUnknown()`

   otherwise.
 * If groups of a given type are known to be finite, one needs to define
   > `Base.length(G::Group) = order(Int, G)`

   which is a "best effort", cheap computation of length of the group iterator. For practical reasons the largest group you could possibly iterate over is of order ~`factorial(19)` (which still fits into `Int`).

##### Obligatory methods
 * `Base.one(G::Group)`: return the identity of the group
 * `GroupsCore.order(::Type{I}, G::Group) where I<:Integer`: the order of `G` returned as an instance of `I`; only arbitrary size integers are required to return mathematically correct answer.
 * `GroupsCore.gens(G::Group)`: return a random-accessed collection of generators of `G`; if a group does not come with a generating set (or it may be prohibitively expensive to compute), one needs to alter `GroupsCore.hasgens(::Group) = false`.
 * `Base.rand(rng::Random.AbstractRNG, rs::Random.Sampler{GT}) where GT<:Group`: to enable asking for random group elements treating group as a collection, i.e. calling `rand(G, 2, 2)`.

## `GroupElement` methods
##### Obligatory methods
 * `Base.parent(g::GroupElement)`: return the parent object of a given group element. Parent objects of the elements of the same group must be **identical** (i.e. ===).
 * `GroupsCore.parent_type(::Type{<:GroupElement})`: given the type of an element return the type of its parent.
 * `GroupsCore.istrulyequal(g::GEl, h::GEl) where GEl<:GroupElement`: return the mathematical equality of group elements; by default the standard equality `==` calls this function.
 * `GroupsCore.hasorder(g::GroupElement)`: return `true` if `g` has finite order (without computing it)`.
 * `Base.deepcopy_internal(g::GroupElement, ::IdDict)`: return a completely intependent copy of group element `g` **without copying its parent**; `isbits` subtypes of `GroupElement` need not to implement this method.
 * `Base.inv(g::GroupElement)`: return the group inverse of `g`.
 * `Base.:(*)(g::GEl, h::GEl) where GEl<:GroupElement`: the group binary operation on `g` and `h`.

No further methods are strictly necessary.

## Implemented methods
Based on these methods only, the following functions in `GroupsCore` are implemented:
 * `Base.one(::GroupElement)`
 * `GroupsCore.order(g)`, `order(I::Type{<:Integer}, g)`
 * `Base.literal_pow(::typeof(^), g, Val{-1})` → `inv(g)`
 * `Base.:(/)(g, h)` → `g*inv(h)`
 * `Base.conj(g, h)`, `Base.:(^)(g, h)` → `inv(h)*g*h`
 * `Base.comm(g, h)` → `inv(h)*inv(g)*h*g` and its `Vararg` (`foldl`) version.
 * `Base.:(==)(g,h)` → `GroupsCore.istrulyequal(g, h)`
 * `Base.:(^)(g, n::Integer)` → powering by squaring.

##### Performance modifications
For performance reasons one may alter any of the following methods.

 * `Base.similar(g::GroupElement)[ = one(g)]`: return an arbitrary (and possibly uninitialized) group element sharing the parent with `g`.
 * `Base.isone(g::GroupElement)[ = g == one(g)]`: to avoid the unnecessary construction of `one(g)`.
 * `Base.:(==)(g::GEl, h::GEl) where GEl<:GroupElement[ = istrulyequal(g, h)]`: to provide cheaper "best effort" equality for group elements.
 * `Base.:^(g::GroupElement, n::Integer) = Base.power_by_squaring(g, n)`
 * `GroupsCore.order(::Type{I}, g::GroupElement)`: to replace the naive implementation.
 * `Base.hash(g::GroupElement, h::UInt)[ = hash(typeof(g), h)]`: a more specific hash function will lead to smaller numer of conflicts.

##### Mutable API (??)
Additionally, for the purpose of mutable arithmetic the following methods may be overloaded to provide more tailored versions for a given type and reduce the allocations. These functions should be used when writing libraries, in performance critical sections. However one should only **use the returned value** and there are no guarantees on in-place modifications actually happening.

All of these functions (possibly) alter only the first argument, and must unalias their arguments when necessary.

 * `GroupsCore.one!(g::GroupElement)`: return `one(g)`, possibly modifying `g`.
 * `GroupsCore.inv!(out::GEl, g::GEl) where GEl<:GroupElement`: return `inv(g)`, possibly modifying `out`.
 * `GroupsCore.mul!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return `g*h`, possibly modifying `out`.
 * `GroupsCore.div_left!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return `inv(h)*g`, possibly modifying `out`.
 * `GroupsCore.div_right!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return `g*inv(h)`, possibly modifying `out`.
 * `GroupsCore.conj!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return `inv(h)*g*h, `possibly modifying `out`.
 * `GroupsCore.comm!(out::GEl, g::GEl, h::GEl) where GEl<:GroupElement`: return `inv(g)*inv(h)*g*h`, possibly modifying `out`.
