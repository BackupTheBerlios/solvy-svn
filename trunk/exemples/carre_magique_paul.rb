require 'solvy'
require 'tools/tools'

##### n, coté du carré

opts=Hash.new(0)

ARGV.each do |foo|
  opts[foo.split('=')[0]]=foo.split('=')[1].to_i
end

n=5
n=opts["n"] if opts["n"] != 0

pb = Problem.new
tab = Array.new

for i in 0..n-1
  for j in 0..n-1
    tab.push(pb.civ("C"+i.to_s+"_"+j.to_s,1,n*n))
  end
end


sum = pb.civ("sum",1,5000) # porko style
pb.post(pb.eq(sum,n * (n*n + 1) / 2))

pb.post(pb.all_diff(tab,"tous differents"))

tab.get_array_by_row().each do |foo|
  pb.post(pb.eq(pb.sum(foo),sum))
end

tab.get_array_by_col.each do |foo|
  pb.post(pb.eq(pb.sum(foo),sum))
end

pb.post(pb.eq(pb.sum(tab.get_diag_nw_se(0)),sum))
pb.post(pb.eq(pb.sum(tab.get_diag_sw_ne(0)),sum))

# Pour un carré magique diabolique, c'est par ici :)
# for i in 1..n-1
#   pb.post(pb.eq(pb.sum(tab.get_diag_nw_se(i) + tab.get_diag_nw_se(i-n)),sum)) # les diags no_se
#   pb.post(pb.eq(pb.sum(tab.get_diag_sw_ne(i) + tab.get_diag_sw_ne(i-n)),sum)) # et les so_ne
# end

sol = Solvy.new(pb)
sol.solve

tab.print_domain
