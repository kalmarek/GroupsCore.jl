```@meta
CurrentModule = GroupsCore
```

# GroupsCore

An experimental group interface for the
[OSCAR](https://oscar.computeralgebra.de/) project. The aim of this package is
to standardize the common assumptions and functions on group i.e. to create
Group interface.
This should standardize the groups within and outside of the OSCAR project.

The protocol consists of two parts:
  * [`Group`](@ref H1_groups) (parent object) methods,
  * [`GroupElement`](@ref H1_group_elements) methods.

This is due to the fact that hardly any information can be encoded in `Type`, we
rely on parent objects that represent groups, as well as ordinary group
elements. It is assumed that all elements of a group have **identical** parent
(i.e.  `===`) so that parent objects behave locally as singletons. More on this
can be read under
[AbstractAlgebra.jl](https://nemocas.github.io/AbstractAlgebra.jl/latest/types/).
