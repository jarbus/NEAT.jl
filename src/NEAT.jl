module NEAT
using Printf

include("config.jl")

# track count of various global variables & holds refernce to the config
mutable struct Global
    speciesCnt::Int
    chromosomeCnt::Int
    nodeCnt::Int
    innov_number::Int
    innovations::Dict{Tuple{Int,Int},Int}
    cf::Config
end

function Global(cf::Config)
    Global(0,0,0,0,Dict{Tuple{Int,Int},Int}(),cf) # global dictionary
end

include("genome.jl")
include("chromosome.jl")
include("species.jl")
include("population.jl")
# include("../networks/nn.jl")

# export Input, Output, Hidden

end # module
