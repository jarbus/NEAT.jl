module NEAT

include("config.jl")

# track count of various global variables & holds refernce to the config
struct Global
    speciesCnt::Int
    chromosomeCnt::Int
    nodeCnt::Int
    innov_number::Int
    innovations::Dict{Tuple{Int,Int},Int}
    cf::Config
    function Global(cf::Config)
        new(0,0,0,0,Dict{(Int,Int),Int},cf) # global dictionary
    end
end

include("genome.jl")
# include("chromosome.jl")
# include("species.jl")
# include("population.jl")
# include("../networks/nn.jl")

# export Input, Output, Hidden

end # module
