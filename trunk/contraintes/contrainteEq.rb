#Contrainte d'égalité.
require 'contraintes/contrainteSimple.rb'

class ContrainteEq < ContrainteSimple

	### Constructeur ###

	def initialize(avar1,avar2)
		super(avar1,avar2,"eq")
		if avar1.is_a?(IntVar)
			avar1.add_observer(self)
		end
		if avar2.is_a?(IntVar)
			avar2.add_observer(self)
		end	
	end


	### Methode ###
	#
	#
	
	def satisfied?
		getVar(0).guessed? && getVar(1).guessed? && getVar(0).result == getVar(1).result
	end
	def update(deleted,added,var,compteur,pile)


	end

	def opposite
		ContrainteNeq.new(getVar(0),getVar(1))
	end



	#Apply sert à filtrer les domaines des deux variables, le fonctionnement est assez basique, il enleve des domaines tout entier qui n'est pas present dans les deux domaines. 
	def apply(compteur,pile)
		
		if getVar(0).guessed?
			if (getVar(0).domain != getVar(1).domain)
				if getVar(1).domain.include?(getVar(0).domain[0])

					getVar(1).setDomain(getVar(0).domain,compteur,pile)
				else
					
					return false
				end
			end

		elsif getVar(1).guessed?
			if (getVar(0).domain != getVar(1).domain)
				if getVar(0).domain.include?(getVar(1).domain[0]) 

					getVar(0).setDomain(getVar(1).domain,compteur,pile)
				else
					return false
				end
			end

		else
			temp = getVar(0).domain & getVar(1).domain

			if temp.empty?
				return false
			else
				if getVar(0).domain != temp

					getVar(0).setDomain(temp,compteur,pile)
				end
				if getVar(1).domain != temp

					getVar(1).setDomain(temp,compteur,pile)
				end
			end
		end

		return true
	end

end
