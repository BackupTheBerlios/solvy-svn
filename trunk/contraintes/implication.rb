#Contrainte d'implication
require 'contraintes/contrainteSimple.rb'

class Implication < ContrainteSimple


	### Constructeur ###

	def initialize(avar1,avar2)
		super(avar1,avar2,"Equivalence")
		if avar1.is_a?(IntVar)
			avar1.add_observer(self)
		end
		if avar2.is_a?(IntVar)
			avar2.add_observer(self)
		end	
	end


	### Methode ###
	#
	def update(deleted,added,var,compteur,pile)


	end


	def apply(compteur,pile)

		
			if getVar(0).guessed? # si la première variable est décidé
				if getVar(0).domain.first == 0 # si elle est à "faux"
					return true									 # l'implication est toujours vrai
				elsif getVar(1).guessed?			 # si les deux sont décidé
					return getVar(1).domain.first == 1 # seul vrai est autorisé pour l'autre variable.
				else
					getVar(1).setDomain(getVar(0).domain.dup,compteur,pile) #sinon on peut reduire la deuxieme variable
				end
			end
			#pareil avec non-b -> non-a
			if getVar(1).guessed?
				if getVar(1).domain.first == 1
					return true
				elsif getVar(0).guessed?
					return getVar(0).domain.first == 0
				else
					getVar(0).setDomain(getVar(1).domain.dup,compteur,pile)
				end
			end

	return true
		

	end

end
