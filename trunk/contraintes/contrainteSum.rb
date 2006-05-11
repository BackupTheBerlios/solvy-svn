# Cette classe represente une contrainte sur une somme.

require 'contraintes/contrainte'

class ContrainteSum < Contrainte
  
  @somme
  
  def getSum
    @somme
  end
  
  def initialize(tab)
    @somme=tab[0]
    @somme.depend=true
    super(tab,"plus")
  end
  
  def apply(compteur,pile)
    maxi = 0
    mini =0
    for i in 1..tab.length-1
      maxi+= getVar(i).domain.last
      mini+= getVar(i).domain.first
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
      tempmin = mini - getVar(i).domain.first + getVar(i).domain.last
      tempmax = maxi - getVar(i).domain.last + getVar(i).domain.first
      tempVarDom = getVar(i).domain.dup
      while tempmin > @somme.domain.last
        if tempVarDom.length == 1
          return false
        end
        tempmin = tempmin - tempVarDom.pop + tempVarDom.last
      end
      
      while tempmax < @somme.domain.first
        if tempVarDom.length ==1
          return false
        end
        tempmax = tempmax - tempVarDom.shift + tempVarDom.first
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
