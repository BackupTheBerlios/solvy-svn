require 'set'

# TODO : test/debug
# TODO : clean-up code, make it more rubyish (specialy tarjan method

def min(a,b)
  return a if a<b
  return b
end


class Node
  attr_reader :arcs_out, :arcs_in
  attr_accessor :marker, :value
  
  def initialize value=0
    @arcs_out =  Set.new
    @arcs_in = Set.new
    @value = value
    @marker = false
  end

  def add_arc_out arc; @arcs_out << arc; end
  def add_arc_in arc; @arcs_in << arc; end

  def delete_arc_out arc; @arcs_out.delete arc; end
  def delete_arc_in arc; arcs_in.delete arc; end

  def add_arc(node, min_flow=0, max_flow=1, flow=0)
    arc = Arc.new(self, node, min_flow, max_flow, flow)
    add_arc_out arc
    node.add_arc_in arc
  end
  
  def each_arc_in; @arcs_in.each{|arc| yield arc}; end
  def each_arc_out; @arcs_out.each{|arc| yield arc}; end

  def each_successor; @arcs_out.each{|a| yield a.end_node}; end
  def each_predecessor; @arcs_in.each{|a| yield a.start_node}; end

  def each_residual_successor
    each_arc_out{|arc| yield arc.end_node if arc.residue > 0}
    each_arc_in{|arc| yield arc.start_node if arc.reverse_residue > 0}
  end
  
  def to_s; "node: {title: \"#@value\"}"; end

  def is_marked?; @marker; end

  def mark; @marker = true; end

  def flow_in; @arcs_in.inject{|sum, arc| sum + arc.flow}; end
  def flow_out; @arcs_out.inject{|sum, arc| sum + arc.flow}; end
    
end #class Node


class Arc
  attr_accessor :min_flow, :max_flow, :flow
  attr_reader :start_node, :end_node
  
  def initialize(start_node, end_node, min_flow=0, max_flow=1, flow=0)
    @min_flow = min_flow
    @max_flow = max_flow
    @flow = flow
    @start_node = start_node
    @end_node = end_node
  end

  def to_s
    "edge: {sourcename: \"#{@start_node.value}\"
    targetname: \"#{@end_node.value}\"
    label: \"#@min_flow - #@flow - #@max_flow\"}"
  end

  def residue; return @max_flow - @flow; end

  def reverse_residue; return @flow - @min_flow; end

  def delete
    @start_node.delete_arc_out self
    @end_node.delete_arc_in self
  end
  
end # class Arc


class Flow_graph

  attr_reader :nodes_list

  def initialize
    @nodes_list = Array.new
  end

  def nb_nodes; return @nodes_list.size; end
  def each; @nodes_list.each{|node| yield node}; end
  
  def each_arc
    @nodes_list.each do|node|
      node.each_arc_out{ |arc| yield arc}
    end
  end

  def add_node value=0
    node = Node.new(value)
    @nodes_list << node
    node
  end

  # Ajoute un arc du noeud i au noeud j
  def add_arc(i, j, min_flow=0, max_flow=1, flow=0)
    arc = Arc.new(@nodes_list[i], @nodes_list[j], min_flow, max_flow, flow)
    @nodes_list[i].add_arc_out arc
    @nodes_list[j].add_arc_in arc 
    arc
  end

  # Appose le marquer marker sur tous les noeuds
  def mark marker; @nodes_list.each{|n| n.marker=marker}; end


  # Finds a paths where the flow can be increased
  # Returns the arcs and by how much the path can be increased
  def augmenting_path s
    s.mark

    # if we're the sinc
    # TODO : we should find something better to determine which is the sink and source
    # I think that the algorthimes could be implemented without knowing which node is the sink or source
    return [[],[], 1.0/0] if s == @nodes_list[1]

    #We'll explore each arc, to see if there is an augmenting path throught it
    s.each_arc_out do |arc|
      residue = arc.residue
      if !arc.end_node.is_marked? and residue > 0
        path = augmenting_path arc.end_node
        return [path[0] << arc, path[1], min(path[2],residue)] if path != nil
      end
    end

    # Ok, we found nothing interesting
    # Let's try if we can redirect some flow
    s.each_arc_in do |arc|
      residue = arc.reverse_residue
      if !arc.start_node.is_marked? and residue > 0
        path = augmenting_path arc.start_node
        return [path[0], path[1] << arc, min(path[2],residue)] if path != nil
      end
    end

    # The is no augmenting path starting from this node
    return nil
  end


  # TODO get this shit more cleaner
  # Returns all the strongly connected components as a hash
  # Two nodes of the same SCC will be two keys for the same value
  def tarjan
    root = {} 
    rang = {}
    scc = {}
    k = 0
    pile = []

    visit = Proc.new do |s, r|
      s.mark
      pile << s
      root[s] = rang[s] = r + 1

      s.each_residual_successor do |x|
          visit.call(x, r+1) if !x.is_marked?
          root[s] = min(root[s], root[x]) if pile.include?(x)
      end

      if rang[s] == root[s]
        k += 1
        until (z = pile.pop) == s
          scc[z] = k
        end
        scc[s] = k
      end
    end

    mark false
    each{ |node| visit.call(node, 0) unless node.is_marked? }
    scc
  end


  def maximise_flow
    mark false #we mark all node as not explored
    while (path = augmenting_path(@nodes_list[0]))
      mark false #we mark all node as not explored
      path[0].each {|arc| arc.flow += path[2] }
      path[1].each {|arc| arc.flow -= path[2] }
    end
  end

  def to_s
    str = "graph: {\n"
    @nodes_list.each{|n| str += n.to_s + "\n"}
    @nodes_list.each{|n| n.each_arc_out{|a| str += a.to_s + "\n"}}
    str += "}\n"
    str
  end

  def feasible?
    @nodes_list.each do |node|
      if node != @nodes_list[0] && node != @nodes_list[1]
        puts node
        return false if node.flow_in != node.flow_out
      end
    end
    flows = true
    each_arc{|arc| flows &= (arc.flow >= arc.min_flow && arc.flow <= arc.max_flow) }
    return flows
  end

end
