# [Group elements](@id H1_group_elements)

The abstract type `GroupElement` is defined via
```julia
const GroupElement = AbstractAlgebra.GroupElem
```

Be aware that more methods exists than what is listed here. For the natural
extensions, please see
[AbstractAlgebra](https://nemocas.github.io/AbstractAlgebra.jl/latest/extending_abstractalgebra/).

## Obligatory methods

The first essential methods one should extend are
```julia
Base.deepcopy_internal(g::GroupElement, ::IdDict)
AbstractAlgebra.parent_type(::Type{<:GroupElement})
```

The rest of the obligatory methods are:

```@docs
parent(::GroupElement)
:(==)(::GEl, ::GEl) where {GEl <: GroupElement}
isfiniteorder(::GroupElement)
inv(::GroupElement)
:(*)(::GEl, ::GEl) where {GEl <: GroupElement}
```

## Implemented methods

From on the obligatory methods we implement the rest of the functions in
GroupsCore. For starters, the first of these are:
```julia
:(^)(::GroupElement, ::Integer)
:(/)(::GEl, ::GEl) where {GEl <: GroupElement}
```
and
```@docs
one(::GroupElement)
isequal(::GEl, ::GEl) where {GEl <: GroupElement}
order(::Type{<:Integer}, ::GroupElement)
conj
:(^)(::GEl, ::GEl) where {GEl <: GroupElement}
commutator
```

### Performance modifications

Some of the mentioned implemented methods may be altered for performance
reasons:
```julia
isequal(g::GEl, h::GEl) where {GEl <: GroupElement}
:(^)(g::GroupElement, n::Integer)
order(::Type{I}, g::GroupElement)
```

Further methods are also implemented. However, for performance reasons one may
alter any of the following methods:

```julia
hash(::GroupElement, ::UInt)
```

```@docs
similar(::GroupElement)
isone(::GroupElement)
```

### Mutable API

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
