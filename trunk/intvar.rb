#Cette classe represente une variable -> un nom (string) et un domaine (Tableau d'entier) et un boolean qui dit si le domaine a été modifié
require 'abstract/domain.rb'
require 'observer'

class IntVar
	include Observable
	@@id_count = 0 #il compte le prochain no d'id
	### variables d'instance ###

	@name							#Le nom de la variable (string)
	@depend						#Variable d'etat, pour savoir si il faut tenter un branching										#sur cette variable.
	@problem					#Le probleme auquel la variable est liée
	@domain
	@pile_const			#pile des contraintes associés à cette variable
	@id							#identifiant unique de l'instance
	@done
	@specifique				#Pointeur vers une contrainte utile.
	@in_problem
	### accesseurs ###

	attr_reader :problem,:pile_const,:id,:done
	attr_writer :depend,:name,:pile_const,:done
	attr_accessor :specifique,:in_problem,:domain,:name

	def depend?
		@depend
	end

	def in_problem?
		@in_problem
	end

	def in?(arr)
		b = false
		arr.each do |x|
			if self.same_name?(x)
				return true
			end
		end
		return b
	end
		

	### constructeur ###

	def initialize(aname,pb)
		@id = @@id_count
		@@id_count += 1
		if (aname.is_a?(String))
			@name = aname
			@problem = pb
			@pile_const = []
			@done = false
			@in_problem = false
		else
			puts "Error in parameter types (IntVar)"
			exit(0)
		end
	end



	### Operator Overloading ###


	def -(other)
		@problem.minus(self,other)
	end

	def +(other)
		@problem.plus(self,other)
	end

	def *(other)
		@problem.mult(self,other)
	end

	def ==(other)
		@problem.eq(self,other)
	end

	def <(other)
		@problem.lt(self,other)
	end

	def >(other)
		@problem.gt(self,other)
	end

	def <=(other)
		@problem.leq(self,other)
	end

	def >=(other)
		@problem.geq(self,other)
	end

	def =~(other)
		@problem.neq(self,other)
	end

	#	def =(other)
	#		@problem.eq(self,other)
	#	end


	### Methodes ###


	def equal?(intvar)			#Verivie l'egalité de deux intvars		
		return intvar.domain == @domain && intvar.name == @name
	end

	def same_name?(intvar)
		return intvar.name == @name
	end



	def guessed?()					#Retourne vrai si la variable a été devinée
		return (domain.length == 1)
	end

	def call 
		self
	end

	def result
		if guessed?
			domain.first
		else
			false
		end
	end


end

