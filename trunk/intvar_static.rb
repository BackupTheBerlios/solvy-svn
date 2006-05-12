#Cette classe represente une variable -> un nom (string) et un domaine (Tableau d'entier) et un boolean qui dit si le domaine a été modifié
require 'abstract/domain.rb'
require 'intvar.rb'
require 'observer'

class IntVarStat < IntVar

	### variables d'instance ###

	@domain						#Le domaine de type Domain, c'est un ensemble d'entier
	### accesseurs ###

	attr_reader :domain


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
		super(aname,pb)
		if (adomain.is_a?(Array) || adomain.is_a?(Range))
			@name = aname
			@domain = Domain.new(adomain)
			@depend = false
		else
			puts "Error in parameter types (IntVar)"
			exit(0)
		end
	end



	### Operator Overloading ###


	def -@
		a = IntVarStat.new("DuMmyy",domain.opposite.to_a,@problem)
		@problem.post(@problem.opeq(self,a))
		return a
	end


	### Methodes ###


	def dup()								#copie en profondeur l'objet courant
		out = IntVar.new(name().dup,domain.to_a,@problem)
		return out
	end



end

