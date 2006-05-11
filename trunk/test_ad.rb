require 'solvy'
pb = Problem.new

arr = Array.new

  for j in 1..9
    arr.push(pb.createIntVar("var"+j.to_s,1,9))
  end

pb.post(pb.all_diff(arr))
pb.post(arr[0] == 2)
sol = Solvy.new(pb)
sol.solve()
pb.print
