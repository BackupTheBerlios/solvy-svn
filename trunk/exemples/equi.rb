require 'solvy'


pb = Problem.new


bool1 = pb.civ("bool1",0,1)
bool2 = pb.civ("bool2",0,1)
bool3 = pb.civ("bool3",0,1)

pb.post((bool1&bool2)>>bool3)

sol = Solvy.new(pb)
sol.randomized = false
sol.solveAll
while sol.next_sol

pb.print
puts ""
end


