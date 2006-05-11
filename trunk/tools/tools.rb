require 'set'

class Tools

	# Kindly provided by Tristram aka Groubi
	# Permet de connaitre le domaine de la somme de plusieurs variables
	# TODO: Reduire la complexité ! c'est trop long
	def somme_2a2(set1,set2)
		resultat = Set.new
		set1.each do |x|
			set2.each do |y|
				resultat << x+y
			end
		end
		resultat
	end

	def sommes_possibles(tab)
		if tab.size <= 1
			Set.new(tab).to_a.sort
		elsif tab.size == 2
			somme_2a2(Set.new(tab[0]), Set.new(tab[1])).to_a.sort
		else
			tete = tab.shift
			somme_2a2(Set.new(tete), sommes_possibles(tab)).to_a.sort
		end
	end
	#############################
	# un raccourci pratique :)
	# def civ(name,mini,maxi)
	#  createIntVar(name,mini,maxi)  
	#end



	# recupeter un tableau bien ordonné
	def getSorted()
		return myH.sort
	end

	# pour imprimer
	def print()
		sorted = myH
		sorted = order(sorted)
		sorted.each do |var|

			if !var.name.include?("DuMmy")
				puts var.name+" : "+var.domain.to_a.to_s
			end
		end
	end

	def order(tab)

		out =[]
		# test = []
		tab.each do |var|
			# test.push(subtab[1].id)
			out[var.id] = var
		end
		# puts test.sort
		return out.compact
	end

	# pour verifier qu'un clef est presente dans le hash
	def exist?(key,const)
		b = false
		key.pile_const.each do |x|
			if x.is_a?(Contrainte)
				b = x.equal?(const) || b
			end
		end
		b
	end

end


class Contradiction < Exception
end



# La classe array permet d'extraire des lignes,
# colonnes et diagonales du tableau 2 dimensions
# Le tableau peut être rempli sous forme 1 ou 2 dimension
# !!! Uniquement des matrices carrées pour le moment !!!
# TODO : trouver comment hooker une modification pour appeler prepare
class Array
	@myTab # La representation interne est un tableau de tableaux
	@dim_i=nil
	@dim_j=nil

	# prepare permet de préparer la représentation interne
	# du tableau selon les standards utilisés par la classe
	# Si la matrice fournie est en 1d alors qu'elle représente
	# une matrice 2d, elle sera automatiquement convertie si
	# il s'agit d'une matrice carrée. Sinon, le nb de lignes
	# et de colonnes devront être précisés pour les matrices rectangles
	def prepare(nb_row=nil,nb_col=nil)
		@myTab = Array.new
		if (self[0].is_a?(Array))
			@myTab = self
			@dim_i = @myTab.length
			@dim_j = @myTab[0].length
		elsif (!(self[0].is_a?(Array)) && (nb_row && nb_col))
			@dim_i = nb_row
			@dim_j = nb_col
			for i in 0..@dim_i-1
				tmpTab = Array.new
				for j in 0..@dim_j-1
					tmpTab.push(self[i*@dim_j+j])
				end
				@myTab.push tmpTab
			end
		elsif (!(self[0].is_a?(Array)) && !(nb_row || nb_col))
			@dim_i = Math.sqrt(self.length).to_i
			@dim_j = @dim_i
			for i in 0..@dim_i-1
				tmpTab = Array.new
				for j in 0..@dim_j-1
					tmpTab.push(self[i*@dim_j+j])
				end
				@myTab.push tmpTab
			end
		else
			puts "Erreur dans la classe Array, prepare mal défini"
		end
	end

	# si vous voulez le recuperer à plat
	def get_array_flat
		prepare(@dim_i,@dim_j)
		return @myTab.flatten
	end

	# renvoit le tableau par lignes
	def get_array_by_row()
		prepare(@dim_i,@dim_j)
		return @myTab
	end

	# renvoit le tableau par colonnes
	def get_array_by_col()
		prepare(@dim_i,@dim_j)
		tmpTab = Array.new
		for j in 0..@dim_j-1
			tmpTab.push get_col(j)
		end
		return tmpTab
	end

	# Donne la n_ieme ligne
	def get_row(n)
		prepare(@dim_i,@dim_j)
		return @myTab[n]
	end

	# Donne la n_ieme colonne
	def get_col(n)
		prepare(@dim_i,@dim_j)
		tmpCol = Array.new
		@myTab.each do |row|
			tmpCol.push row[n]
		end
		return tmpCol
	end


	# Pour les diagonnale, on les identifie avec nord / est / sud / ouest
	# Et un numéro. Le numéro est compté positif dans le sens horizontal
	# nul pour la grande diagonnale
	# et négatif dans le sens vertical
	# !!! les diagonnales sont reservées au matrices carrées !!!

	# Donne la n_ieme diag nord-ouest/sud-est
	def get_diag_nw_se(n)
		prepare(@dim_i,@dim_j)
		tmpTab = Array.new
		dim = @dim_i
		if (n<0)
			deb = n.abs
			fin = dim - 1
			iterateur = 0
		end
		if (n==0)
			deb = 0
			fin = dim - 1
			iterateur = 0
		end
		if (n>0)
			deb = 0
			fin = dim - 1 - n
			iterateur = n
		end
		for i in deb..fin
			tmpTab.push @myTab[i][iterateur]
			iterateur = iterateur + 1
		end
		return tmpTab
	end

	# Donne la n_ieme diag nord-est/sud-ouest
	def get_diag_ne_sw(n)
		prepare(@dim_i,@dim_j)
		tmpTab = Array.new
		dim = @dim_i
		if (n<0)
			deb = n.abs
			fin = dim - 1
			iterateur = dim - 1
		end
		if (n==0)
			deb = 0
			fin = dim - 1
			iterateur = dim - 1
		end
		if (n>0)
			deb = 0
			fin = dim - 1 - n
			iterateur = dim - 1 - n
		end
		for i in deb..fin
			tmpTab.push @myTab[i][iterateur]
			iterateur = iterateur - 1
		end
		return tmpTab
	end

	def get_diag_sw_ne(n)
		return get_diag_ne_sw(-n).reverse
	end

	def get_diag_se_nw(n)
		return get_diag_nw_se(-n).reverse
	end

	### Outils d'impression

	# Imprime en tableau, sep (=" ") est l'ecartement minimum entre 2 nombres d'une ligne
	def print(sep=" ")
		prepare(@dim_i,@dim_j)
		lgMax = Array.new # ce tableau va connaitre la longueur max de chaque colonne
		for j in 0..@dim_j - 1
			lgMax.push longer(get_col(j))
		end
		for i in 0..@dim_i-1
			tmpRow=""
			for j in 0..@dim_j-1
				tmpRow += sep + " " * (lgMax[j] - @myTab[i][j].to_s.length) + @myTab[i][j].to_s
			end
			tmpRow += sep
			puts tmpRow
		end
	end

	# Imprime le domaine d'un tableau
	# Non portable, specifique à l'implementation de bebui
	# Mais tellement pratique :)
	def print_domain(sep=" ")
		map_domain.print(sep)
	end

	def map_domain
		prepare(@dim_i,@dim_j)
		tabDom=@myTab.map{ |foo| foo.map{ |bar| bar.domain.to_s}}
		return tabDom
	end

	# Renvoit la longueur en caractere de l'element le plus long d'une liste (utilisé pour print)
	def longer(unTab) # unTab est de dimension 1 bien entendu ...
		l = 0
		unTab.each do |foo|
			l = foo.to_s.length if foo.to_s.length > l
		end
		return l
	end

end
