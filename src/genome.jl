abstract type Node end

mutable struct NodeGene <: Node
    #= A node gene encodes the basic artificial neuron model.
    nodetype should be "INPUT", "HIDDEN", or "OUTPUT" =#
    id::Int
    ntype::Symbol
    bias::Float64
    response::Float64
    activation::Symbol
    timeConstant::Float64
    function NodeGene(id::Int, nodetype::Symbol, bias::Float64=0., response::Float64=1., # 4.924273,
                      activation::Symbol=:sigm, timeConstant::Float64=1.0)
        @assert  activation in [:none, :sigm, :tanh, :relu]
        new(id, nodetype, bias, response, activation, timeConstant)
    end
end

function Base.show(io::IO, ng::NodeGene)
    @printf(io, "Node %2d %6s, bias=%+2.10s, response=%+2.10s, %s(), time constant=%+2.5s\n",
            ng.id, ng.ntype, ng.bias, ng.response,ng.activation,ng.timeConstant)
    return
end

function get_child(ng::NodeGene, other::NodeGene)
    # Creates a new NodeGene ramdonly inheriting its attributes from parents
    @assert ng.id == other.id
    ng = NodeGene(ng.id, ng.ntype,
                    rand(Bool) ? ng.bias : other.bias,
                    rand(Bool) ? ng.response : other.response, ng.activation,
                    rand(Bool) ? ng.timeConstant : other.timeConstant)
    return ng
end

function mutate_bias!(ng::NodeGene, cf::Config)
    ng.bias += randn() * cf.bias_mutation_power
    if (ng.bias > cf.max_weight)
        ng.bias = cf.max_weight
    elseif (ng.bias < cf.min_weight)
        ng.bias = cf.min_weight
    end
end

function mutate_response!(ng::NodeGene, cf::Config)
    #  Mutates the neuron's average firing response.
    ng.response += randn() * cf.bias_mutation_power
end

function mutate_time_constant(ng::NodeGene, cf::Config)
    # Warning: pertubing the time constant (tau) may result in numerical instability
    ng.timeConstant += randn() * .001
    if ng.timeConstant > cf.max_weight
        ng.timeConstant = cf.max_weight
    elseif ng.timeConstant < cf.min_weight
        ng.timeConstant = cf.min_weight
    end
end

function mutate!(ng::NodeGene, cf::Config)
    if rand() < cf.prob_mutatebias mutate_bias!(ng, cf) end
    if rand() < cf.prob_mutatebias mutate_response!(ng, cf) end
#     if rand() < 0.1 ng.mutate_time_constant() end
end

get_new_innov_number(g::Global) =  g.innov_number += 1

mutable struct ConnectionGene
    inId::Int
    outId::Int
    weight::Float64
    enable::Bool
    key::Tuple{Int,Int}
    innovNumber::Int
    function ConnectionGene(g::Global,inId::Int, outId::Int, weight::Float64, enable::Bool=true, innov::Int=0)
        key = (inId, outId)
        if innov == 0
            if haskey(g.innovations,key)
                innovNumber = g.innovations[key]
            else
                innovNumber = get_new_innov_number(g)
                g.innovations[key] = innovNumber
            end
        else
            innovNumber = innov
        end
#         println("innovNumber = $innovNumber")
        new(inId, outId, weight, enable, key, innovNumber)
    end
end

function mutate!(cg::ConnectionGene, cf::Config)
    if rand() < cf.prob_mutate_weight
        mutate_weight!(cg, cf)
    end
    if rand() < cf.prob_togglelink
        cg.enable = true
    end
end

function mutate_weight!(cg::ConnectionGene, cf::Config)
#     cg.weight += (rand() * 2 -1) * cf.weight_mutation_power
    cg.weight += randn() * cf.weight_mutation_power
    if cg.weight > cf.max_weight
        cg.weight = cf.max_weight
    elseif cg.weight < cf.min_weight
        cg.weight = cf.min_weight
    end
end

function weight_replaced!(cg::ConnectionGene, cf::Config)
        # cg.weight = random.uniform(-Config.random_range, Config.random_range)
        cg.weight = randn() * cf.weight_stdev
end

function split(g::Global,cg::ConnectionGene, node_id::Int)
    # Splits a connection, creating two new connections and disabling this one """
    cg.enable = false
    new_conn1 = ConnectionGene(g, cg.inId, node_id, 1.0, true)
    new_conn2 = ConnectionGene(g, node_id, cg.outId, cg.weight, true)
    return new_conn1, new_conn2
end

is_same_innov(self::ConnectionGene, other::ConnectionGene) = self.innovNumber == other.innovNumber

get_child(self::ConnectionGene, other::ConnectionGene) = rand(Bool) ? self : other

function maxInnov(cgs::Dict{Tuple{Int,Int}, ConnectionGene})
    @assert length(cgs) > 0

    cgsKeys = collect(keys(cgs))
    maxCg = cgs[cgsKeys[1]]
    for key in cgsKeys
        maxCg = cgs[key].innovNumber > maxCg.innovNumber ? cgs[key] : maxCg
    end
    return maxCg
end

function Base.show(io::IO, cg::ConnectionGene)
    @printf(io, "In: %2d, Out: %2d, Weight: %+3.5f, %6s, InnovID: %d",
            cg.inId, cg.outId, cg.weight,(cg.enable ? "Enabled" : "Disabled"), cg.innovNumber)
    return
end
