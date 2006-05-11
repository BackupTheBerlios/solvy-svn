#Cette classe est là par manque d'intelligence de l'auteur (Julien)
require 'contraintes/contrainteSimple.rb'


class ContrainteOpEq < ContrainteSimple

	### Constructeur ###

	def initialize(var1,var2)
		super(var1,var2,"opeq")

	end

	def satisfied?
		getVar(0).guessed? && getVar(1).guessed? && -getVar(0).result == getVar(1).result
	end

	def apply(compteur,pile)
		if getVar(0).guessed?
			if (getVar(0).domain != getVar(1).domain.opposite)
				if getVar(1).domain.opposite.include?(getVar(0).domain[0])

					getVar(1).setDomain(getVar(0).domain.opposite,compteur,pile)
				else
					return false
				end
			end

		elsif getVar(1).guessed?
			if (getVar(0).domain.opposite != getVar(1).domain)
				if getVar(0).domain.opposite.include?(getVar(1).domain[0]) 

					getVar(0).setDomain(getVar(1).domain.opposite,compteur,pile)
				else
					return false
				end
			end

		else
			temp = getVar(0).domain & getVar(1).domain.opposite

			if temp.empty?
				return false
			else
				if getVar(0).domain != temp

					getVar(0).setDomain(temp,compteur,pile)
				end
				if getVar(1).domain != temp.opposite

					getVar(1).setDomain(temp.opposite,compteur,pile)
				end
			end
		end

		return true
	end

end

