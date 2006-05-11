require 'solvy'
require 'timeout'
require 'tools/tools.rb'

opts=Hash.new(0)

ARGV.each do |foo|
  opts[foo.split('=')[0]]=foo.split('=')[1].to_i
end

b = true

while b
  
  pb = Problem.new
  
  arr = Array.new
  n=5
  n=opts["n"] if opts["n"] != 0
  
  for i in 0..n-1
    for j in 0..n-1
      arr.push(pb.civ("C"+i.to_s+"_"+j.to_s,1,n*n))
    end
  end
  
  sum = pb.civ("sum",1,4010)
  
  pb.post(pb.eq(sum,n * (n*n + 1) / 2))
  
  #pb.post(arr[9] =~ arr[8])
  
  for i in 0..(n*n)-1 
    for j in 0..i-1
      pb.post(arr[j]=~arr[i])
    end
  end

  #pb.post(pb.all_diff(arr,""))
  #pb.post(arr[9] =~ arr[8])

  for i in 0..n-1
    pb.post(pb.eq(pb.sum(arr.get_row(i)),sum))
    pb.post(pb.eq(pb.sum(arr.get_col(i)),sum))
  end

  
#   tab = []
#   for i in 0..n-1
#     tab.push(arr[n*i+j])
#   end  

#   for j in 0..n-1    

#     tab = []
#     for i in 0..n-1
#       tab.push(arr[n*i+j])
#     end
#     pb.post(pb.eq(pb.sum(tab),sum))
#   end
  
  
 
	for i in 0..n-2
    pb.post(arr[i] < arr[i+1])
    pb.post(arr[i*n] < arr[(i+1)*n])
  end
  
  begin
    status = Timeout::timeout(9999999) {
      sol = Solvy.new(pb)
			sol.randomized = false
      sol.solveAll()
      b = false
      #pb.print()
      #
      
      #sol.tab_des_solutions.each do |tab|
      #	arr = []
      #	tab.each do |x|
      #		if !x[0].include?("sum")
      #			arr.push(x[1])
      #		end
      #	end
      
      
      while sol.next_sol

        arr.print_domain
        
        # for i in 0..n*n-1
          
          
#           if (arr[i].domain.first < 10)
#             print "  "+arr[i].domain.to_s+"  "
#           elsif (arr[i].domain.first < 100)
#             print " "+arr[i].domain.to_s+"  "
#           else
#             print arr[i].domain.to_s+"  "
#           end
          
#           if i%n == n-1 && i!=0
#             puts " "
#           end
#         end
        
        puts "sum : "+sum.domain.to_s
      end
      
    }
  rescue Timeout::Error
    puts "1 timeout"
  end
end
