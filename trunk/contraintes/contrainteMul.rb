#Cette classe represente une contrainte sur une somme.

require 'contraintes/contrainte'

class ContrainteMul < Contrainte

	@mul

	attr_accessor :mul

	def initialize(tab)
		@mul=tab[0]
		@mul.depend=true
		super(tab,"mul")
	end




	def satisfied?
		i = 0
		while i < tab.length && getVar(i).guessed?
			i+=1
		end
		if i < tab.length
			return false
		else
			result = 1
			for i in 1..tab.length-1
				result*=getVar(i).result
			end

			return result == @mul.result
		end
	end


	def apply(compteur,pile)
		maxi = 1
		mini =1
		for i in 1..tab.length-1
			maxi*= getVar(i).domain.last
			mini*= getVar(i).domain.first
		end
		temp = @mul.domain.dup
		
		#puts "coin"

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
		if temp != @mul.domain
			@mul.setDomain(temp.dup,compteur,pile)
		end

		for i in 1..tab.length-1
			if getVar(i).domain.first == 0
				tempmin = 1
				for j in 1..tab.length-1
					if j!=i
						tempmin*=getVar(j).domain.first
					end
				end
				tempmin*=getVar(i).domain.last
			else
				tempmin = mini / getVar(i).domain.first * getVar(i).domain.last
			end

			if getVar(i).domain.last == 0
				tempmax = 1
				for j in 1..tab.length-1
					if j!=i
						tempmax*=getVar(j).domain.last
					end
				end
				tempmax*=getVar(i).domain.first
			else
				tempmax = maxi / getVar(i).domain.last * getVar(i).domain.first
			end
			tempVarDom = getVar(i).domain.dup
			while tempmin > @mul.domain.last
				if tempVarDom.length == 1
					return false
				end
				last_d = tempVarDom.pop
				if last_d == 0
					tempmin == 1
					for j in 1..tab.length-1
						if i!=j
							tempmin*=getVar(j).domain.first
						end
					end
					tempmin*=tempVarDom.last
				else
					tempmin = tempmin / last_d * tempVarDom.last
				end
			end

			while tempmax < @mul.domain.first
				if tempVarDom.length ==1
					return false
				end
				first_d = tempVarDom.shift
				if first_d == 0
					tempmax = 1
					for j in 1..tab.length-1
						if i!=j
							tempmax*=getVar(j).domain.last
						end
					end
					tempmax*=tempVarDom.first
				else
					tempmax = tempmax / first_d * tempVarDom.first
				end
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
