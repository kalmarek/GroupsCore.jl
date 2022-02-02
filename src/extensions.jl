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
    index(H::Gr, G::Gr) where {Gr <: Group}

Return the index $|G : H|$, where $H \subseteq G$. If $H$ is not contained
in $G$, an error is thrown.
"""
function index end

@doc Markdown.doc"""
    left_coset_representatives(H::Gr, G::Gr) where {Gr <: Group}

Return representatives of the left cosets $h G$ where $h$ are elements of $H$.
If $H$ is not contained in $G$, an error is thrown.
"""
function left_coset_representatives end
function right_coset_representatives end
