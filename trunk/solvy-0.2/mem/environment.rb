require 'trail.rb'

class Environment

  @trail
  @current_world


  attr_accessor :trail,:current_world


  def initialize
    @trail = Trail.new(self)
    @current_world = 0
  end

  def get_world_index
    @current_world
  end

  def world_push
    @trail.world_push()
    @current_world += 1
  end

  def world_pop
    @trail.world_pop()
    @current_world -= 1
  end


  def make_bt_obj(obj)
    Backtrackable.new(self,obj)
  end



  


end
