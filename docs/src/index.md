```@meta
CurrentModule = GroupsCore
```

# GroupsCore

An Experimental `Group Interface` for the `Oscar`/`AbstractAlgebra` project.

The protocol consists of two parts:
  * `Group` (parent object) methods
  * `GroupElement` methods.

Due to the fact that hardly any information can be encoded in `Type`, we rely on
`parent` objects that represent groups, as well as ordinary group elements. It
is assumed that all elements of a group have **identical** (ie. `===`) parent,
i.e. parent objects behave locally as singletons.
