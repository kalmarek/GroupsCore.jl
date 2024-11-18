struct InterfaceNotImplemented <: Exception
    family::Symbol
    method::String
end

function Base.showerror(io::IO, err::InterfaceNotImplemented)
    return print(
        io,
        "Missing method from $(err.family) interface: `$(err.method)`",
    )
end

struct InfiniteOrder{T} <: Exception
    x::T
    msg::Any
    InfiniteOrder(g::Union{<:MonoidElement,<:Monoid}) = new{typeof(g)}(g)
    function InfiniteOrder(g::Union{<:MonoidElement,<:Monoid}, msg)
        return new{typeof(g)}(g, msg)
    end
end

function Base.showerror(io::IO, err::InfiniteOrder{T}) where {T}
    println(io, "Infinite order exception with ", err.x)
    if isdefined(err, :msg)
        print(io, err.msg)
    else
        print(io, "order will only return a value when it is finite. ")
        f = if T <: Monoid
            "isfinite(…)"
        elseif T <: MonoidElement
            "isfiniteorder(…)"
        end
        print(io, "You should check with `$f` first.")
    end
end
