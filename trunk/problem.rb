# ici, c'est la classe problem, elle decrit le problem, elle contient le Hash des variables/contraintes
require 'set'
# intvar.rb est la classe qui represente une variable
require 'intvar_static.rb'
require 'intvar_dynamic.rb'

# les outils de manipulation des tableaux...
require 'tools/tools.rb'
# Bon là ca me parait evident
require 'contraintes/contrainteEq.rb'
require 'contraintes/contrainteNeq.rb'
require 'contraintes/contrainteGt.rb'
require 'contraintes/contrainteGeq.rb'
require 'contraintes/contrainteAD.rb'
#require 'contraintes/contrainteSum.rb'
require 'contraintes/scalar.rb'
require 'contraintes/contrainteOpEq.rb'
require 'contraintes/contrainteMul.rb'
require 'contraintes/occurence.rb'
require 'contraintes/contrainteGCC.rb'

# Contraintes Boolean

require 'contraintes/equivalence.rb'
require 'contraintes/implication.rb'

require 'set'
# la classe pour resoudre un probleme
# require 'solver.rb'


class Problem < Tools
  
  ### Variables d'instance ###
  @dummyNameNb 		# Juste pour savoir le nombre de fausses variables créees
  @nbCst		# Aucune idée je m'en souviens plus
  @myH			# Devrait changer de nom... tableau des variables
  @myH_name		# Le nom des variables... dans le meme ordre ct plus pratique
  @file_de_prop   # La file de propagation contenant des contraintes
  @all_constraint # Toute les contraintes...
  @mini			# tableau des fonctions objectifs à minimiser
  @maxi			# tableau des fonctions objectifs à maximiser
	@solveur  # Le solveur
  
  ### Accesseurs ###
  
  attr_reader :myH,:nbCst
  attr_writer :nbCst
  attr_accessor :myH_name,:all_constraint,:file_de_prop,:mini,:maxi,:dummyNameNb,:solveur
  
  def setH(aH)
    @myH = aH.dup
  end
  
  
  
  ### Constructeur ###
  
  def initialize
    @myH = Array::new
    @myH_name = []
    @dummyNameNb = 0
    @nbCst =0
    @file_de_prop =  []
    @all_constraint = Set.new
    @mini = []
    @maxi = []
		@solveur = Solvy.new(self)
  end
  
  
  
  ### Methodes ###
  
  
  # post sert à ajouter une contrainte au probleme. il place les contraintes dans un tableau appartenant à chque variables mises en jeu.
  def post(constraint)
    @all_constraint.add(constraint)
    constraint.tab.each do |var|
			if var.in_problem?
        if !exist?(var,constraint)
          if constraint.is_a?(ContrainteSimple)
            var.pile_const.unshift(constraint)
          else
            var.pile_const.push(constraint)
          end
        end
      else
				var.in_problem = true
        myH.push(var)
        myH_name.push(var.name)
        var.pile_const.push(constraint)
      end
    end
    return self
  end
  
  
  # Propagate, sert à filtrer les domaines des variables en fonction des contraintes de chacune de ces variables.
  def propagate(count,pile)
    while !@file_de_prop.empty?
      cst = @file_de_prop.shift
      cst.en_file = false
      if !cst.apply(count,pile)
        return false
      end
    end
    return true
    
  end
  
  # rajoute une contrainte ou un tableau de contrainte à la file de propagation
  def enfile(cst)
    if cst.is_a?(Contrainte)
      if !cst.en_file # || cst.en_file
        @file_de_prop.push(cst)
        cst.en_file = true
      end
    elsif cst.is_a?(Array)
      for i in 0..cst.length-1
        if !cst[i].en_file # || cst[i].en_file
          @file_de_prop.push(cst[i])
          cst[i].en_file = true
        end
        # puts a
      end
    end
  end


	# Resoud le probleme
	
	def create_file
		myH.each do |var|
			enfile(var.pile_const)
		end
	end
	
	def solve
		myH.each do |var|
			enfile(var.pile_const)
		end
		solveur.solve()
	end

	def solveAll
    myH.each do |var|
			enfile(var.pile_const)
		end
		solveur.solveAll()
	end

	def next_sol
		solveur.next_sol
	end
  
  # Sert à créer une variable, en indiquant un nom une borne inf et sup
  def createIntVar(name,mini,maxi)
    if mini.class == Array
      return IntVarStat.new(name,mini,self)
    elsif (mini.is_a?(Integer) && maxi.is_a?(Integer))
      temparr =(mini..maxi)
      return IntVarStat.new(name,temparr.dup,self)
    else 
      puts "Error"
    end
  end
  alias civ createIntVar
  
  
  def create_bool_var(name)
    civ(name,0,1)
  end
  alias cbv create_bool_var
  
  # Retourne une contrainte d'egalité entre deux variables
  def eq(var1,var2)
    return ContrainteEq.new(var1,var2)
  end
  
  # Retourne une contrainte de difference entre deux variables
  def neq(var1,var2)
    return ContrainteNeq.new(var1,var2)
  end
  
  # Retourne une contrainte var1 > var2
  def gt(var1,var2)
    return ContrainteGt.new(var1,var2)
  end
  
  # Retourne une contrainte var1 < var2
  def lt(var1,var2)
    return ContrainteGt.new(var2,var1)
  end
  
  # Retourne une contrainte var1 >= var2
  def geq(var1,var2)
    return ContrainteGeq.new(var1,var2)
  end
  
  # Retourne une contrainte var1 <=var2
  def leq(var1,var2)
    return ContrainteGeq.new(var2,var1)
  end
  
  # Retourne une contrainte idiote, comme moi. << bebui ... t'es comme le 'H' de @myH ... :)
  def opeq(var1,var2)
    return ContrainteOpEq.new(var1,var2)
  end
  
  # retourne une contrainte globale de difference entre toutes les variables dans tab
  def all_diff(tab, name)
    return ContrainteAD.new(tab, name)
  end

  def gcc(tab, mins, maxs)
    return ContrainteGCC.new(tab, mins, maxs)
  end
  
  # sera remplacé par at_least et at_most, la flemme. meme pas implementé
  def occurence(var1,var2)
    return Occurence.new(var1,var2)
  end
  
  # Creer une variable representant la somme de plusieurs variables
  def sum(tab,coef = Array.new(tab.length,1))
    mini = 0
    maxi = 0
    for i in 0..tab.length
      if tab[i].is_a?(IntVar)
        maxi+= tab[i].domain.last*coef[i]
        mini+= tab[i].domain.first*coef[i]
      elsif tab[i].is_a?(Integer)
        maxi+=tab[i]*coef[i]
        mini+=tab[i]*coef[i]
        tab[i]= IntVarStat.new("DuMmyINT"+tab[i].to_s,[tab[i]],self)
      end
    end
    varS = createIntVar("PlusDuMmy"+@dummyNameNb.to_s,mini,maxi)
    varS.depend = true
    @dummyNameNb+=1
    varD = civ("PlusDuMmy"+@dummyNameNb.to_s,mini,maxi)
    @dummyNameNb+=1
    post(eq(varD,varS))
    cst = ContrainteSum.new([varD]+tab,coef)
    post(cst)
    varS.specifique = cst
    return varS
  end

  
  # Retourne une variable de la somme de deux variables
  def plus(iva,ivb)
    return sum([iva,ivb]) 
  end
  
  # Pareil avec moins, la contrainte idiote est là.
  def minus(iva,ivb)
    if ivb.is_a?(IntVar)
      temp = -ivb
      temp.name="MinusDuMmy"+@dummyNameNb.to_s
    elsif ivb.is_a?(Integer)
      temp = IntVarStat.new("DuMmyINT"+ivb.to_s,[-ivb],self)	
    end
    post(ContrainteOpEq.new(ivb,temp))
    @dummyNameNb+=1	
    return sum([iva,temp])
    
  end
  alias moins minus
  
  # PAreil que somme mais avec la multiplication :)
  def multiplication(tab)
    mini = 1
    maxi = 1
    for i in 0..tab.length-1
      if tab[i].is_a?(IntVar)
        mini*=tab[i].domain.first
        maxi*=tab[i].domain.last
      elsif tab[i].is_a?(Integer)
        mini*= tab[i]
        maxi*= tab[i]
        tab[i] = IntVarStat.new("DuMmyINT"+tab[i].to_s,[tab[i]],self)
      end
    end
    var_returned = civ("MultDuMmy"+@dummyNameNb.to_s,mini,maxi)
    var_returned.depend=true
    @dummyNameNb+=1
    var_in_const = civ("MultDuMmy"+@dummyNameNb.to_s,mini,maxi)
    @dummyNameNb+=1
    post(eq(var_returned,var_in_const))
    
    post(ContrainteMul.new([var_in_const]+tab))
    
    return var_returned
    
  end
  alias multAll multiplication	
  
  
  # multiplication de deux valeurs.
  def mult(iva,ivb)
    multiplication([iva,ivb])
  end
  alias time mult
  
  # rajoute une fonction objectif à maximiser
  def maximize(intvar)
    @maxi.push(intvar)
			post(eq(IntVarStat.new("Objectif",intvar.domain.first..intvar.domain.last,self),intvar))
  end
  
  # rajoute une fonction objectif à minimiser
  def minimize(intvar)
    @mini.push(intvar)
		post(eq(IntVarStat.new("Objectif",intvar.domain.first..intvar.domain.last,self),intvar))
  end

	#return a dynamic intvar that can take the mininmum value
	def min(tab_of_intvar)
		my_proc = Proc.new do |tab|
			currentvar=tab[0]
			currentmin=currentvar.domain.first
			tab.each do |var|
				if var.domain.first < currentmin
					currentmin = var.domain.first
					currentvar=var
				end
			end
			currentvar
		end
		out = IntVarDyn.new("DuMmyDynamic"+@dummyNameNb.to_s,my_proc,tab_of_intvar,self)
		@dummyNameNb+=1
		out
	end
  
end
