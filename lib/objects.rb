require './lib/utility'
include Utility

module GameObject
  def unload (game)
  end
  def act (game)
  end
  def react (game)
  end
  def draw (game)
  end
  def debug_draw (game)
    draw(game)
  end
  def click_area
    Vec2.new(16, 16)
  end
  def to_a
    []
  end
end


