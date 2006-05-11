# encore un exemple type
#  SEND
# +MORE
# -----
# MONEY
# 
# Avec S!=0 et M!=0
# C'est tout

require 'solvy'

tab = Array.new

tab.push("S")
tab.push("E")
tab.push("N")
tab.push("D")
tab.push("M")
tab.push("O")
tab.push("R")
tab.push("Y")

pb = Problem.new
arr = Array.new

tab.each do |foo|
  arr.push(pb.civ(foo,0,9))
end

send = pb.sum(arr[0..4],[1000,100,10,1])
more = pb.sum((arr[4..6].push arr[1]),[1000,100,10,1])
money = pb.sum([arr[4],arr[5],arr[2],arr[1],arr[7]],[10000,1000,100,10,1])

pb.post(pb.eq(pb.sum(send,more),money))

sol = Solvy.new(pb)

sol.solveAll()

while sol.next_sol
end

