# Groups

#### Iteration
 * `Base.eltype(::Type{G}) where G<:Group`: return the type of elements
 * `Base.iterate(G::Group[, state])`: iteration functionality
 * `Base.IteratorSize(::Type{MyGroup}) [= Base.SizeUnknown()]` should be
modified to return the following only if if **all instances of `MyGroup`**
   - are finite: `Base.HasLength()` / `Base.HasShape{N}()`,
   - are infinite: `Base.IsInfinite()`.

In the first case one should also define `Base.length(G::MyGroup)::Int` to be
a "best effort", cheap computation of length of the group iterator. For
practical reasons the largest group you could iterate over in your lifetime
is of order that fits into an Int (`factorial(20)` nanoseconds comes to ~77
years).


Additionally the following assumptions are placed on the iteration:
 * `first(G)` must be the identity
 * iteration over a finitely generated group should exhaust every fixed radius
ball (in word-length metric) around the identity in finite time.

#### Obligatory methods
 * `Base.one(G::Group)`: return the identity of the group
 * `GroupsCore.order(::Type{I}, G::Group) where I<:Integer`: the order of `G`
returned as an instance of `I`; only arbitrary size integers are required to
return mathematically correct answer. An infinite group must throw
`GroupsCore.InfiniteOrder` exception.
 * `GroupsCore.gens(G::Group)`: return a random-accessed collection of
generators of `G`; if a group does not come with a generating set (or it may be
prohibitively expensive to compute, or if the group is not finitely generated ), one needs to alter
`GroupsCore.hasgens(::Group) = false`.
 * `Base.rand(rng::Random.AbstractRNG, rs::Random.Sampler{GT}) where GT<:Group`:
to enable asking for random group elements treating group as a collection, i.e.
calling `rand(G, 2, 2)`.
