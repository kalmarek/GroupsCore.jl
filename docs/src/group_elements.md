# [Group elements](@id H1_group_elements)

`GroupsCore` defines abstract type `GroupElement`, which all implementations
of group elements should subtype.

## Obligatory methods

```@docs
parent(::GroupElement)
:(==)(::GEl, ::GEl) where {GEl <: GroupElement}
isfiniteorder(::GroupElement)
```

As well as the two arithmetic operations:

```julia
Base.inv(::GroupElement)
Base.:(*)(::GEl, ::GEl) where {GEl <: GroupElement}
```

The elements which are not of `isbitstype` should extend
```julia
Base.deepcopy_internal(g::GroupElement, ::IdDict)
```
according to
[`Base.deepcopy`](https://docs.julialang.org/en/v1/base/base/#Base.deepcopy)
docstring. Due to our assumption on parents of group elements (acting as local
singleton objects), a group element and its `deepcopy` should have identical
(i.e. `===`) parents.

!!! note
    If finiteness of a group can be decided based on its type there is no need
    to extend `isfiniteorder`.

## Implemented methods

Using the obligatory methods we implement the rest of the functions in
`GroupsCore`. For starters, the first of these are:

```julia
Base.:(^)(::GroupElement, ::Integer)
Base.:(/)(::GEl, ::GEl) where {GEl <: GroupElement}
Base.one(::GroupElement)
```

and

```@docs
order(::Type{T}, ::GroupElement) where T
conj
:(^)(::GEl, ::GEl) where {GEl <: GroupElement}
commutator
```

### Performance modifications

Some of the mentioned implemented methods may be altered for performance
reasons:
```julia
Base.:(^)(g::GroupElement, n::Integer)
Groups.Core.order([::Type{T}], g::GroupElement) where T
Base.hash(::GroupElement, ::UInt)
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
