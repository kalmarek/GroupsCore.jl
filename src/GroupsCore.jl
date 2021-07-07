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
export commutator, gens, hasgens, isfiniteorder, ngens, order
export istrivial
# export one!, inv!, mul!, conj!, commutator!, div_left!, div_right!

include("exceptions.jl")
include("groups.jl")
include("group_elements.jl")

include("extensions.jl")

include("constructions/constructions.jl")
using .Constructions

end
