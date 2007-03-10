require 'trail.rb'

class Environment

  @trail
  @world


  attr_accessor :trail,:world


  def initialize
    @world = 0
    @trail = Trail.new(self)
  end

  def get_world_index
    @world
  end

  def world_push
    @trail.world_push()
    @world += 1
  end

  def world_pop
    @trail.world_pop()
    @world -= 1
  end


  def make_bt_obj(obj)
    Back_Obj.new(self,obj)
  end
end
