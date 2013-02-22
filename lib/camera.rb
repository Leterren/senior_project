require './lib/utility'
include Utility

class Camera
  attr_accessor :pos, :limits, :screen

  def initialize (w, h)
    @pos = Vec2.new(0, 0)
    @limits = Rect.infinite
    @screen = Rect.new(-w/2, -h/2, w/2, h/2)
  end

  def reset
    @pos = Vec2.new(0, 0)
    @limits = Rect.infinite
  end

  def limit (bound)
    @limits = @limits.intersect(bound)
    @pos = @limits.constrain(@pos)
  end

  def limit_edges (bound)
    @limits = Rect.new(
      bound.l - @screen.l,
      bound.t - @screen.t,
      bound.r - @screen.r,
      bound.b - @screen.b
    )
  end

  def attend (p)
     # Guard against nans
    return unless p.x == p.x && p.y == p.y
    @pos = @limits.constrain(p)
  end

  def to_screen (p, factor = 1.0)
    return p - (@pos * factor) - @screen.lt
  end

  def from_screen (p)
    return p + @screen.lt + @pos
  end

end

