require 'solvy'
pb = Problem.new                                                                                                                          
tab = []                                                                                                                         
n=50
for i in 0..n-1
  tab.push(pb.civ("var"+i.to_s,i,i+5))                                                                            
end                                                                                                                              
pb.post(pb.all_diff(tab,""))                                                                                                       
sol = Solvy.new(pb)                                                                                                             
b =sol.solve                                                                                                                    
pb.print                                                                                                                         
