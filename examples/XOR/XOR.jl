using NEAT
using Printf

paramsDict = loadConfig(joinpath(dirname(@__FILE__),"XOR_config.txt"))
config = Config(paramsDict)
g = Global(config)

# set node gene type

# XOR-2
INPUTS = [0 0; 0 1; 1 0; 1 1]
OUTPUTS = [0, 1, 1, 0]

function eval_fitness(population)
    for chromo in population
        net = createPhenotype(chromo)
        error = 0.0
        for i = 1:size(INPUTS,1)
#             flush!(net) # not strictly necessary in feedforward nets
            output = activate(net.nntype, net, [INPUTS[i,1],INPUTS[i,2]])
            error += (output[1] - OUTPUTS[i])^2
        end
        chromo.fitness = max(0, 1-sqrt(error/length(OUTPUTS)))
    end
end

println("Beginning XOR test...")
g.cf.nn_activation = :sigm
p = Population(g)
p.evaluate = eval_fitness
epoch(g, p, 300, false)

winner = p.best_fitness[end]
println("Number of evaluations: $(p.generation)   winner.id=$(winner.id)")

# Let's check if it's really solved the problem
println("Best network output:")
correct = falses(length(OUTPUTS))
brain = createPhenotype(winner)
println("example\t\tcorrect\t\tpredicted")
for i = 1:size(INPUTS,1)
    output = activate(brain.nntype, brain, [INPUTS[i,1],INPUTS[i,2]])
    @printf("%5d\t\t%1.5f \t%1.5f\n", i ,OUTPUTS[i], round(output[1];digits=0))
    if OUTPUTS[i] == round(output[1];digits=2) correct[i] = true end
end

# # Visualize the winner network (requires PyDot)
# #visualize.draw_net(winner) # best chromosome

# # Plots the evolution of the best/average fitness (requires Biggles)
# #visualize.plot_stats(pop.stats)
# # Visualizes speciation
# #visualize.plot_species(pop.species_log)

# # saves the winner
# #file = open('winner_chromosome', 'w')
# #pickle.dump(winner, file)
# #file.close()
