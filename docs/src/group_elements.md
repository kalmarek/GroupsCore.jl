# [Group elements](@id H1_group_elements)

`GroupsCore` defines abstract types `GroupElement <: MonoidElement`, which all implementations of group/monoid elements should subtype.

## Obligatory methods

```@docs
parent(::Monoid)
:(==)(::El, ::El) where {El <: MonoidElement}
isfiniteorder(::MonoidElement)
```

As well as the two arithmetic operations:

```julia
Base.:(*)(::El, ::El) where {El <: MonoidElement}
Base.inv(::GroupElement)
```

### A note on `deepcopy`

The elements which are not of `isbitstype` should extend

```julia
Base.deepcopy_internal(g::MonoidElement, ::IdDict)
```

according to
[`Base.deepcopy`](https://docs.julialang.org/en/v1/base/base/#Base.deepcopy)
docstring. Due to our assumption on parents of group/monoid elements
(acting as local singleton objects), a monoid element and its `deepcopy` should
have identical (i.e. `===`) parents.

## Implemented methods

Using the obligatory methods we implement the rest of the functions in
`GroupsCore`. For starters, the first of these are:

```julia
Base.one(::MonoidElement)
Base.:(/)(::El, ::El) where {El <: GroupElement}
```

and

```@docs
order(::Type{T}, ::MonoidElement) where T
conj
:(^)(::GEl, ::GEl) where {GEl <: GroupElement}
commutator
```

Moreover we provide basic implementation which could be altered for performance
reasons:
```julia
Base.:(^)(g::MonoidElement, n::Integer)
Groups.Core.order([::Type{T}], g::MonoidElement) where T
Base.hash(::MonoidElement, ::UInt)
```

### Mutable API

!!! warning
    Work-in-progress.
    Mutable API is considered private and hence may change between versions
    without warning.

For the purpose of mutable arithmetic the following methods may be overloaded
to provide more tailored versions for a given type and reduce the allocations.
These functions should be used when writing libraries, in performance critical
sections. However one should only **use the returned value** and there are no
guarantees on in-place modifications actually happening.

All of these functions (possibly) alter only the first argument, and must
unalias their arguments when necessary.

```@docs
GroupsCore.one!
GroupsCore.inv!
GroupsCore.mul!
GroupsCore.div_left!
GroupsCore.div_right!
GroupsCore.conj!
GroupsCore.commutator!
```
