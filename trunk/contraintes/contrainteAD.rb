require 'tools/graph.rb'
require 'contraintes/contrainte.rb'
#TODO : invoquer une muser pour les noms de variables
class ContrainteAD < Contrainte

  @representation # GraphMatching
  @possibles # toutes les valeurs que peuvent prendre les variables
  #@possibles[j] est une valeur que peut prendre la variable
  # j ça sera le n° de sommet pour cette valeur dans le graph
  @nb_var #le nombre de variables
  @id_to_node #À partir de l'id il trouve quel no de noeud il a ds le graph
  @val_to_node #À partir d'une valeur ------------------- " ---------------

  def initialize(tab, name="")
    tab.flatten!
    @nb_var = tab.size
    #On calcule l'ensemble des possibilités
    @possibles = []
    tab.each { |var| @possibles |= var.domain.to_a }

    super(tab,"AD", name)

    @representation = GraphMatching.new(@nb_var, @possibles.size)

    @id_to_node = {}
    @val_to_node = {}
    tab.each_with_index do |var, i|
      #On observe les changements de domaine
      var.add_observer(self)

      @id_to_node[var.id] = i

      @possibles.each_with_index do |poss, j|
	@val_to_node[poss] = j+@nb_var
	if var.domain.include?(poss)
	  @representation.add(i, @val_to_node[poss]) 
	end
      end

    end
  end

 #Cette méthode est appelée à chaque fois que le domaine de var est modifié
  def update(deleted, added, var,compteur,pile)
    begin
      i = @id_to_node[var.id]

      deleted.each do |val|
	@representation.delete(i, @val_to_node[val])
      end

      added.each do |val|
	@representation.add(i, @val_to_node[val])
      end
    end
  end

  def apply(compteur,pile)
    #On applique la méthode qui m'a tellement fait bavé sur les graphes
    begin
      changed = @representation.hyper_arc_consistency
      #On change le domaine de chaque variable si celui-ci a évolué
      changed.each do |i|
	#On construit le nouveau domaine
	new_tab = @representation.graph[i].to_a.map{ |j| @possibles[j-@nb_var] }.sort
	@tab[i].setDomain(Domain.new(new_tab), compteur, pile)
      end
      true
    rescue Contradiction
      #puts @name
      false
    end
  end


	def opposite
		raise "Pas encore implementé"
	end


	
	def satisfied?
		i = 0
		while i < tab.length && getVar(i).guessed?
			i+=1
		end
		if i < tab.length
			return false
		else
			for i in 0..tab.length-1
				for j in i+1..tab.length-1
					if getVar(i).result == getVar(j).result
						return false
					end
				end
			end
			return true
		end
	end
end



