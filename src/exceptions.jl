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
