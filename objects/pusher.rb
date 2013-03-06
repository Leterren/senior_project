require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Pusher
  include GameObject
  attr_accessor :game, :start
  def to_a
    [@start.x, @start.y, @image_filename]
  end

  def initialize (game, x, y, image_filename = 'water.png')
    @start = Vec2.new(x,y)
    @image_filename = image_filename
    @image = Gosu::Image.new(game, "#{IMAGES_DIR}/#{image_filename}", true)
    space = game.space
    @game = game
     # physicsy stuff
    w = @image.width
    h = @image.height
    @body = CP::Body.new(1.0, CP::INFINITY)
    @body.pos = Vec2.new(x, y)
    @body.object = self
    @body.v_limit = 2
    space.add_body @body

    poly = [Vec2.new(0, 0), Vec2.new(0, h), Vec2.new(w, h), Vec2.new(w, 0)]
    @shape = CP::Shape::Poly.new(@body, poly, Vec2.new(0, 0))
    
    @shape.collision_type = :pusher
    @shape.object = self
    @shape.sensor = true

    space.add_shape @shape

    game.space.add_collision_handler(:player, :pusher, Player_Collisions.new)
    game.space.add_collision_handler(:solid, :pusher, Platform_Collisions.new)

    @width = w
    @height = h
  end
  def click_area
    Rect.new(@body.pos.x, @body.pos.y, @body.pos.x + @width, @body.pos.y + @height)
  end

  class Player_Collisions
    def begin (player_s, pusher_s, contact)
      player_s.object.currentHP -= 5
      player_s.body.apply_impulse(Vec2.new(0, 10), Vec2.new(0,0))
      return true  # Go through with this collision
    end
  end

  class Platform_Collisions
    def begin (player_s, pusher_s, contact)
      pusher_s.body.pos = pusher_s.object.start
      pusher_s.body.vel.y = 0
      return true  # Go through with this collision
    end
  end

  def draw (game)
    @image.draw(*game.camera.to_screen(@body.pos).to_a, ZOrder::FAR)
  end

  def unload (game)
    game.space.remove_shape @shape
  end
end