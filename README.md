# GroupsCore

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kalmarek.github.io/GroupsCore.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kalmarek.github.io/GroupsCore.jl/dev)
[![codecov](https://codecov.io/gh/kalmarek/GroupsCore.jl/branch/main/graph/badge.svg?token=EW7jGqK5iY)](https://codecov.io/gh/kalmarek/GroupsCore.jl)
[![Build Status](https://github.com/kalmarek/GroupsCore.jl/workflows/CI/badge.svg)](https://github.com/kalmarek/GroupsCore.jl/actions?query=workflow%3ACI)

----

The aim of this package is to standardize common assumptions on and functions
for groups and monoids, i.e. to create Group/Monoid interface. Packages using it include:
* [PermutationGroups.jl](https://github.com/kalmarek/PermutationGroups.jl)
* [Groups.jl](https://github.com/kalmarek/Groups.jl),
* [SymbolicWedderburn.jl](https://github.com/kalmarek/SymbolicWedderburn.jl),

The [`Oscar.jl`](https://github.com/oscar-system/Oscar.jl) project no longer
supports `GroupsCore.jl` interface at version `0.5`.

## Examples and Conformance testing

For an implemented interface please have a look at `/test` folder, where several
example implementations are tested against the conformance test suite:
  * [`CyclicGroup`](https://github.com/kalmarek/GroupsCore.jl/blob/main/test/cyclic.jl)
  * [`InfCyclicGroup`](https://github.com/kalmarek/GroupsCore.jl/blob/main/test/infinite_cyclic.jl)

To test the conformance of a group implementation one can run

```julia
using GroupsCore
include(joinpath(pathof(GroupsCore), "..", "..", "test", "conformance_test.jl"))
include("my_fancy_group.jl") # the implementation of MyFancyGroup
let G = MyFancyGroup(...)
    test_GroupsCore_interface(G)
    # optionally if particular two group elements are to be tested:
    # g,h = rand(G, 2)
    # test_GroupsCore_interface(g, h)
    nothing
end
```
