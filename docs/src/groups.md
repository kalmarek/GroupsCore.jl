# [Groups and Monoids](@id H1_groups)

The abstract types `Group <: Monoid` encompass all **multiplicative groups**
and **monoids**. Since these are already abstract, we skip the `Abstract` prefix.

## Assumptions

`GroupsCore` implements some methods with default values, which may not be
generally true for all groups. The intent is to limit the extent of the required
interface. **This requires special care** when implementing groups/monoids that
need to override these default methods.

The methods we currently predefine are:

* `GroupsCore.hasgens(::Monoid) = true`
  This is based on the broad assumption that reasonably generic functions
  manipulating groups/monoids can be implemented only with an access to
  a generating set.

* **For finite groups/monoids only** we define `Base.length(M) = order(Int, M)`

!!! danger
    In general `length` should be used **for iteration purposes only**.
    If you are interested in the number of distinct elements of a groups/monoids,
    use [`order(::Type{<:Integer}, ::Group)`](@ref). For more information see
    [Iteration](@ref).

## Obligatory methods

Here we list the minimal set of functions that a group object must extend to
implement the `Monoid` interface:

* `Base.one(::Monoid)` and

```@docs
order(::Type{T}, ::Monoid) where T
gens(::Monoid)
```

### Iteration

If a group/monoid is defined by generators (i.e. `hasgens(M)` returns `true`)
an important aspect of this interface is the iteration over a group.

Iteration over infinite objects seem to be useful only when the returned
elements explore the whole group or monoid. To be precise, for the example of
the free group ``F_2 = ⟨a,b⟩``, one could implement iteration by sequence

```math
a, a^2, a^3, \ldots,
```

which is arguably less useful than

```math
a, b, a^{-1}, b^{-1}, ab, \ldots.
```

Therefore we put the following assumptions on iteration.

* Iteration is mandatory only if `hasgens(M)` returns `true`.
* The first element of the iteration (e.g. given by `Base.first`) is the
  group identity.
* Iteration over an infinite group/monoid should exhaust every fixed radius
  ball around the identity (in word-length metric associated to `gens(M)`) in
  finite time.
* There is no requirement that in the iteration sequence elements are returned
  only once.

These are just the conventions, the iteration interface consists of standard
julia methods:

* [`Base.iterate`](https://docs.julialang.org/en/v1/base/collections/#Base.iterate)
* [`Base.eltype`](https://docs.julialang.org/en/v1/base/collections/#Base.eltype)

```@docs
Base.IteratorSize(::Type{<:Monoid})
```

In contrast to julia we default to `Base.SizeUnknown()` to provide a
mathematically correct fallback. If a group or monoid is finite by definition,
implementing the correct `IteratorSize` (i.e. `Base.HasLength()`, or
`Base.HasShape{N}()`) will simplify several other methods, which will be then
optimized to work only based on the type of the object. In particular when the
information is derivable from the type, there is no need to extend
[`Base.isfinite`](@ref).

!!! note
    In the case that `IteratorSize(Gr) == IsInfinite()`, one should could
    `Base.length(Gr)` to be a "best effort", length of the group/monoid iterator.
    For practical reasons the largest object you could iterate over in your
    lifetime is of order that fits well into an `Int` ($2^{63}$ nanoseconds
    comes to 290 years).

## Additional methods

```@docs
Base.isfinite(G::Group)
istrivial(G::Group)
```

## Random elements

We provide two methods for generating random elements of a group or monoid.

```@docs
GroupsCore.ProductReplacementSampler
GroupsCore.RandomWordSampler
```

By default for finite monoids `ProductReplacementSampler` is used and
`RandomWordSampler` following `Poisson(λ=8)` is employed for inifinite ones.
