require 'tools/flow.rb'
require 'contraintes/contrainte.rb'
# The Global Cardinality Constraint
# Given a set of variables and values.
# Each value, has to appear at least min times, and at most max times


# NOTE : This contraint should be polymorphic :p (whoa! such an amzing word!!)
# NOTE : In theorie the graph current graph should represent a maximum flow
# ----> the calculation is done during initialization and updated during apply

# TODO : filtering (method apply)
# TODO : domain changes, backtrack : o<
# TODO : check if it is possible to raise an exception NotFeasible while looking for a max_path 
# TODO : think about what happens if min is not 0 (if I remember ford fulkerson has to start with some feasible flow)

class ContrainteGCC < Contrainte

  attr_reader :vars
  
  # mins and maxs are hash tables for each value
  # raises ArgumentError if a certain a value has no associated min or max
  # TODO : thinking about a default behaviour (ie. 0 and +inf)
  def initialize(vars, mins, maxs)
    @tab = vars
    @graph = Flow_graph.new
    source = @graph.add_node "Source"
    sink = @graph.add_node "Sink"
    sink.add_arc(source, 0, 1.0/0) # is it needed?

    @var_nodes = {}
    vals = []
    vars.each do |var|
      @var_nodes[var] = @graph.add_node var
      @var_nodes[var].add_arc sink
      vals |= var.domain.to_a
    end

    
    @val_nodes ={}
    vals.each do |val|
      @val_nodes[val] = @graph.add_node val
      source.add_arc(@val_nodes[val], mins[val], maxs[val])
      vars.each {|var| @val_nodes[val].add_arc @var_nodes[var] if var.domain.include? val}
    end
    
    @graph.maximise_flow
  end #initialize

  def satisfied?
      # first we check that each variable has at least one value assigned
      @var_nodes.each_value{|node| puts node.flow_out}
      return @graph.feasible?
  end

  def update(deleted, added, var, compteur, pile)
  end


  def same_scc(start_node, end_node, scc)
    scc[start_node] == scc[end_node]
  end

  def apply(compteur, pile)
    # Getting all SCC
    # Deleting all arcs that have a null flow and donot belong to the same SCC

    scc = @graph.tarjan
    #puts @graph
    #scc.each_pair{|node, blah| puts node.to_s + " = " + blah.to_s }

    puts satisfied?
    puts @graph.feasible?
    @graph.each_arc do |arc|
      if arc.flow == 0 && !same_scc(arc.start_node, arc.end_node, scc)
        puts "deleting arc : " + arc.to_s
        arc.delete
      end
    end
    true
  end # apply

end # classe ContrainteGCC
