require 'set'

class Node
  attr_reader :arcs
  attr_accessor :marquer, :value
  
  def initialize value=0
    @arcs = Set.new
    @value = value
    @marked = false
  end

  def add_arc arc
    @arcs << arc
  end

  def each_arc
    @arcs.each{|a| yield a}
  end

  def each_successor
    @arcs.each{|a| yield a.end_node}
  end
  
end


class Arc
  attr_accessor :min_flow, :max_flow, :flow
  attr_reader :end_node
  
  def initialise(end_node, min_flow=0, max_flow=1, flow=1)
    @min_flow = min_flow
    @max_flow = max_flow
    @flow = flow
    @end_node = end_node
  end
end


class Flow_graph

  attr_reader :nodes_list
  
  def initialize
    @nodes_list = Array.new
  end

  def add_node value=0
    @nodes_list << Node.new(value)
  end
 
  # Ajoute un arc du noeud i au noeud j
  def add_arc(i, j, min_flow=0, max_flow=1, flow=0)
    arc = Arc.new(@nodes_list[j], min_flow, max_flow, flow)
    @nodes_list[i].add_arc(arc)
  end
  
  # Appose le marquer marker sur tous les noeuds
  def mark marker
    @node_list.each{|n| n.marked=marker}
  end

  # Parcours en largeur en partant du sommet s
  # Ignore tous les sommets marqués!
  # Retourne l'ensemble des sommets atteints
  # En O(m)
  def breadth_first_search_rec s
    reached  = Set.new # Contient l'ensemble des sommets atteints
    s.each_successor do |y|
      if !y.marked # Si on a pas encore parcouru cette case, on relance un parcours depuis ce sommet
	y.marked = true
	reached.merge(breadth_first_search_rec(y))
      end
    end
    reached.add(s)
  end

end


class BipartiteFlowGraph < FlowGraph

  attr_reader :card

  # i et j sont le nombre de sommets dans chaque ensemble
  def initialize(i,j)
  
