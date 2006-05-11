#Contrainte d'equivalence
require 'contraintes/contrainteSimple.rb'

class Equivalence < ContrainteSimple


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

		for i in 0..1
			if getVar(i%2).guessed?
				if getVar((i+1)%2).guessed?
					return getVar(i%2).domain == getVar((i+1)%2).domain
				else
					getVar((i+1)%2).setDomain(getVar(i%2).domain.dup,compteur,pile)
				end
			end
		end
		return true

	end

end
