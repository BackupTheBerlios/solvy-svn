#Contrainte plus grand que
require 'contraintes/contrainteSimple.rb'


class ContrainteGt < ContrainteSimple


	### Constructeur ###

	def initialize(avar1,avar2)
		super(avar1,avar2,"gt")
	end



	### Methode ###


	def satisfied?
		getVar(0).guessed? && getVar(1).guessed? && getVar(0).result > getVar(1).result
	end

	def opposite
		ContrainteGeq.new(getVar(1),getVar(0))
	end

	#sert à filtré les domaines, enleve des domaines tous ce qui menerait à une contradiction. 
	def apply(cpt,pile)

		#premier cas : intersection nulle et tous plus grand à droite -> contradiction.

		if (getVar(0).domain.last <= getVar(1).domain.first)
			#      puts "Contradiction0"
			return false
		else
			temp1 = getVar(0).domain.dup
			temp2 = getVar(1).domain.dup

			while temp1.first <= temp2.first

				temp1.shift


				if temp1.empty?
					#          puts "Contradiction1"
					return false
				end

			end


			while temp1.last <= temp2.last
				temp2.pop
				if temp2.empty?
					#           puts "Contradiction2"
					return false
				end

			end

			if (temp1!= getVar(0).domain)
				getVar(0).setDomain(temp1,cpt,pile)
			end

			if (temp2!= getVar(1).domain)
				getVar(1).setDomain(temp2,cpt,pile)
			end

		end

		return true
	end

end
