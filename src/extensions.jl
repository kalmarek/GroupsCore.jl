function isabelian end
function issolvable end
function isnilpotent end
function isperfect end

function derivedsubgroup end
function center end
function socle end
function sylowsubgroup end

function centralizer end
function normalizer end
function stabilizer end

@doc Markdown.doc"""
    index(subgroup::G, group::G) where {G <: Group}

Return the index of the subgroup compared to the group. If subgroup is not
contained in group, an error is thrown.
"""
function index end

@doc Markdown.doc"""
    left_coset_representatives(subgroup::G, group::G) where {G <: Group}

Return representatives of the left coset. If subgroup is not contained in
group, an error is thrown.
"""
function left_coset_representatives end
function right_coset_representatives end
