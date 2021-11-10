mutable struct Config
    # phenotype config
    input_nodes::Int
    output_nodes::Int
    hidden_nodes::Int
    fully_connected::Bool
    max_weight::Float64
    min_weight::Float64
    max_weight_tau::Float64
    min_weight_tau::Float64
    feedforward::Bool
    nn_activation::Symbol
    weight_stdev::Float64

    # GA config
    pop_size::Int
    max_fitness_threshold::Float64
    prob_addconn::Float64
    prob_addnode::Float64
    prob_mutatebias::Float64
    bias_mutation_power::Float64
    prob_mutate_weight::Float64 # dynamic mutation rate (future release)
    weight_mutation_power::Float64
    prob_togglelink::Float64
    elitism::Bool

    # genotype compatibility
    compatibility_threshold::Float64
    compatibility_change::Float64
    excess_coeficient::Float64
    disjoint_coeficient::Float64
    weight_coeficient::Float64

    # species
    species_size::Int
    survival_threshold::Float64 # only the best 20% for each species is allowed to mate
    old_threshold::Int
    youth_threshold::Int
    old_penalty::Float64    # always in (0,1)
    youth_boost::Float64    # always in (1,2)
    max_stagnation::Int

    function Config(params::Dict{String,String})

        new(
            # phenotype
            parse(Int,params["input_nodes"]),
            parse(Int,params["output_nodes"]),
            parse(Int,params["hidden_nodes"]),
            Bool(parse(Int,params["fully_connected"])),
            parse(Float64,params["max_weight"]),
            parse(Float64,params["min_weight"]),
            parse(Float64,params["max_weight_tau"]),
            parse(Float64,params["min_weight_tau"]),
            Bool(parse(Int,params["feedforward"])),
            Symbol(params["nn_activation"]),
            parse(Float64,params["weight_stdev"]),

            # GA
            parse(Int,params["pop_size"]),
            parse(Float64,params["max_fitness_threshold"]),
            parse(Float64,params["prob_addconn"]),
            parse(Float64,params["prob_addnode"]),
            parse(Float64,params["prob_mutatebias"]),
            parse(Float64,params["bias_mutation_power"]),
            parse(Float64,params["prob_mutate_weight"]),
            parse(Float64,params["weight_mutation_power"]),
            parse(Float64,params["prob_togglelink"]),
            Bool(parse(Int,params["elitism"])),

            # genotype compatibility
            parse(Float64,params["compatibility_threshold"]),
            parse(Float64,params["compatibility_change"]),
            parse(Float64,params["excess_coeficient"]),
            parse(Float64,params["disjoint_coeficient"]),
            parse(Float64,params["weight_coeficient"]),

            # species
            parse(Int,params["species_size"]),
            parse(Float64,params["survival_threshold"]),
            parse(Int,params["old_threshold"]),
            parse(Int,params["youth_threshold"]),
            parse(Float64,params["old_penalty"]),
            parse(Float64,params["youth_boost"]),
            parse(Int,params["max_stagnation"])
         )
    end
end

function loadConfig(file::String)
    str = open(file) do f
        read(f, String)
    end

    str = replace(str, r"\r(\n)?" => '\n')
    ls = Base.split(str, "\n")

    ls = filter(l->length(l)>0 && l[1] != '#', ls)
    lsMap = map(x->Base.split(x,'='),ls)
    params = Dict{String,String}()
    for i = 1:length(lsMap)
#         println((i,lsMap[i][1],lsMap[i][2]))
        params[rstrip(lsMap[i][1])] = lstrip(lsMap[i][2])
    end

    return params
end
