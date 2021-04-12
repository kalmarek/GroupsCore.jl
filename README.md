# GroupsCore

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kalmarek.github.io/GroupsCore.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kalmarek.github.io/GroupsCore.jl/dev)
[![codecov](https://codecov.io/gh/kalmarek/GroupsCore.jl/branch/main/graph/badge.svg?token=EW7jGqK5iY)](https://codecov.io/gh/kalmarek/GroupsCore.jl)
[![Build Status](https://github.com/kalmarek/GroupsCore.jl/workflows/CI/badge.svg)](https://github.com/kalmarek/GroupsCore.jl/actions?query=workflow%3ACI)

----

An experimental group interface for the
[OSCAR](https://oscar.computeralgebra.de/) project. The aim of this package is
to standardize the common assumptions and functions on group i.e. to create
Group interface.
This should standardize the groups within and outside of the OSCAR project.

## Examples and Conformance testing

For an implemented interface please have a look at `/test` folder, where several
example implementations are tested against the conformance test suite:
  * [`CyclicGroup`](https://github.com/kalmarek/GroupsCore.jl/blob/main/test/cyclic.jl)

To test the conformance of a group implementation one can run

```julia
using GroupsCore
include(joinpath(pathof(GroupsCore), "..", "..", "test", "conformance_test.jl"))
include("my_group.jl")
let G = MyFancyGroup(15, 37, 42)
    test_Group_interface(G)
    test_GroupElement_interface(rand(G, 2)...)
    nothing
end
```
