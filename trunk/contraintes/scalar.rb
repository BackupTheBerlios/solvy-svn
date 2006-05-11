#Cette classe represente une contrainte sur une somme.

require 'contraintes/contrainte'

class ContrainteSum < Contrainte

	@somme
	@coeff
	def getSum
		@somme
	end

	attr_reader :coeff

	def initialize(tab,coef = Array.new(tab.length-1,1))
		@somme=tab[0]
		@coeff = coef
		@somme.depend=true
		super(tab,"plus")
	end

	def satisfied?
		i = 0
		while i < tab.length && getVar(i).guessed?
			i+=1
		end
		if i < tab.length
			return false
		else
			result = 0
			for i in 1..tab.length-1
				result+=getVar(i).result * @coeff[i-1]
			end

			return result == @somme.result
		end
	end


	def apply(compteur,pile)
		maxi = 0
		mini =0
		for i in 1..tab.length-1
			maxi+= getVar(i).domain.last*coeff[i-1]
			mini+= getVar(i).domain.first*coeff[i-1]
		end
		temp = @somme.domain.dup
		while temp.last > maxi
			temp.pop
			if temp.empty?
				return false
			end
		end
		while temp.first < mini
			temp.shift
			if temp.empty?
				return false
			end
		end
		if temp != @somme.domain
			@somme.setDomain(temp.dup,compteur,pile)
		end

		for i in 1..tab.length-1
			tempmin = mini - getVar(i).domain.first*coeff[i-1] + getVar(i).domain.last*coeff[i-1]
			tempmax = maxi - getVar(i).domain.last*coeff[i-1] + getVar(i).domain.first* coeff[i-1]
			tempVarDom = getVar(i).domain.dup
			while tempmin > @somme.domain.last
				if tempVarDom.length == 1
					return false
				end
				tempmin = tempmin - tempVarDom.pop*coeff[i-1] + tempVarDom.last * coeff[i-1]
			end

			while tempmax < @somme.domain.first
				if tempVarDom.length ==1
					return false
				end
				tempmax = tempmax - tempVarDom.shift*coeff[i-1] + tempVarDom.first*coeff[i-1]
			end
			#puts tempVarDom == getVar(i).domain
			if tempVarDom != getVar(i).domain
			#	puts "j'ai changé un truc ! tempVar"
				getVar(i).setDomain(tempVarDom.dup,compteur,pile)
			end
		end
		return true
	end

end
