require 'domain.rb'

d = Domain.new([1,10])
#d.rep = [1..3,6..9,12..19]
e = Domain.new([1,9])

puts d&e
puts d.to_a.to_s
puts e.to_a.to_s
puts d == e
#puts d.first
#puts d.last
#
#12.times {d.pop}
#puts d
