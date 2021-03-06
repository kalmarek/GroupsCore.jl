module GroupsCore

using AbstractAlgebra
const Group = AbstractAlgebra.Group
const GroupElement = AbstractAlgebra.GroupElem

# abstract type Group end
# abstract type GroupElement end

# export hasgens, hasorder, rand_pseudo,
#     direct_product, semidirect_product,
#     one!, conj, conj!, comm, comm!, div_left!, div_right!

export truly_equal, hasorder, hasgens

struct InterfaceNotSatisfied <: Exception
    family::Symbol
    method::String
end

Base.showerror(io::IO, err::InterfaceNotSatisfied) =
    print(io, "Missing method from $(err.family) interface: `$(err.method)`")

include("groups.jl")
include("group_elements.jl")

end
