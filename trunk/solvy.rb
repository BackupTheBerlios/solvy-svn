# la classe solvy est la classe principale de resolution
require 'problem.rb'
require 'thread'

class Solvy
  
  ### Variables d'instances ###
  
  @problem				# Le probleme que l'on doit resoudre
  @pile						# la pile des changements, set pour le backtrack
  @nb_of_branch		# Combien de fois une valeur a été fixé arbitrairement
  @nb_of_backtrack # Combien de fois recSolve à du revenir en arrière
  @nb_found				# Nombre de solutions trouvé, sert à solveAll
  @all						# Boolean servant à indiquer le type de resolution
  @mutex					# Exclusion mutuelle pour synchroniser les threads
  @cv							# Semaphore 1
  @cv2						# Semaphore 2
  @th							# Thread de la resolution
  @bool						# Un petit workaround qui permet de savoir quand sortir
  @out						# permet de modifier la sortie d'une fonction
  @randomized     # Flag definissant le type de choix de valeurs et de variables
  @minimum				# Cas d'optimisation : dernier minimum atteint
  @maximum				# Cas d'optimisation : dernier maximum atteint
  @save						# Sauvegarde de la dernière solution trouvée
  ### Accesseurs ###
  
  attr_reader :pile,:problem,:nb_found
  attr_accessor :tab_des_solutions,:th,:randomized,:minimum,:maximum,:save
  
  ### Constructeur###
  
  def initialize(pb)
    if pb.is_a?(Problem)
      @problem = pb
      @all = false
      @th = nil
      @bool = true
      @out = true
      @pile = Array::new
      @nb_of_branch = 0
      @nb_of_backtrack = 0
      @nb_found = 0
      @randomized = true
      @problem.myH.each do |var|
        @problem.enfile(var.pile_const)
      end
      @minimum = []
      @maximum = []
      @save = []
      
    else
      puts "Error in Arguments"
      exit(0)
    end
  end
  
  
  
  ### Methodes ###
  
  # Propage les contraintes du problème
  def prop(count,pile)
    @problem.propagate(count,pile)
  end
  
  
  # Fonction qui lance la resolution du probleme.
  #
  
  # Initialise un resolution complete d'un probleme... peut etre très long :p
  # l'exclusion mutuel permet d'avoir "lamain" entre deux solutions.
  def solveAll()
    @mutex = Mutex.new
    @cv =ConditionVariable.new
    @cv2 = ConditionVariable.new
    @nb_found = 0
    @all = true
    @th = Thread.new do
      @mutex.synchronize {
        solvy()
      }
    end
  end
  
  # Rend la main à l'utilisateur entre deux solutions (pour pouvoir l'afficher par exemple
  def next_sol
    if @all
      @mutex.synchronize {
        while true
          if @bool
            @bool = false
            return @out
          else
            @bool = true
            @cv.signal
            @cv2.wait(@mutex)
            
            # return true
          end
        end
      }
    else
      if @bool
        @bool = false
        return true
      else
        return false
      end
    end
    
  end
  
  # Indique que ce n'est qu'une resolution unique
  def solve()
    @all=false
    solvy()
  end
  
  
  # Solvy gere la resolution, en particulier la fin.
  def solvy()
    # initialisation du compteur pour le backtrack
    compteur = 0
    
    # Sur une resolution simple, si recSolve repond faux, c que le probleme est surcontraint.
    if !recSolve(compteur)
      if !@all
        puts "Contradiction"
        return false
      else
        @out = false
        @cv2.signal
        @problem.myH.each_with_index do |x,i|
          x.setDomain(@save[i],compteur,@pile)
        end
        return true
      end
    else
      puts "Il y a eu "+@nb_of_branch.to_s+" choix, et "+@nb_of_backtrack.to_s+" backtracks"
      return true
    end
    
  end
  
  
  # retourn un element au hasard d'un tableau passé en parametres.	
  def randGet(dom)
    if dom.length > 499
      return dom[rand(2)*(dom.length-1)]
    else
      bui = rand(dom.length)
      return dom[bui]
    end
  end
  ####  begin
  #      # Cas d'optimisation, si la valeur minimale du domaine de la fonction objective est plus grande que le dernier minimum stoqué, on n'a pas d'interet à poursuivre cette branche de l'arbre des solutions.
  #      def greater_than_minimum?
  #        if !@problem.mini.empty?
  #          @problem.mini.each_with_index do |x,i|
  #            if @minimum.length > i
  #              if x.domain.first >= @minimum[i][1]
  #                return true
  #              end
  #            end
  #          end
  #        end
  #        return false
  #      end
  
  
  
  #      # Cas d'optimisation, si la valeur maximale du domaine de la fonction objective est plus petite que le dernier maximum stoqué, on n'a pas d'interet à poursuivre cette branche de l'arbre des solutions.
  #      def smaller_than_maximum?
  #        if !@problem.maxi.empty?
  #          @problem.maxi.each_with_index do |x,i|
  #            if @maximum.length > i
  #              if x.domain.last <= @maximum[i][1]
  #                return true
  #              end
  #            end
  #          end
  #        end
  #        return false
  #      end
  ####    end
  def minimize # si la solution trouvée est meilleur, on la stoque.
    if !@problem.mini.empty?
      @problem.mini.each_with_index do |x,i|
        if @minimum.length > i
          if x.domain.first < @minimum[i][1]
            @minimum[i] = [@nb_found,x.domain.first]
          end
        else
          @minimum[i] = [@nb_found,x.domain.first]
        end
        cst = (x < @problem.civ("DuMmyMini"+@problem.dummyNameNb.to_s,x.domain.to_a.dup,nil))
        
        @problem.post(cst)
        @problem.enfile(cst)
        @problem.dummyNameNb+=1
      end
    end
  end
  
  
  def maximize # si la solution trouvée est meilleur, on la stoque.
    if !@problem.maxi.empty?
      @problem.maxi.each_with_index do |x,i|
        if @maximum.length > i
          # puts x.domain.last.to_s+"      "+@maximum[i][1].domain.to_s
          if x.domain.last > @maximum[i][1]
            @maximum[i] = [@nb_found,x.domain.last]
          end
        else
          @maximum[i] = [@nb_found,x.domain.last]
        end
        cst = (x > @problem.civ("DuMmyMini"+@problem.dummyNameNb.to_s,x.domain.to_a.dup,nil))
        
        @problem.post(cst)
        @problem.enfile(cst)
        @problem.dummyNameNb+=1
        
      end
    end
    
    
  end
  
  def recSolve(compteur)		
    
    # On va essayer de propager les contraintes, si prop retourne faux, c que le probleme en l'etat est surcontraint, il va falloir backtracké
    if !prop(compteur,@pile)
      return false
    end
    
    # solved verifie qu'un assignement a ete trouvé.
    # si oui, et que l'on cherche qu'une seule solution, on s'en va
    # dans le cas d'un solveAll, on arrete l'execution de la resolution, on indique a next_sol que l'on a trouvé une solution e ton attend que next_sol nous redonne la main pour continuer.
    if solved?()
      @nb_found+=1
      
      # Au besoin on va stocker la solution si elle est minimale OU maximale
      minimize
      maximize
      
      if @all
        save_last_solution
        @cv2.signal
        @cv.wait(@mutex)
        return false
      else
        return true
      end
    else
      
      
      # le compteur compte le nombre de boucle effectué par recsolve, permet de backtracker à un etat donné
      compteur = compteur +1
      
      # voire plus bas pour getBestKey, permet de modifier la facon dont on selectionne la variable à instancier.
      cle = getBestKey
      temp = cle.domain.dup
      
      for i in 0..(temp.length-1)
        if !@randomized # comme son nom l'indique... interessant dans certain cas.
          el = temp[0]
          temp.shift
        else
          el = randGet(temp)
          temp.delete(el)
        end
        # Branching, on fixe une valeur à une variable... on verra bien :)
        cle.setDomain(Domain.new([el]),compteur,@pile)
        @nb_of_branch+=1
        
        
        if recSolve(compteur) # si ca ne marche pas (defaut de propagation ou une solution a été trouvé mais on veut en trouver une autre, on backtrack à l'aide de restoreState
          return true
        else
          restoreState(compteur)
        end
        
      end
      
      return false
      
    end
  end
  
  def save_last_solution
    @save.clear
    @problem.myH.each do |x|
      @save.push(x.domain.dup)
    end
  end
  
  # Permet de restorer l'etat du problème a un moment donné par le compteur.
  def restoreState(compteur)
    while (!@pile.empty? && @pile.last[0] == compteur)
      temp = @pile.pop       
      temp[1].setDomain(temp[2],-1,@pile)
    end
    @nb_of_backtrack+=1
    @problem.file_de_prop.each { |cst| cst.en_file = false}
    @problem.file_de_prop.clear
  end
  
  
  #########################################################################
  # TODO: Comprendre pouquoi dans certains cas un est plus rapide que l'autre...
  #
  #
  def getBestKey
    # gfak					# Take the first non guessed variable in the hash
    # glck					# Take the least constrained variable in the hash
    # gkmid 				# Take the variable which has the minimum domain size
    mdr						# Take the minimum domain, then random
    # gkmad				# Take the variable which has the maximum domain size
    # gmck					# Take the most constrained variable in the hash
    # gkmidAmc			# Combination of gkmid and gmck 
  end
  #########################################################################
  
  
  def getFirstAppearedKey
    @problem.myH.each_key do |key|
      if !@problem.myH[key].guessed? && (!@problem.myH[key].depend?)
        return key
      end
    end
  end
  
  alias gfak getFirstAppearedKey
  
  def getMostConstrainedKey
    compteur = 0
    temp = nil
    @problem.myH.each_key do |key|
      if (compteur == 0) && (!@problem.myH[key].guessed?) && (!@problem.myH[key].depend?)
        temp = key
        compteur+=1		
        
      elsif (compteur > 0) && (@problem.myH[key].pile_const.length > @problem.myH[temp].pile_const.length) && (!@problem.myH[key].guessed?) &&  (!@problem.myH[key].depend?)
        
        # 	return temp
        temp = key
      end
    end
    return temp
  end	
  alias gmck getMostConstrainedKey
  
  def getLeastConstrainedKey
    compteur = 0
    temp = nil
    @problem.myH.each_key do |key|
      if (compteur == 0) && (!@problem.myH[key].guessed?) && (!@problem.myH[key].depend?)
        temp = key
        compteur+=1		
        
      elsif (compteur > 0) && (@problem.myH[key].pile_const.length < @problem.myH[temp].pile_const.length) && (!@problem.myH[key].guessed?) &&  (!@problem.myH[key].depend?)
        
        # 	return temp
        temp = key
      end
    end
    return temp
  end	
  alias glck getLeastConstrainedKey
  
  
  # La seule fonction fonctionnelle depuis le changement du mode de stockage des variables (Hash -> Tableau)
  def min_dom_et_random
    compteur = 0
    temp = []
    @problem.myH.each do |var|
      if (compteur == 0) && (var.domain.length > 1) && (!var.depend?)
        temp.push(var)
        compteur+=1
        
      elsif compteur > 0
        if var.domain.length == temp[0].domain.length
          temp.push(var)
          
        elsif (var.domain.length < temp[0].domain.length) &&
            (var.domain.length > 1) && 
            (!var.depend?)
          
          temp.clear
          temp.push(var)
        end
      end
    end
    if @randomized
      return temp[rand(temp.length)]
    else
      return temp[0]
    end
  end
  alias mdr min_dom_et_random
  
  
  def getKeyOfMinDomain
    compteur = 0
    temp = nil
    @problem.myH.each do |var|
      if (compteur == 0) && (var.domain.length > 1) && (!var.depend?)
        temp = var
        compteur+=1
        if temp.domain.length == 2
          return temp
        end
        
      elsif compteur > 0
        if var.domain.length == 2 && (!var.depend?)
          
          return var
        end
        if (var.domain.length < temp.domain.length) &&
            (var.domain.length > 1) && 
            (!var.depend?)
          
          temp = var
        end
      end
    end
    return temp
    
  end
  alias gkmid getKeyOfMinDomain
  
  def getKeyOfMaxDomain
    compteur = 0
    temp = nil
    @problem.myH.each_key do |key|
      if (compteur == 0) && (!@problem.myH[key].guessed?) && (!@problem.myH[key].depend?)
        temp = key
        compteur+=1
      elsif (compteur > 0) && (!@problem.myH[key].guessed?) && (!@problem.myH[key].depend?) && (@problem.myH[key].domain.length > @problem.myH[temp].domain.length)
        
        temp = key
      end
    end
    return temp
  end
  alias gkmad getKeyOfMaxDomain
  
  # à priori le plus efficace, retourne la clé possedant le domaine le plus petit ET celle etant la plus contrainte.
  
  def get_key_with_shorter_domain_and_most_constrained # c pas long cà ?
    
    compteur = 0
    temp = nil
    @problem.myH.each_key do |key|
      if (compteur == 0) && (@problem.myH[key].domain.length > 1) && (!@problem.myH[key].depend?)
        temp = key
        compteur+=1
      elsif compteur > 0
        if ((@problem.myH[key].domain.length < @problem.myH[temp].domain.length) || ((@problem.myH[key].domain.length == @problem.myH[temp].domain.length) && (@problem.myH[key].pile_const.length > @problem.myH[temp].pile_const.length))) &&
            (@problem.myH[key].domain.length > 1) && 
            (!@problem.myH[key].depend?)
          
          temp = key
        end
      end 
    end
    
    return temp
    
  end
  alias gkmidAmc get_key_with_shorter_domain_and_most_constrained
  
  
  # Retourne vrai si le probleme a un assignement.
  def solved?		
    b = true
    @problem.myH.each do |x|
      b = b && x.guessed?
      if !b
        return b
      end
    end
    return b
  end
end
