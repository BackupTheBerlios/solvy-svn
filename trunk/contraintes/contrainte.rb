#Cette classe represente une contrainte, son type est une chaine de caracteres, elle a egalement deux variables.

require 'intvar.rb'

class Contrainte
	@@id_count = 0

	@id
	@tab
	@type
	@en_file
	@name

	attr_reader :tab,:type,:id,:en_file
	attr_writer :type,:en_file

	def getVar(i)
		@tab[i]
	end


	def initialize(tab,type,name="")
		@id = @@id_count
		@@id_count += 1
		@tab = tab
		@type=type
		@en_file = false
		@name = name
		
	end


	#equal? sert à determiner l'egalité au sens des variables d'instances de deux contraintes

	def equal?(autreC)
		if (self.tab.length != autreC.tab.length) || (autreC.type != self.type)
			return false
		else
			for i in 0..self.tab.length-1
				if !self.getVar(i).equal?(autreC.getVar(i))
					return false
				end
			end

		end
		return true

	end

	#def ==(other)
	#	other.id == @id
	#end

	#appelée si jamais la contrainte est executée
	#A modifier dans le code utilisateurs si ça l'interesse
	def on_call type
	end
end
