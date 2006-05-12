#Cette classe represente une variable -> un nom (string) et un domaine (Tableau d'entier) et un boolean qui dit si le domaine a été modifié
require 'abstract/domain.rb'
require 'intvar.rb'
require 'observer'

class IntVarDyn < IntVar

	@proc			#procedure that can recalculate the intvar
	@tab_other_var #Array that contains all the intvar this dynamic intvar 
								 #should be evaluated with


	attr_accessor :tab_other_var

	alias other tab_other_var

	def in_problem?
		@in_problem
	end


		def setDomain(unTab,compteur,pile)
		if unTab == domain
			
		
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
			deleted = domain - unTab
			added = unTab - domain
			call.setDomain(unTab,compteur,pile)
			notify_observers(deleted,added, self,compteur,pile)
			if compteur >=0
				@problem.enfile(@pile_const)
			end
	  else
		 raise "SetDomain : argument is not a domain!"
		end
		
	end


	### constructeur ###

	def initialize(aname,a_proc,other_var,pb)
		super(aname,pb)
		if (a_proc.is_a?(Proc) && other_var.is_a?(Array) )
			@proc = a_proc
			@tab_other_var = other_var
			@pile_const = []
			@done = false
			@in_problem = false
			@depend=true
		else
			puts "Error in parameter types (IntVar)"
			exit(0)
		end
	end



	### Operator Overloading ###



	### Methodes ###

	def domain
		call.domain
	end

	def call
		var = @proc.call(@tab_other_var)
		#self.name = var.name
		var
	end

	def dup()								#copie en profondeur l'objet courant
		out = IntVarDyn.new(name.dup,@proc,@tab_other_var,@problem)
		return out
	end


end

