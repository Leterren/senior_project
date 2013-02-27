require 'gosu'
require './lib/objects.rb'

class Player

  include GameObject

  JUMP_IMPULSE = 10.0
  GROUND_ACCEL = 0.3
  GROUND_TOP_SPEED = 5.0
  AIR_ACCEL = 0.3
  AIR_TOP_SPEED = 4.0
  STOP_DECEL = 0.5
  SKID_DECEL = 0.6
  FALL_TOP_SPEED = 12.0

   # Determines the friction for non-ground collisions.
  MISC_FRICTION = 0.4

  attr_accessor :ground, :ground_friction, :reset_point, :recent_checkpoint, :message, :message_timer
  
  def to_a
    [@start.x, @start.y, @direction, @death]
  end
  def initialize (game, x, y, dir = :right, death = 1.0/0.0)
     # Initialize
    @start = Vec2.new(x, y)
    @direction = dir
    @ground = nil
    @walk_speed = 0.0
    @ground_friction = 2.0
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

    @death = death
    @recent_checkpoint = 0
    @reset_point = @start

    poly = [Vec2.new(-17, -20), Vec2.new(-17, 14), Vec2.new(-13, 19), Vec2.new(13, 19), Vec2.new(17, 14), Vec2.new(17, -20), Vec2.new(13, -25), Vec2.new(-13, -25)]
    @shape = CP::Shape::Poly.new(@body, poly, Vec2.new(0, 0))

    @shape.u = MISC_FRICTION  # friction
    @shape.e = 0.0  # elasticity
    @shape.collision_type = :player
    @shape.object = self

    @message = "Hello World"
    @message_timer = 0

    game.space.add_shape(@shape)

    game.space.add_collision_handler(:player, :solid, Solid_Collisions.new)

  end

  class Solid_Collisions
    def pre_solve (player_s, solid_s, contact)
       # The player can stand on something if the contact direction
       # is at most around 45° from flat
      if contact.normal(0).y > 0.7  # A little less than sqrt(2)/2
        player_s.object.ground = solid_s.object
        contact.u = 0.0
      end
      return true  # Go through with this collision
    end
    def separate (player_s, solid_s, contact)
      if player_s.object.ground == solid_s.object
        player_s.object.ground = nil
      end
    end
  end

  def act (game)
     # Basic motion control
    if game.button_down?(Gosu::KbLeft) && !game.button_down?(Gosu::KbRight)
      if @ground
        @direction = :left
        if @body.vel.x > -GROUND_TOP_SPEED
          @body.apply_impulse(Vec2.new((@body.vel.x > 0 ? -SKID_DECEL : -GROUND_ACCEL), 0), Vec2.new(0, 0))
          if @body.vel.x < -GROUND_TOP_SPEED
            @body.vel = Vec2.new(-GROUND_TOP_SPEED, @body.vel.y);
          end
        end
      else
        if @body.vel.x > -AIR_TOP_SPEED
          @body.apply_impulse(Vec2.new(-AIR_ACCEL, 0), Vec2.new(0, 0))
          if @body.vel.x < -AIR_TOP_SPEED
            @body.vel = Vec2.new(-AIR_TOP_SPEED, @body.vel.y)
          end
        end
      end
    elsif game.button_down?(Gosu::KbRight)
      if @ground
        @direction = :right
        if @body.vel.x < GROUND_TOP_SPEED
          @body.apply_impulse(Vec2.new((@body.vel.x > 0 ? SKID_DECEL : GROUND_ACCEL), 0), Vec2.new(0, 0))
          if @body.vel.x > GROUND_TOP_SPEED
            @body.vel.x = GROUND_TOP_SPEED
          end
        end
      else
        if @body.vel.x < AIR_TOP_SPEED
          @body.apply_impulse(Vec2.new(AIR_ACCEL, 0), Vec2.new(0, 0))
          if @body.vel.x > AIR_TOP_SPEED
            @body.vel.x = AIR_TOP_SPEED
          end
        end
      end
    else
      if @ground
        if @body.vel.x > 0
          @body.apply_impulse(Vec2.new(-STOP_DECEL, 0), Vec2.new(0, 0))
          if @body.vel.x < 0
            @body.vel.x = 0
          end
        elsif @body.vel.x < 0
          @body.apply_impulse(Vec2.new(STOP_DECEL, 0), Vec2.new(0, 0))
          if @body.vel.x > 0
            @body.vel.x = 0
          end
        end
      else
        if @body.vel.y > FALL_TOP_SPEED
          @body.vel.y = FALL_TOP_SPEED
        end
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
    if @body.pos.y >= @death
      @@wow.play
      @body.pos = @reset_point
      @body.vel = Vec2.new(0, 0)
    end
  end
  
  def draw (game)
    screen_pos = game.camera.to_screen(@body.pos)
    x_scale = @direction == :left ? 1.0 : -1.0
    frame = @ground ? @@stand : @@jump
    frame.draw_rot(screen_pos.x, screen_pos.y, ZOrder::PLAYER, @body.a, 0.5, 0.5, x_scale)
    game.main_font.draw(@body.pos.x, 8, Game::SCREEN_HEIGHT - 68, ZOrder::HUD)
    game.main_font.draw(@body.pos.y, 8, Game::SCREEN_HEIGHT - 48, ZOrder::HUD)
    if @message_timer > 0
      game.main_font.draw_rel(@message, screen_pos.x, screen_pos.y - 30, ZOrder::HUD, 0.5, 1, 1, 1, 0xffffff00)
      @message_timer -= 1 
    end
  end

  def click_area
    Rect.new(@start.x - 17, @start.y - 25, @start.x + 17, @start.y + 25)
  end

end
