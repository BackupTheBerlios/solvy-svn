# Rendu de monnaie pour un distributeur

require 'solvy'

opts=Hash.new(-1)

ARGV.each do |foo|
  opts[foo.split('=')[0]]=foo.split('=')[1].to_f
end

cout = (opts["cout"]*100).round.to_i    # cout de la boisson
mise = (opts["mise"]*100).round.to_i    # monnaie insérée

# flouz contient un nom, la valeur, et les reserves pour chaque piece
flouz = [["e2",200,50],  # reserve en pièces de 2 euros
  ["e1",100,50],  # ~ 1e
  ["c50",50,45],   # ~ 50 cents
  ["c20",20,60],   # ~ 20 c
  ["c10",10,80]]   # ~ 10 c

pb = Problem.new
tab = Array.new

flouz.each do |foo|
  tab.push(pb.civ(foo[0],0,foo[2]))
end

sum = pb.civ("sum",0,mise)
pb.post(pb.eq(sum,(mise-cout)))

#puts tab
var = pb.sum(tab,flouz.get_col(1)) 
cst = var == sum
pb.post(cst)
pb.minimize(pb.sum(tab))
#pb.maximize(pb.sum(tab))

sol = Solvy.new(pb)
sol.randomized=true
sol.solveAll()
while sol.next_sol
end
  #pb.print
  tab.prepare(1,flouz.length)
  a = []
  a.push flouz.get_col(0)
  a.push tab.map_domain.flatten
  a.print
  puts

	puts cst.satisfied?
	puts var.specifique.satisfied?


