require 'set'
require 'tsort'
# Implémentation de la classe graph. En gros c'est une liste d'adjacence en profitant de quelques comodités du ruby :)
# @graph est un est un tableau d'ensembles ('Set'). @graph[i] contient tous les successeurs de i

class Graph
  @graph
  @n # nbre de sommets
  attr_reader :graph, :n

  # On crée un graphe avec n sommets
  def initialize n
    @graph = Array.new(n){Set.new}
    @n = n
  end

  # On rajoute un arc de i vers j
  def add(i,j)
    @graph[i] << j
  end

  # On supprime l'arc de i vers j
  def delete(i,j)
    @graph[i].delete(j)
  end

  # Parcours en largeur en partant du sommet x
  # Retourne l'ensemble des sommets atteints
  # En O(m)
  def breadth_first_search s
    reached = Set.new # Contient l'ensemble des sommets atteints
    fifo = [s] # La file qui contient les sommets qui restent à explorer
    reached << s
    while !fifo.empty?
      x = fifo.shift
      @graph[x].each do |y|
	if !reached.include?(y) # si on est pas encore passé par ce sommet
	  fifo << y
	  reached << y
	end
      end
    end
    reached
  end

  def pprint
    @graph.each_with_index do |x, i|
      print i, " => "
      x.each{ |y| print y-8, " "}
      print "\n"
    end
  end

  def min(a,b); a<=b ? a : b; end

end

# Défini un graph bi-parti permettant des couplages
# Pour la complexité : m est le nombre d'arcs, n le nombre de sommets dans l'ensemble de départ
class GraphMatching < Graph
  @mate # @mate[i] contient le sommet couplé à i
  @pred # @pred[j] contient le prédécesseur de j. i = @pred[j] et j = @mate[i]
  @card # cardinalité du graphe
  @i # nombre de sommets dans le 1er ensemble
  attr_reader :mate, :pred, :card

  # i et j sont le nombre de sommets dans chaque ensemble
  def initialize(i,j)
    super(i+j)
    @n = i+j
    @mate = Array.new(@n)
    @pred = Array.new(j)
    @i = i
    @j = j
  end

  def add(i,j)
    super(i,j)
    super(j,i)
  end

  # Si on supprime un arc, faut eventuellement le supprimer cet arc du couplage!
  def delete(i,j)
    super(i,j)
    super(j,i)
    if @mate[i] == j # Si on supprime un arc du couplage
      @mate[i] = nil
      @mate[j] = nil
    end
  end

  # Retourne les successeurs du noeud node
  # Si l'arc fait parti du couplage ou pas
  def successors node
    if node < @i # Si c'est une variable, on renvoit la paire du couplage
      if @mate[node]
        Set.new [@mate[node]]
      else
	# @graph[node]
	nil
      end
    else
      @graph[node].reject{|x| x == @mate[x]}
    end
  end
  
  # Retourne les composantes fortement connexes
  # Tous les noeuds d'une même composante on le même no dans le tableau
  def tarjan
    visited = Array.new(@n, false)
    root = Array.new(@n,0)
    rang = Array.new(@n,0)
    scc = Array.new(@n,0)
    k = 0
    pile = []

    visit = Proc.new do |s, r|
      visited[s] = true
      pile << s
      rang[s] = r + 1
      root[s] = r + 1
      #    @graph.successors(s).each do |x|
      successors(s).each do |x|
	if !visited[x]
	  visit.call(x, r+1)
	  root[s] = min(root[s], root[x])
	elsif pile.include?(x)
	  root[s] = min(root[s], rang[x])
	end
      end
      if rang[s] == root[s]
	k += 1
	until (z = pile.pop) == s
	  scc[z] = k
	end
	scc[s] = k
      end
    end

    visited.each_with_index { |bool, i| visit.call(i, 0) unless bool }
    scc
  end

  # Trouve une chaine alternée augmentante
  # Complexité en O(m)
  def augmenting_path
    ap_found = false
    @pred = Array.new(@n) # on remet à zéro la liste des prédecesseurs

    fifo = [] # First-in, first out (file en bon français)
    # On rajoute que les sommets insaturés du 1er ensemble dans la file
    for i in 0..@i-1
      fifo << i unless @mate[i]
    end

    while !ap_found && !fifo.empty?
      x = fifo.shift
	@graph[x].each do |y|
	if !pred[y] && !ap_found
	  @pred[y] = x
	  if !@mate[y]
	    ap_found = true
	    transfert(y)
	    break
	  else
	    fifo << @mate[y]
	  end
	end
      end
    end
    ap_found
  end

  # Effectue un transfert ->  le couplage devient de cardinal += 1
  # Théorème du à Petersen (1891), mais généralement attribué à Berge (1957) ;)
  # En O(m)
  def transfert y
    while y != nil
      @mate[y] = @pred[y]
      x = @mate[@pred[y]]
      @mate[@pred[y]] = y
      y = x
    end
  end

  # Trouve un couplage biparti maximal
  # En O(n·m) - il y a au plus n arcs dans le couplage!
  def max_matching
    while augmenting_path;end
    # À la fin, il le cardinal du couplage doit être égal au nombre
    card = 0
    for i in 0..@i-1
      card += 1 if @mate[i]
    end

    raise Contradiction, "No matching possible" unless card ==@i
  end



#   Nom pédant qui permet de trouver tous les arcs "consistent"
#   Le théorème serait de Petersen 1891
#   Un arc appartient à un couplage max ssi :
#   Soit M un couplage
#   -il fait parti de M
#   ou -il est dans un chemin alternant dans M commençant par un sommet qui ne fait pas partie de M
#   ou -il est dans un circuit alternant dans M (ie. les arc du circuit sont 1 coup dans M, un coup non) -> CFC

#   NB : normalement un couplage n'est pas orienté. Le fait de construire le graphe comme dans foo_graph permet une recherche simple des 2derniers

#   Réf : Van Hoeve (pas d'année, 2004 je pense)


  def hyper_arc_consistency
    # On va reconstruire un nouveau graphe
    consistent_graph = Array.new(@n){Set.new}

    # On cherche un couplage max
    max_matching

    # On rajoute tous les arrêtes du couplage dans le nouveau graphe
    for i in 0..@i-1
      consistent_graph[i] << @mate[i]
      consistent_graph[@mate[i]] << i
    end

    # On rajoute les arcs d'un chemin alternant dans M, commençant depuis un sommet pas dans M
    # TODO : Mettre à jour cette fonction pour utiliser successors
    @mate.each_with_index do |x, i|
      if !x
	reached = @mgraph.breadth_first_search i
	reached.each do |k|
	  @graph[k].each { |x| consistent_graph[k] << x if reached.include?(x) }
	end
      end
    end
    
    # On rajoute les arcs appartenant à la même composante fortement connexe
    scc = tarjan
    for i in 0..@i-1
      @graph[i].each do |y| 
	if scc[i] == scc[y] 
	  consistent_graph[i] << y
	  consistent_graph[y] << i 
	end
      end
    end

    # On detecte les éléments qui ont changé
    changed = Set.new
    for i in 0..@i-1 do
      changed << i unless @graph[i] == consistent_graph[i]
    end
    @graph = consistent_graph
    changed
  end

end
