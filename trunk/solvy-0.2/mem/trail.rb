
class Trail

  @environment
  @variable_stack
  @value_stack
  @stamp_stack
  @current_level
  @world_start_levels

  attr_reader :environment
  attr_accessor :variable_stack,:value_stack,:stamp_stack,:current_level

  def initialize(env)
    @environment = env
    @current_level = 0
    @variable_stack = []
    @value_stack = []
    @stamp_stack = []
    @world_start_levels = []
  end


  def world_push
    world_start_levels[@environment.current_world() +1] = @current_level
  end

  def world_pop
    while (@current_level > world_start_levels[@environment.current_world()])
      current_level-=1
      v = @variable_stack[currentLevel]
      v.current_value = @value_stack[current_level]
      v.stamp = @stamp_stack[current_level]
    end
  end

  def get_size
    @current_level
  end

  def save_previous_state(v,old_val,old_stamp)
    value_stack[current_level] = old_val
    variable_stack[current_level] = v
    stamp_stack[current_level] = old_stamp
    current_level+=1
  end






end
