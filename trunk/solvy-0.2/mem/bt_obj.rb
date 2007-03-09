
class Backtrackable 

  #variables d'instance
  
  @current_value # Object copy at current node
  @trail         # Objects trail
  @stamp         # world stamp
  @environment   # class containing the trails


  attr_accessor :current_value,:stamp
  attr_reader :environment,:trail

  def initialize (env,obj)
    @current_value = obj
    @environment = env
    @stamp = env.current_world()
    @trail = env.trail();
  end

  def get
    @current_value
  end
  

  
  def to_s
    puts current_value()
  end
end


