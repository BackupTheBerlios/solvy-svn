require 'solvy.rb'

pb = Problem.new

var1 = pb.civ("var1",1,5)
var2 = pb.civ("var2",1,5)
var3 = pb.civ("var3",1,5)
var4 = pb.civ("var4",1,5)
var5 = pb.civ("var5",1,5)
var6 = pb.civ("var6",1,5)
var7 = pb.civ("var7",1,5)
var8 = pb.civ("var8",1,5)
var9 = pb.civ("var9",1,5)
var10 = pb.civ("var10",1,5)
var11= pb.civ("var11",1,5)
var12 = pb.civ("var12",1,5)


#sum1=pb.sum([var1,var2,var3])
#sum2=pb.sum([var3,var4,var5])
#sum3=pb.sum([var5,var6,var7])
#sum4=pb.sum([var7,var8,var9])
#sum5=pb.sum([var9,var10,var11,var12])



pb.minimize(pb.min([var1,var2]))

sol = Solvy.new(pb)

sol.randomized=true
sol.solveAll
while sol.next_sol
	pb.print
end

pb.print
