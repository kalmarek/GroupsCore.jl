import Random

function Random.Sampler(
    RNG::Type{<:Random.AbstractRNG},
    M::Monoid,
    repetition::Random.Repetition = Val(Inf),
)
    if isfinite(M)
        return PRASampler(RNG(), M)
    else
        # for infinite groups/monoids PRA will either return
        # ridiculously long words or just run out of memory
        S = gens(M)
        if M isa Group
            S = [S; inv.(S)]
        end
        return RandomWordSampler(S, Poisson(; λ = 8))
    end
end

"""
    PRASampler
Implements Product Replacement Algorithm for a group or monoid generated by
an explicit finite set of generators.

Product Replacement Algorithm performs a random walk on the graph of
`n`-generating tuples of a group (or monoid) with __two accumulators__.
Each step consists of
 1. multiplying the right accumulator by a random generator,
 2. replacing one of the generators with the product with the right accumulator,
 3. multiplying the left accumulator (on the left) by a random generator.

The left accumulator is returned as a random element.

By default for a group with `k` generators we set `n = 2k + 10` and perform
`10*n` scrambling steps before returning a random element.

`PRASampler` provides provably uniformly distributed random elements for
finite groups. For infinite groups [`RandomWordSampler`](@ref) is used.

!!! warning
    Using `PRASampler` for an infinite group is ill-advised as the exponential
    growth of words during scrambling will result in excessive memory use and
    out-of-memory situation.
"""
mutable struct PRASampler{T} <: Random.Sampler{T}
    gentuple::Vector{T}
    right::T
    left::T
end

# constants taken from GAP
function PRASampler(
    rng::Random.AbstractRNG,
    M::Monoid,
    n::Integer = 2ngens(M) + 10,
    scramble_time::Integer = 10max(n, 10),
)
    @assert hasgens(M)
    if istrivial(M)
        return PRASampler(fill(one(M), n), one(M), one(M))
    end
    @assert hasgens(M)
    l = max(n, 2ngens(M), 2)
    sampler = let S = collect(gens(M))
        if M isa Group
            S = union!(S, inv.(S))
        end
        append!(S, rand(rng, S, l - length(S)))
        PRASampler(S, one(M), one(M))
    end
    for _ in 1:scramble_time
        _ = rand(rng, sampler)
    end
    return sampler
end

function Random.rand(rng::Random.AbstractRNG, pra::PRASampler)
    i = rand(rng, 1:length(pra.gentuple))

    pra.right = pra.right * rand(rng, pra.gentuple)
    @inbounds pra.gentuple[i] = pra.gentuple[i] * pra.right
    pra.left = rand(rng, pra.gentuple) * pra.left

    return pra.left
end

struct Poisson
    λ::Int
    cdf::Vector{Float64}

    function Poisson(; λ::Integer)
        cdf = cumsum([λ^k * exp(-λ) / factorial(k) for k in 0:20])
        return new(λ, cdf)
    end
end

cdf(d::Poisson, x) = something(findfirst(≥(x), d.cdf), length(d.cdf) + 1)

"""
    RandomWordSampler(S, distribution)
Return elements from a monoid represented by words of length in `S`, obeying `distribution`.

Usually for a monoid (group) `S` is a (symmetric) generating set.

`distribution` object must implement `cdf(distribution, x::Float64)::Integer`.

For finite monoids or groups when uniformity of results is needed
[`ProductReplacementSampler`](@ref) should be used.
"""
struct RandomWordSampler{V,D}
    gens::V
    distribution::D
end

Base.eltype(::Type{<:RandomWordSampler{V}}) where {V} = eltype(V)

function Base.rand(
    rng::Random.AbstractRNG,
    rs::Random.SamplerTrivial{<:RandomWordSampler{I}},
) where {I}
    rw_sampler = rs[]
    k = cdf(rw_sampler.distribution, rand(rng))
    return prod(rand(rng, rw_sampler.gens, k))
end
