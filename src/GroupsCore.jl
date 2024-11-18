module GroupsCore

import Random

abstract type Monoid end
abstract type MonoidElement end
abstract type Group <: Monoid end
abstract type GroupElement <: MonoidElement end

export Monoid, MonoidElement, Group, GroupElement
export commutator, gens, hasgens, isfiniteorder, ngens, order
export istrivial
# export one!, inv!, mul!, conj!, commutator!, div_left!, div_right!

include("exceptions.jl")
include("groups.jl")
include("group_elements.jl")

include("rand.jl")
include("extensions.jl")

end
