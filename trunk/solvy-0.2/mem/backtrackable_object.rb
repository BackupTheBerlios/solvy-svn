require 'environment.rb'

class Back_obj

  @backtrackable
  @obj_ptr
  @trail
  @environment
  @world
  
  attr_accessor :backtrackable,:other_infos,:trail,:environment,:world


  def initialize(env,obj)

    begin
      @backtrackable = obj.backtrackable().clone()
      @obj_ptr = obj
    rescue
      begin
        @backtrackable = obj.clone()
        @obj_ptr = obj
      rescue
        @backtrackable = obj
        @obj_ptr = obj
      end
    end
    @environment = env
    @world = env.world()
    @trail = env.trail()


  end

  def get
    @obj_ptr
  end

  def get_value
    @backtrackable
  end

  def update
    begin
      @obj_ptr.backtrackable = @backtrackable.clone()
    rescue
      begin 
        @obj_ptr.backtrackabke = @backtrackable
      rescue
        @obj_ptr = @backtrackable
      end
    end
  end

  def set(param)
    @backtrackable = param
  end

  def save
    @trail.save(self)
  end

  def to_s
    @obj.to_s
  end
end




