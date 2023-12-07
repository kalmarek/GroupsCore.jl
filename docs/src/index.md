# GroupsCore

```@meta
CurrentModule = GroupsCore
```

The aim of this package is to standardize the common assumptions and functions
on group i.e. to create Group interface.

The protocol consists of two parts:

* [`Group`](@ref H1_groups) (parent object) methods,
* [`GroupElement`](@ref H1_group_elements) methods.

This is due to the fact that hardly any information can be encoded in `Type`, we
rely on parent objects that represent groups, as well as ordinary group
elements. It is assumed that all elements of a group have **identical** parent
(i.e.  `===`) so that parent objects behave locally as singletons. More on this
can be read under
[AbstractAlgebra.jl](https://nemocas.github.io/AbstractAlgebra.jl/latest/types/).

## Examples and Conformance testing

For an implemented interface please have a look at `/test` folder, where several
example implementations are tested against the conformance test suite:

* [`CyclicGroup`](https://github.com/kalmarek/GroupsCore.jl/blob/main/test/cyclic.jl)

To test the conformance of e.g. `CyclicGroup` defined above one can run

```@repl
using GroupsCore
include(joinpath(pathof(GroupsCore), "..", "..", "test", "conformance_test.jl"))
include(joinpath(pathof(GroupsCore), "..", "..", "test", "cyclic.jl"))
let C = CyclicGroup(15)
    test_Group_interface(C)
    test_GroupElement_interface(rand(C, 2)...)
    nothing
end
```

## Users
* [PermutationGroups.jl](https://github.com/kalmarek/PermutationGroups.jl)
* [Groups.jl](https://github.com/kalmarek/Groups.jl),
* [SymbolicWedderburn.jl](https://github.com/kalmarek/SymbolicWedderburn.jl),
* [Oscar](https://github.com/oscar-system/Oscar.jl) project.
