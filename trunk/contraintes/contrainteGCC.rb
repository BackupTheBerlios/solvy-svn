require 'tools/flow.rb'
require 'contraintes/contrainte.rb'

# TODO : filtering (method apply)
# TODO : domain changes, backtrack
# TODO : check if it is possible to raise an exception NotFeasible while looking for a max_path 
# TODO : think about what happens if min is not 0

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
    
    @graph.maximise_flow
  end #initialize

  def statisfied?
    return @graph.is_feasible?
  end

  def update(deleted, added, var, compteur, pile)
  end

          
  # TODO : same_scc to be optimized (use hashtable?)
  def same_scc(start_node, end_node, scc)
    scc[start_node] == scc[end_node]
  end

  def apply(compteur, pile)
    # Getting all SCC
    # Deleting all arcs that have a null flow and donot belong to the same SCC
    
    scc = @graph.tarjan

    @graph.each_arc do |arc|
      if arc.flow == 0 && same_scc(arc.start_node, arc.end_node, scc)
        puts "deleting arc : " + arc.to_s
        arc.delete
      end
    end
  end # apply

end # classe ContrainteGCC
