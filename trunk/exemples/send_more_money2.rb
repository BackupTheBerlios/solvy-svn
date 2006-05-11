# encore un exemple type
#  SEND
# +MORE
# -----
# MONEY
# 
# Avec S!=0 et M!=0
# C'est tout

require 'solvy'
pb = Problem.new
send = pb.civ("send", 1000, 9999)
more = pb.civ("more", 1000, 9999)
money = pb.civ("money", 10000, 19998)
s = pb.civ("s",1,9); e = pb.civ("e",0,9); n = pb.civ("n",0,9); d = pb.civ("d",0,9)
m = pb.civ("m",1,9); o = pb.civ("o",0,9); r = pb.civ("r",0,9); y = pb.civ("y",0,9)
temp = [s,e,n,d,m,o,r,y]

for i in 0..6
 for j in i+1..(7)
   pb.post(temp[i] =~ temp[j])
 end
end

send = pb.sum([s*1000,e*100,n*10,d])
more = pb.sum([m*1000,o*100,r*10,e])
money = pb.sum([m*10000,o*1000,n*100,e*10,y])
pb.post(send + more == money)

sol = Solvy.new(pb)
sol.solve
