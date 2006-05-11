#Cette classe represente une variable -> un nom (string) et un domaine (Tableau d'entier) et un boolean qui dit si le domaine a été modifié
require 'abstract/domain.rb'
require 'observer'

class IntVar
	include Observable
	@@id_count = 0 #il compte le prochain no d'id
	### variables d'instance ###

	@name							#Le nom de la variable (string)
	@domain						#Le domaine de type Domain, c'est un ensemble d'entier
	@depend						#Variable d'etat, pour savoir si il faut tenter un branching										#sur cette variable.
	@problem					#Le probleme auquel la variable est liée

	@pile_const				#pile des contraintes associés à cette variable
	@id							#identifiant unique de l'instance
	@done
	@specifique				#Pointeur vers une contrainte utile.
	@in_problem
	### accesseurs ###

	attr_reader :name,:domain,:problem,:pile_const,:id,:done
	attr_writer :depend,:name,:pile_const,:done
	attr_accessor :specifique,:in_problem

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
		

	def setDomain(unTab,compteur,pile)
		if unTab == @domain
			
		
		elsif unTab.is_a?(Domain)
			if compteur >=0
				pile.push([compteur,self,self.domain.dup])
			end
			#@domain = unTab
			changed #le domaine a changé (utilisé pour observer) 
			#On fait remarquer à ceux qui nous observent les changements
			#Le 1er paramètre sont les éléments supprimés
			#Le 2e les éléments rajoutés
			#Le 3e, c'est pour qu'on sache quel objet a été modifié
			deleted = @domain - unTab
			added = unTab - @domain
			@domain = unTab
			notify_observers(deleted,added, self,compteur,pile)
			if compteur >=0
				@problem.enfile(@pile_const)
			end
	  else
		 raise "SetDomain : argument is not a domain!"
		end
		
	end



	### constructeur ###

	def initialize(aname,adomain,pb)
		@id = @@id_count
		@@id_count += 1
		if (aname.is_a?(String) && (adomain.is_a?(Array) || adomain.is_a?(Range)))
			@name = aname
			@domain = Domain.new(adomain)
			@depend = false
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


	def -@
		a = IntVar.new("DuMmyy",domain.opposite.to_a,@problem)
		@problem.post(@problem.opeq(self,a))
		return a
	end

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


	def dup()								#copie en profondeur l'objet courant
		out = IntVar.new(name().dup,domain.to_a,@problem)
		return out
	end


	def guessed?()					#Retourne vrai si la variable a été devinée
		return (@domain.length == 1)
	end

	def result
		if guessed?
			@domain.first
		else
			false
		end
	end


end

