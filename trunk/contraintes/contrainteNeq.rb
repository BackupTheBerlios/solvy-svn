#Contrainte de difference entre deux variables
require 'contraintes/contrainteSimple.rb'

class ContrainteNeq < ContrainteSimple

	### Constructeur ###

	def initialize(avar1,avar2)
		super(avar1,avar2,"neq")
	end




	### Methode ###



	def satisfied?
		getVar(0).guessed? && getVar(1).guessed? && getVar(0).result != getVar(1).result
	end

	def opposite
		ContrainteEq.new(getVar(0),getVar(1))
	end
	#apply retire du domaine un entier qui serait seul dans l'autre. (pas clair hein ^^)
	def apply(compteur,pile)
		if getVar(0).guessed?
			if getVar(1).domain.include?(getVar(0).domain[0])
				if (getVar(1).domain - getVar(0).domain).empty?
					return false
				else
					getVar(1).setDomain(getVar(1).domain - getVar(0).domain,compteur,pile)
				end
			end

		elsif  getVar(1).guessed?
			if getVar(0).domain.include?(getVar(1).domain[0])
				if (getVar(0).domain - getVar(1).domain).empty?
					return false
				else
					getVar(0).setDomain(getVar(0).domain - getVar(1).domain,compteur,pile)
				end
			end

		end
		return true
	end

end
