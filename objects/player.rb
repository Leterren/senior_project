require 'gosu'
require './lib/objects.rb'

class Player

  JUMP_IMPULSE = 1200.0
  GROUND_ACCEL = 100.0
  GROUND_TOP_SPEED = 300.0
  AIR_ACCEL = 80.0
  AIR_TOP_SPEED = 200.0
  SKID_DECEL = 300.0
  FALLING_TOP_SPEED = 600.0

  attr_accessor :ground
  
  include GameObject
  def to_a
    [@start.x, @start.y, @direction]
  end
  def initialize (game, x, y, dir)
     # Initialize
    @start = Vec2.new(x, y)
    @direction = dir
    @ground = nil
     # Load resources
    @@wow = Gosu::Sample.new(game, "#{SOUNDS_DIR}/wow.wav")
    @@stand, @@walk1, @@walk2, @@jump = *Gosu::Image.load_tiles(
      game, "#{IMAGES_DIR}/player.png", 50, 50, false
    )
     # Physicsy stuff
    @body = CP::Body.new(1.0, CP::INFINITY)  # mass, moi
    @body.pos = @start
    @body.object = self
    game.space.add_body(@body)

     # TODO: Make a polygon shape that mimics the player image
    shape = CP::Shape::Circle.new(@body, 25.0, CP::Vec2.new(0, 0))
    shape.u = 0.0  # friction
    shape.e = 0.0  # elasticity
    shape.collision_type = :player
    shape.object = self
    game.space.add_shape(shape)

    game.space.add_collision_handler(:player, :solid, Solid_Collisions.new)

  end

  class Solid_Collisions
    def begin (player_s, solid_s, contact)
       # The player can stand on something if the contact direction
       # is at most around 45° from flat
      if contact.normal(0).y > 0.7  # A little less than sqrt(2)/2
        player_s.object.ground = solid_s.object
      end
      return true  # Go through with the collision in any case
    end
    def separate (player_s, solid_s, contact)
      if player_s.object.ground = solid_s.object
        player_s.object.ground = nil
      end
    end
  end

  def act (game)
     # Basic motion control
    if game.button_down?(Gosu::KbLeft) && !game.button_down?(Gosu::KbRight)
      if @ground
        @body.apply_force(Vec2.new(-AIR_ACCEL, 0), Vec2.new(0, 0))
      else
        @body.apply_force(Vec2.new(-GROUND_ACCEL, 0), Vec2.new(0, 0))
      end
    elsif game.button_down?(Gosu::KbRight)
      if @ground
        @body.apply_force(Vec2.new(AIR_ACCEL, 0), Vec2.new(0, 0))
      else
        @body.apply_force(Vec2.new(GROUND_ACCEL, 0), Vec2.new(0, 0))
      end
    end
    if game.button_down?(Gosu::KbUp)
      if @ground
        @body.apply_impulse(Vec2.new(0, -JUMP_IMPULSE), Vec2.new(0, 0))
        @ground = nil
      end
    end
  end

  def react (game)
    game.camera.attend(@body.pos)
  end

  def draw (game)
    x_scale = @direction == :left ? 1.0 : -1.0
    frame = @ground ? @@stand : @@jump
    frame.draw_rot(*game.camera.to_screen(@body.pos).to_a, ZOrder::PLAYER, @body.a, 0.5, 0.5, x_scale)
    game.main_font.draw(@body.pos.x, 4, 4, ZOrder::HUD)
    game.main_font.draw(@body.pos.y, 4, 32, ZOrder::HUD)
  end

end
