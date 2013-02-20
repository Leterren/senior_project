module Utility

  Vec2 = CP::Vec2

  # Convenience method for converting from radians to a Vec2 vector.
  class Numeric
    def radians_to_vec2
      CP::Vec2.new(Math::cos(self), Math::sin(self))
    end
  end

  class Rect
    attr_accessor :l, :t, :r, :b


    def lt
      Vec2.new(l, t)
    end

    def rb
      Vec2.new(r, b)
    end

    def initialize (l, t, r, b)
      @l = l
      @t = t
      @r = r
      @b = b
    end

    def self.infinite
      Rect.new(-10000.0, -10000.0, 10000.0, 10000.0)
    end

    def to_a
      [@l, @t, @r, @b]
    end

    def merge (o)
      Rect.new(
        @l < o.l ? @l : o.l,
        @t < o.t ? @t : o.t,
        @r > o.r ? @r : o.r,
        @b > o.b ? @b : o.b
      )
    end

    def intersect (o)
      Rect.new(
        @l > o.l ? @l : o.l,
        @t > o.t ? @t : o.t,
        @r < o.r ? @r : o.r,
        @b < o.b ? @b : o.b
      )
    end

    def contains (p)
      p.x > @l && p.y > @t && p.x < @r && p.y < @b
    end

    def constrain (p)
      newp = Vec2.new(
        p.x < @l ? @l : p.x > @r ? @r : p.x,
        p.y < @t ? @t : p.y > @b ? @b : p.y
      )
    end
  end

end
