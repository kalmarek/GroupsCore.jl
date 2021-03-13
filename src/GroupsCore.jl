module GroupsCore

import Random
import Markdown
import AbstractAlgebra
import AbstractAlgebra: elem_type, gens, ngens, order, parent_type
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

struct InfiniteOrder{T} <: Exception
    x::T
    msg
    InfiniteOrder(g::Union{GroupElement, Group}) = new{typeof(g)}(g)
    InfiniteOrder(g::Union{GroupElement, Group}, msg) = new{typeof(g)}(g, msg)
end

function Base.showerror(io::IO, err::InfiniteOrder{T}) where T
    println(io, "Infinite order exception with ", err.x)
    if isdefined(err, :msg)
        print(io, err.msg)
    else
        print(io, "order will only return a value when it is finite. ")
        f = if T <: Group
            "isfinite(G)"
        elseif T <: GroupElement
            "isfiniteorder(g)"
        end
        print(io, "You should check with `$f` first.")
    end
end

include("groups.jl")
include("group_elements.jl")

end
