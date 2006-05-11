require 'solvy'
require 'tools/tools.rb'

opts=Hash.new(0)
ARGV.each do |foo|
  opts[foo.split('=')[0]]=foo.split('=')[1].to_i
end
n=5
n=opts["n"] if opts["n"] != 0

pb = Problem.new
tab = []
n=20
for i in 0..n-1
  tab.push(pb.civ("Queen"+i.to_s,1,n))
end

for i in 0..n-1
  for j in i+1..n-1
    pb.post(tab[i]=~tab[j])
    pb.post(tab[i] =~ tab[j]+(j-i))
    pb.post(tab[i] =~ tab[j]-(j-i))
  end
end
#pb.post(tab[0] == 5)

sol = Solvy.new(pb)
sol.randomized = true
sol.solve

#while sol.next_sol
  
  tmpTab=Array.new
  
  for i in 1..n
    for j in 1..n
      if tab[i-1].domain.to_a.first == j
        tmpTab.push 'X'
      else
        tmpTab.push '_'
      end
    end
  end
  tmpTab.print('|')
  
  pb.print
  #end
