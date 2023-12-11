module GroupsCore

import Random
import Markdown

abstract type Group end
abstract type GroupElement end

export Group, GroupElement
export commutator, gens, hasgens, isfiniteorder, ngens, order
export istrivial
# export one!, inv!, mul!, conj!, commutator!, div_left!, div_right!

include("exceptions.jl")
include("groups.jl")
include("group_elements.jl")

include("rand.jl")
include("extensions.jl")

end
