require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Victorypoint
  attr_accessor :game
  include GameObject
  def to_a
  	[@body.pos.x, @body.pos.y, @width, @height, @image_filename]
  end
  def initialize (game, x, y, width = 100, height = 100, image_filename = 'portal.png')
    @game = game
    @image_filename = image_filename
    @image = Gosu::Image.new(game, "#{IMAGES_DIR}/#{image_filename}", true)
    space = game.space
     # physicsy stuff
    @body = CP::Body.new_static
    @body.pos = Vec2.new(x, y)
    @body.object = self 
    poly = [Vec2.new(width/4, height/4), Vec2.new(width/4, 3*height/4), Vec2.new(3*width/4, 3*height/4), Vec2.new(3*width/4, height/4)]
    @shape = CP::Shape::Poly.new(@body, poly, Vec2.new(0, 0))
     # Player will acheive victory when collision happens
    @shape.collision_type = :victorypoint
    @shape.object = self
    @shape.sensor = true
    space.add_shape @shape
    game.space.add_collision_handler(:player, :victorypoint, Victorypoint_Collisions.new)
    @width = width
    @height = height
  end
  def click_area
    Rect.new(@body.pos.x, @body.pos.y, @body.pos.x + @width, @body.pos.y + @height)
  end

  class Victorypoint_Collisions
    def begin (player_s, victorypoint_s, contact)
      #player_s.object.message = "Victory!"
      #player_s.object.message_timer = 60
      player_s.object.previctory = true
      
      return true  # Go through with this collision
    end
  end

  def draw ()
    @image.draw(*game.camera.to_screen(@body.pos).to_a, ZOrder::FAR)
  end

  def unload ()
    game.space.remove_shape @shape
  end
  def reset()
  end
end