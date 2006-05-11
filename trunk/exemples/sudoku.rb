require 'solvy.rb'

# def getSudoku()
#  sudo = []
#  while (sudo.size < 9)
#    row = gets.scan(/\d|_/).map { |s| s.to_i }
#    sudo << row if row.size == 9
#  end
# @mon_sudoku = sudo
#  return sudo
# end


pb = Problem.new

# var1 = pb.createIntVar("var1",1,4)
# var2 = pb.createIntVar("var2",3,6)
# var3 = pb.createIntVar("var3",5,7)

arr = Array.new

for i in 1..9
  for j in 1..9
    arr.push(pb.createIntVar("var"+i.to_s+"__"+j.to_s,1,9))
  end
end


# entree du sudoku
# temp = getSudoku()
temp=[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]
a=Array.new(81)

# puts $*[0]
for i in 0..$*[0].length-1
  if $*[0][i,1] == "_"
    a[i] = 0
  else
    a[i] = $*[0][i,1].to_i
  end
end
# puts a.to_s

for i in 0..8
  for j in 0..8
    temp[i][j] =a[i*9+j]
  end
end



for i in 0..8
  for j in 0..8
    if temp[i][j]!=0
      pb.post(pb.eq(arr[i*9+j],temp[i][j]))
    end
  end
end




# lignes
for i in 0..80
  j = 0
  while (j+(i%9)) < 9
    if i+j != i
      pb.post(pb.neq(arr[i],arr[i+j]))
    end
    j+=1
  end
end




# colonnes

for i in 0..80
  j = 0
  while j+i < 81
    if i+j != i
      pb.post(pb.neq(arr[i],arr[i+j]))
    end
    j+=9
  end
end



# Contrainte dans une zone :
base = [0,1,2,9,10,11,18,19,20]

for k in 0..2
  for l in 0..2
    
    for i in 0..8
      for j in i+1..8
        pb.post(pb.neq(arr[base[i]+l*27+k*3],arr[base[j]+l*27+k*3]))
      end
    end
  end
end


# puts pb.myH
sol = pb.solveur
sol.randomized = true
if pb.solveAll()

	while pb.next_sol
  i = 0
  
  
  puts "+-------+-------+-------+"
  for i in 0..80
    if (i%9 == 0) 
      print "|"
    end
    print " "+arr[i].domain.to_s
    if (i+1)%3 == 0
      print " |"
    end
    if (i+1)%9 == 0
      puts ""
    end
    if (i+1)%27 == 0
      puts "+-------+-------+-------+"
    end
  end
	end
  #  pb.print()
  
  # else
  # puts "Contradiction!!!!!!!!!!!!!"
  # end

	puts "j'ai trouve "+sol.nb_found.to_s+" solution(s)"
end


# pprint()
