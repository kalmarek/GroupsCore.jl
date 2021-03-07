module GroupsCore

import Random
import AbstractAlgebra
import AbstractAlgebra: elem_type, gens, ngens, order, parent, parent_type
import AbstractAlgebra: inv!, mul!
const Group = AbstractAlgebra.Group
const GroupElement = AbstractAlgebra.GroupElem

# abstract type Group end
# abstract type GroupElement end

export Group, GroupElement
export comm, istrulyequal, gens, hasorder, hasgens, ngens, order
# export one!, inv!, mul!, conj!, comm!, div_left!, div_right!

struct InterfaceNotImplemented <: Exception
    family::Symbol
    method::String
end

Base.showerror(io::IO, err::InterfaceNotImplemented) =
    print(io, "Missing method from $(err.family) interface: `$(err.method)`")

include("groups.jl")
include("group_elements.jl")

end
