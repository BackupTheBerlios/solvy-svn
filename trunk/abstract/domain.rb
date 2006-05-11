#Cette classe represente un domaine, c'est à dire un ensemble d'entier, il peut etre implementé à l'aide de n'importe quel structure.
class Domain

	####Variables d'instance ###

	@rep
	@is_a_range


	### Accesseurs ###

	attr_writer :rep
	attr_reader :rep
	attr_accessor :is_a_range


	### Constructeur ###

	def initialize(tab=[])
		if tab.is_a?(Range)
			if tab.length > 499
				@rep = tab.dup
				@is_a_range = true
			else
				@rep = tab.to_a
				@is_a_range = false

			end
		elsif tab.is_a?(Array)
			if tab.length > 499
				@rep = tab.first..tab.last
				@is_a_range = true
			else
				@rep = tab.dup
				@is_a_range = false
			end
		else
			raise "Arguments Error"
		end
		#pour le moment un domaine est un tableau ou un Range.

	end


	### Methode + Operator overloading ###

	def opposite #Retourne un nouveau domaine avec les opposés
		if @rep.is_a?(Array)
			temp = Array.new(@rep.length,0)
			for i in 0..@rep.length-1
				temp[@rep.length-1-i] = -@rep[i]
			end
			return Domain.new(temp.dup)
		elsif @rep.is_a?(Range)
			return Domain.new(-@rep.last..-@rep.first)
		end
	end

	def [](a)
		@rep.at(a)
	end

	def +(other)
		if other.is_a_range
			Domain.new(other.rep+@rep)
		else
			temp = @rep+other.rep
			Domain.new(@rep+other.rep) #parce que ici c des tableaux !
		end
	end

	def -(other)
		if other.is_a?(Domain)
			if other.is_a_range
				Domain.new((@rep.first..@rep.last)-other.rep)
			else
				Domain.new(@rep-other.rep) #idem
			end
		elsif other.is_a?(Integer)
			Domain.new(@rep - [other])
		end
	end
	def &(other)
		if other.is_a_range
			Domain.new(other.rep&@rep)
		else
			Domain.new(@rep & other.rep) # reduction de domaine
		end
	end

	def ==(other)
		@rep == other.rep
	end

	def empty?
		@rep.empty?
	end

	def include?(integer)
		@rep.include?(integer)
	end

	def delete_at(i)
		if is_a_range
			if i == 0
				@rep = (@rep.first+1)..@rep.last
			elsif i == @rep.length-1
				@rep = (@rep.first..(@rep.last-1))
			end
			if @rep.length<= 499
				@rep = @rep.to_a
				@is_a_range = false
			end

		else
			@rep.delete_at(i)
		end
	end
	def dup
		Domain.new(@rep.dup)
	end

	def last
		@rep.last
	end

	def first
		@rep.first
	end

	def pop
		if is_a_range
			out = @rep.last
			@rep = @rep.first..(@rep.last-1)
			if @rep.length <= 499
				@rep = @rep.to_a
				@is_a_range = false
			end
			return out
		else
			@rep.pop
		end
	end

	def push(i)
		if is_a_range
			if i  > @rep.last
				@rep = @rep.first..i
			end
		else
			@rep.push(i)
			if @rep.length > 499
				@rep = @rep.sort.first..@rep.sort.last
				@is_a_range = true
			end
		end
	end

	alias << push

	def shift
		if is_a_range
			out = @rep.first
			@rep = (@rep.first+1)..@rep.last
			if @rep.length <= 499
				@rep = @rep.to_a
				@is_a_range = false
			end
			return out
		else
			@rep.shift
		end
	end

	def length
		@rep.length
	end

	alias size length

	def sort
		@rep = @rep.sort
	end

	def to_a
		@rep.to_a
	end

	def to_s
		@rep.to_a.to_s
	end

	def delete obj
		if is_a_range
			if obj == @rep.first
				delete_at(0)
			elsif obj == @rep.last
				delete_at(@rep.length-1)
			end
		else
			@rep.delete obj
		end
	end

	def each
		@rep.each{|i| yield i}
	end

	def map
		Domain.new(@rep.map{|i| yield i})
	end
end

class Range

	def length
		return last-first+1
	end

	def at(idx)
		if idx+first > last
			raise "Index out of Bounds"
		else
			idx+first
		end

	end

	def -(other)
		if last > other.last && first < other.first
			return first..last
		elsif other.first > first && other.last > last && other.first < last
			return first..other.first-1
		elsif first >= other.first && other.last >= last
			return []
		elsif first >= other.first && last > other.last && first < other.last
			#puts 'coin'
			return (other.last+1)..last
		elsif first >= other.first && last > other.last && first >= other.last
			return (other.last+1)..last

		elsif other.first <= first && other.last == first
			return (first+1)..last
		elsif other.first == last && other.last >= last
			return first..(last-1)
		elsif other.first > last || other.last <first
			return first..last
		elsif first < other.first && last <= other.last
			return first..other.first-1
		end
		

	end
	def +(other)
		if first < other.first
			temp = first
		else
			temp = other.first
		end
		if last > other.last
			temp2 = last
		else
			temp2 = other.last
		end
		return temp..temp2
	end

	def &(other)

		if first < other.first
			temp = other.first
		else
			temp = first
		end
		if last > other.last
			temp2 = other.last
		else
			temp2 = last
		end
		return temp..temp2
	end

	def empty?
		false
	end

	def sort
		self
	end


end

