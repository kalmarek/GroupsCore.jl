# Groups

The abstract type `Group` is defined via
```julia
const Group = AbstractAlgebra.Group
```

Be aware that more methods exists than what is listed here. For the natural
extensions, please see
[AbstractAlgebra](https://nemocas.github.io/AbstractAlgebra.jl/latest/extending_abstractalgebra/).

## Assumptions

GroupsCore implement some methods with default values, which may not be
generally true for all groups. The intent is to limit the extent of the required
interface. **This require special care** when implementing groups that need to
override these default methods.

The methods we currently predefine are:

 * `GroupsCore.hasgens(::Group) = true`

    This is based on the assumption that reasonably generic functions
    manipulating groups can be implemented only with access to a generating set.

 * `Base.length(G) = order(Int, G)` **for finite groups only**

    If this value is incorrect, one needs to redefine it. For example, one can
    redefine it to `Base.length(G) = convert(Int, order(G))` (see `length` below).

## Obligatory methods

This is the complete list of the obligatory methods:

```@docs
one(::Group)
order(::Type{<:Integer}, ::Group)
gens(::Group)
rand
```

## Implemented methods

```@docs
elem_type
```

## Iteration

An important aspect of this interface is to be able to iterate over the group.

In order to be able to iterate, it is mandatory that
 * the first element in the iterations given by `Base.first` must be the
   identity,
 * iteration over a finitely generated group should exhaust every fixed radius
   ball (in word-length metric) around the identity in a finite amount of time,
 * `Base.eltype(G::Group)` returns the element type of $G$.

The iterator method that should be extended is
```julia
Base.iterate(G::Group[, state])
```
with the optional `state`-parameter. The iterator size is then given by:

```@docs
Base.IteratorSize
```

!!! note
    In the case that `IteratorSize(Gr) == IsInfinite()`, one should define
    `Base.length(Gr)` to be a "best effort", cheap
    computation of length of the group iterator.

For practical reasons the largest group you could iterate over in your lifetime
is of order that fits into an `Int`. For example, $2^{63}$ nanoseconds comes to
290 years.
