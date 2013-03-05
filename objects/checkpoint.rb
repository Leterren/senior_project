require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Checkpoint
  attr_accessor :order
  include GameObject
  def to_a
  	[@body.pos.x, @body.pos.y, @width, @height, @order]
  end
  def initialize (game, x, y, width = 100, height = 100, order = 1)
    space = game.space
     # physicsy stuff
    @body = CP::Body.new_static
    @body.pos = Vec2.new(x, y)
    @body.object = self 
    poly = [Vec2.new(-width/2, -height/2), Vec2.new(-width/2, height/2), Vec2.new(width/2, height/2), Vec2.new(width/2, -height/2)]
    @shape = CP::Shape::Poly.new(@body, poly, Vec2.new(0, 0))
     # Player will update reset_point when collision of type :checkpoint happens
    @shape.collision_type = :checkpoint
    @shape.object = self
    @shape.sensor = true
    space.add_shape @shape
    game.space.add_collision_handler(:player, :checkpoint, Checkpoint_Collisions.new)
    @order = order
    @width = width
    @height = height
  end
  def click_area
    Rect.new(@body.pos.x - @width/2, @body.pos.y - @height/2, @body.pos.x + @width/2, @body.pos.y + @height/2)
  end

  class Checkpoint_Collisions
    def begin (player_s, checkpoint_s, contact)
      if player_s.object.recent_checkpoint < checkpoint_s.object.order
        player_s.object.reset_point = checkpoint_s.body.pos
        player_s.object.recent_checkpoint = checkpoint_s.object.order
        player_s.object.message = "Checkpoint!"
        player_s.object.message_timer = 30
      end
      return true  # Go through with this collision
    end
  end

  def unload (game)
    game.space.remove_shape @shape
  end

end