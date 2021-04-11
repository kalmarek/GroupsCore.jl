```@meta
CurrentModule = GroupsCore
```

# GroupsCore

An experimental group interface for the
[OSCAR](https://oscar.computeralgebra.de/) project. The aim of this project is
to standardize the design of such an interface in order for such packages to be
able to work together more easily.

The protocol consists of two parts:
  * `Group` (parent object) methods,
  * `GroupElement` methods.

This is due to the fact that hardly any information can be encoded in `Type`, we
rely on parent objects that represent groups, as well as ordinary group
elements. It is assumed that all elements of a group have **identical** parent
(i.e.  `===`) so that parent objects behave locally as singletons. More on this
can be read under
[AbstractAlgebra.jl](https://nemocas.github.io/AbstractAlgebra.jl/latest/types/).
