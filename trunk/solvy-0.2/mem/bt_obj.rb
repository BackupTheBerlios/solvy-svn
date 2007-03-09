require 'environment.rb'
class Backtrackable 

  #variables d'instance
  
  @obj_ptr       # object pointer
  @current_value # Backtrackable part of the object
  @trail         # Objects trail
  @stamp         # world stamp
  @environment   # class containing the trails


  attr_accessor :current_value,:stamp
  attr_reader :environment,:trail

  def initialize (env,obj)
    begin 
      @current_value = obj.backtrackable()
      @obj_ptr = obj
    rescue
      @current_value = obj
      @obj_ptr  = obj
    end

    @environment = env
    @stamp = env.current_world()
    @trail = env.trail();
  end

  def get
    @current_value
  end
  

  
  def to_s
    @current_value.to_s
  end
end


