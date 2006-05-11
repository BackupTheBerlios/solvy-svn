#Cette classe represente une contrainte simple qui ne prend que deux variables c la mère de toute les contraintes simple (eq,neq,geq,gt)
require 'contraintes/contrainte.rb'

class ContrainteSimple < Contrainte



	### Constructeur ###

	def initialize(avar1,avar2,type)
		if (avar1.class == IntVar && avar2.class == IntVar)
			super([avar1,avar2],type)

		elsif (avar2.is_a?(Integer) && avar1.class == IntVar)
			super([avar1,IntVar.new("DuMmyINT"+avar2.to_s,[avar2],avar1.problem)],type)

		elsif (avar1.is_a?(Integer) && avar2.class == IntVar)
			super([IntVar.new("DuMmyINT"+avar1.to_s,[avar1],avar2.problem),avar2],type)

		else

			puts "Error in parameter types (Contrainte Simple)"
			exit(0)
		end

	end

end


