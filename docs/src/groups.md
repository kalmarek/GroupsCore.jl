# [Groups](@id H1_groups)

The abstract type `Group` encompasses all groups. Since these are already
abstract, we skip the `Abstract` prefix.

## Assumptions

`GroupsCore` implement some methods with default values, which may not be
generally true for all groups. The intent is to limit the extent of the required
interface. **This require special care** when implementing groups that need to
override these default methods.

The methods we currently predefine are:

 * `GroupsCore.hasgens(::Group) = true`
This is based on the assumption that reasonably generic functions
manipulating groups can be implemented only with access to a generating set.

 * **For finite groups only** we define `Base.length(G) = order(Int, G)`

!!! danger
    In general `length` is used **for iteration purposes only**.
    If you are interested in the number of distinct elements of a group, use
    [`order(::Type{<:Integer}, ::Group)`](@ref). For more information see
    [Iteration](@ref).

## Obligatory methods

Here we list the minimal set of functions that a group object must extend to
implement the `Group` interface.

```@docs
one(::Group)
order(::Type{<:Integer}, ::Group)
gens(::Group)
rand
```

### Iteration

If a group is defined by generators (i.e. `hasgens(G)` returns `true`) an
important aspect of this interface is the iteration over a group.

Iteration over infinite objects seem to be useful only when the returned
elements explore the whole group. To be precise, for the free group
``F_2 = ⟨a,b⟩``, one could implement iteration by sequence
```math
a, a^2, a^3, \ldots,
```
which is arguably less useful than
```math
a, b, a^{-1}, b^{-1}, ab, \ldots.
```

Therefore we put the following assumptions on iteration.
 * Iteration is mandatory only if `hasgens(G)` returns `true`.
 * The first element of the iteration (e.g. given by `Base.first`) is the
   group identity.
 * Iteration over a finitely generated group should exhaust every fixed radius
   ball around the identity (in word-length metric) in finite time.

These are just the conventions, the iteration interface consists of standard
julia methods:

 * [`Base.iterate`](https://docs.julialang.org/en/v1/base/collections/#Base.iterate)
 * [`Base.eltype`](https://docs.julialang.org/en/v1/base/collections/#Base.eltype)

```@docs
Base.IteratorSize(::Type{<:Group})
```
In contrast to julia we default to `Base.SizeUnknown()` to provide a
mathematically correct fallback. If your group is finite by definition,
implementing the correct `IteratorSize` (i.e. `Base.HasLength()`, or
`Base.HasShape{N}()`) will simplify several other methods, which will be then
optimized to work only based on the type of the group. In particular when the
information is derivable from the type, there is no need to extend

```@docs
Base.isfinite(G::Group)
```

!!! note
    In the case that `IteratorSize(Gr) == IsInfinite()`, one should define
    `Base.length(Gr)` to be a "best effort", length of the group iterator.

    For practical reasons the largest group you could iterate over in your
    lifetime is of order that fits into an `Int`. For example, $2^{63}$
    nanoseconds comes to 290 years.
