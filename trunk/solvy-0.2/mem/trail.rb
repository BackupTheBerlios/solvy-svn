require 'environment.rb'

class Trail

  @environment
  @variable_stack
  @value_stack
  @stamp_stack
  @level
  @starts

  attr_reader :environment
  attr_accessor :variable_stack,:value_stack,:stamp_stack,:level,:starts

  def initialize(env)
    @environment = env
    @level = 0
    @variable_stack = []
    @value_stack = []
    @stamp_stack = []
    @starts = []
  end


  def world_push
    @starts[@environment.world()+1] = @level
  end

  def world_pop
    while (@level > @starts[@environment.world()])
      @level-=1
      v = @variable_stack[@level]
      v.backtrackable = @value_stack[@level]
      v.world = @stamp_stack[@level]
    end
  end

  def get_size
    @level
  end

  def save(v)
    @value_stack[@level] = v.backtrackable()
    @variable_stack[@level] = v
    @stamp_stack[@level] = v.world()
    @level+=1


  end





end
