# GroupsCore

```@meta
CurrentModule = GroupsCore
```

The aim of this package is to standardize the common assumptions and functions
on group i.e. to create Group/Monoid interface.

Due to the fact that hardly any information can be encoded in `Type`, the
interface consists of two parts:

* [`Group` or `Monoid`](@ref H1_groups) (parent object) methods,
* [`GroupElement` or `MonoidElement`](@ref H1_group_elements) methods.

We rely on parent objects that represent groups/monoids, and separate types
for elements. It is assumed that all elements of a group or monoid have
**identical** parent (i.e.  `===`) so that parent objects behave locally as
singletons.

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
    test_GroupsCore_interface(C)
    # optionally if particular two group elements are to be tested:
    # g, h = rand(C, 2)
    # test_GroupsCore_interface(g, h)
    nothing
end
```

## Users
* [PermutationGroups.jl](https://github.com/kalmarek/PermutationGroups.jl)
* [Groups.jl](https://github.com/kalmarek/Groups.jl),
* [SymbolicWedderburn.jl](https://github.com/kalmarek/SymbolicWedderburn.jl).

The [`Oscar.jl`](https://github.com/oscar-system/Oscar.jl) project no longer
supports `GroupsCore.jl` interface at version `0.5`. See
[these](https://github.com/oscar-system/Oscar.jl/pull/3070#issuecomment-1841742705)
[comments](https://github.com/oscar-system/Oscar.jl/pull/3070#issuecomment-1841865387).
