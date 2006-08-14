require 'solvy.rb'

pb = Problem.new

arr = Array.new

for i in 1..9
  for j in 1..9
    arr.push(pb.createIntVar("var"+i.to_s+"__"+j.to_s,1,9))
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


sol = Solvy.new(pb)
sol.randomized = true

sol.solve()
removed = []
left = (0..80).to_a
test = 0
line = 0
nb = sol.nb_found
while nb <= 1 && test < 80

	a = rand(9)
	idx = left[(line%9)*9+a]
	#left.delete_at((line%9)*9+a)
  removed.push(idx)
	removed.each do |i|
		arr[i].setDomain(Domain.new(1..9),0,sol.pile)
	end
	sol.solveAll
	while sol.next_sol
	end
	line+=1
 
  puts sol.nb_found
  if sol.nb_found > 1
    removed.pop
		test +=1
  end



end

removed.pop
removed.each do |i|
	arr[i].setDomain(Domain.new(1..9),0,sol.pile)
end

	


puts "+-------+-------+-------+"
  for i in 0..80
    if (i%9 == 0) 
      print "|"
    end
		if arr[i].domain.length == 1
    	print " "+arr[i].domain.to_s
		else
			print " _"
		end
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

out = ""
for i in 0..arr.length-1
	if arr[i].domain.length > 1
		out = out+"_"
	else
		out = out+arr[i].domain.to_s
	end
end
puts out

