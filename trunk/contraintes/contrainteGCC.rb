require 'tools/flow.rb'
require 'contraintes/contrainte.rb'

# TODO : everything :p
# TODO : domain changes, backtrack

# The Global Cardinality Constraint
# Given a set of variables and values.
# Each value, has to appear at least min times, and at most max times
class ContrainteGCC < Contrainte

  attr_reader :vars
  
  def initialize(vars, mins, maxs)
    @tab = vars
    @graph = Flow_graph.new
    source = @graph.add_node "Source"
    sink = @graph.add_node "Sink"
    sink.add_arc(source, 0, 1.0/0)

    @var_nodes = {}
    vals = []
    vars.each do |var|
      @var_nodes[var] = @graph.add_node var
      @var_nodes[var].add_arc sink
      vals |= var.domain.to_a
    end

    
    @val_nodes ={}
    vals.each_with_index do |val, i|
      @val_nodes[val] = @graph.add_node val
      source.add_arc(@val_nodes[val], mins[i], maxs[i])
      vars.each {|var| @val_nodes[val].add_arc @var_nodes[var] if var.domain.include? val}
    end
  end #initialize

  def statisfied?
    return @graph.is_feasible?
  end

  def update(deleted, added, var, compteur, pile)
  end

          

  def apply(compteur, pile)
    @graph.maximise_flow
    puts @graph.to_s
    puts @graph.tarjan
    return @graph.is_feasible?
  end

end # classe ContrainteGCC
