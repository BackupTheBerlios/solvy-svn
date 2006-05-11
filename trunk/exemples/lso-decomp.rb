require 'solvy.rb'

pb = Problem.new

x1 = pb.civ("x1",0,10)

x2 = pb.civ("x2",0,10)

x3 = pb.civ("x3",0,10)


pb.post(x1-x2+x3*3 >= 10)
pb.post(x1*5+x2*2-x3 >= 6)

pb.minimize(x1*7+x2+x3*5)


sol = Solvy.new(pb)
sol.randomized = true
sol.solveAll
while sol.next_sol
end

pb.print

