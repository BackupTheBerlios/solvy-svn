require 'solvy'

pb = Problem.new

arr = Array.new

for i in 0..3
  for j in 0..3
    arr.push(pb.civ("C"+i.to_s+"_"+j.to_s,1,16))
  end
end

sum = pb.civ("sum",34,34)


#pb.post(pb.eq(sum,34))

pb.post(pb.all_diff(arr))

for i in 0..3
  pb.post(pb.eq(pb.sum(arr[(4*i)..(4*i+3)]),sum))
end


for j in 0..3
  pb.post(pb.eq(pb.sum([arr[0+j],arr[4+j],arr[8+j],arr[12+j]]),sum))
end

sol = Solvy.new(pb)
sol.solve()

#pb.print()

for i in 0..15

  
  if (arr[i].domain.first < 10)
    print " "+arr[i].domain.to_s+"  "
  else
    print arr[i].domain.to_s+"  "
  end
  
  if i%4 == 3 && i!=0
    puts " "
  end
end

puts "sum : "+sum.domain.to_s
