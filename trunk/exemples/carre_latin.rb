require 'solvy.rb'
require 'tools/tools.rb'

opts=Hash.new(0)
ARGV.each do |foo|
  opts[foo.split('=')[0]]=foo.split('=')[1].to_i
end
n=5
n=opts["n"] if opts["n"] != 0

pb = Problem.new
tab = []

for i in 0..n*n-1
  tab.push(pb.civ("var"+i.to_s,0,n-1))
end

for i in 0..n-1
  pb.post(pb.all_diff(tab.get_row(i),"contrainte lignes"))
  pb.post(pb.all_diff(tab.get_col(i),"contrainte colonnes"))
end

sol = Solvy.new(pb)
sol.solveAll

#pb.print
while sol.next_sol
  tab.print_domain
  puts
end


