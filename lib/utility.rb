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
      Rect.new(-1.0/0.0, -1.0/0.0, 1.0/0.0, 1.0/0.0)
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
      if p.instance_of? Vec2
        p.x > @l && p.y > @t && p.x < @r && p.y < @b
      elsif p.instance_of? Rect
        p.l > @l && p.t > @t && p.r < @r && p.b < @b
      else
        raise TypeError.new
      end
    end

    def constrain (p)
      newp = Vec2.new(
        p.x < @l ? @l : p.x > @r ? @r : p.x,
        p.y < @t ? @t : p.y > @b ? @b : p.y
      )
    end
    def + (x)
      if x.instance_of? Vec2
        return Rect.new(
          @l + x.x, @t + x.y, @r + x.x, @b + x.y
        )
      elsif x.instance_of? Rect
        return Rect.new(
          @l + x.l, @t + x.t, @r + x.r, @b + x.b
        )
      else
        raise TypeError.new
      end
    end
    def - (x)
      return self + (- x)
    end
    def - ()
      return Rect.new(-@l, -@t, -@r, -@b)
    end
  end

end
