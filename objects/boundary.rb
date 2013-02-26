class Boundary
  include GameObject

  attr_accessor :bounds

  def to_a
    [@bounds.l, @bounds.t, @bounds.r, @bounds.b]
  end

  def initialize (game, l, t, r = l + 400, b = t + 400)
    @bounds = Rect.new(l, t, r, b)
  end

  def react (game)
    game.camera.limit_edges(@bounds)
  end

  def click_area
    @bounds
  end
end
