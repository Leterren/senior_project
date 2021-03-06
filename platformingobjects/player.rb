require 'gosu'
require './lib/objects.rb'

class Player

  include GameObject

  attr_accessor :ground, :ground_friction, :reset_point, :recent_checkpoint, :message, :message_timer, :message_color
  attr_accessor :previctory, :fall_timer, :currentHP, :body, :MAX_HP, :walk_start, :game, :modifyHP, :LIVES, :savedHP
  attr_accessor :strength, :agility, :defense, :physics_constants_update, :invuln_timer
  
  def to_a
    [@start.x, @start.y, @direction, @death]
  end
  def initialize (game, x, y, dir = :right, death = 1.0/0.0)
      
      @game = game
      @game.player = self

      # Initialize
      @start = Vec2.new(x, y)
      @direction = dir
      @ground = nil
      @walk_speed = 0.0
      @ground_friction = 2.0
      @walk_start = x

       # Load resources
      #@@wow = Gosu::Sample.new(game, "#{SOUNDS_DIR}/wow.wav")
      @@stand, @@walk1, @@walk2, @@jump = *Gosu::Image.load_tiles(
        game, "#{IMAGES_DIR}/player.png", 50, 50, false
      )

       # RPG elements
      @LIVES = 4
      @MAX_HP = 100
      @currentHP = @MAX_HP
      @savedHP = @currentHP
      @strength = 3
      @agility = 3
      @defense = 2

       # physics engine stuff
      physics_constants_update
      @body = CP::Body.new(1.0, CP::INFINITY)  # mass, moi
      @body.pos = @start
      @body.object = self
      game.space.add_body(@body)
      poly = [Vec2.new(-17, -20), Vec2.new(-17, 14), Vec2.new(-13, 19), Vec2.new(13, 19), Vec2.new(17, 14), Vec2.new(17, -20), Vec2.new(13, -25), Vec2.new(-13, -25)]
      @shape = CP::Shape::Poly.new(@body, poly, Vec2.new(0, 0))
      @shape.u = @misc_friction  # friction
      @shape.e = 0.0  # elasticity
      @shape.collision_type = :player
      @shape.object = self
      game.space.add_shape(@shape)
      game.space.add_collision_handler(:player, :solid, Solid_Collisions.new)

       # world checks
      @fall_timer = 0
      @invuln_timer = 0
      @death = death
      @recent_checkpoint = 0
      @reset_point = @start

       # body message
      @message = "Hello World"
      @message_timer = 0
      @message_color = 0xFF00FF00
      @previctory = false

  end

  def physics_constants_update
     # physics constants
    @jump_impulse = 8.5 + @agility.to_f/2
    @ground_accel = @agility.to_f/10
    @ground_top_speed = 4.4 + @agility.to_f/5
    @air_accel = @agility.to_f/10
    @air_top_speed = 3.4 + @agility.to_f/5
    @stop_decel = 0.2 + @agility.to_f/10
    @skid_decel = 0.3 + @agility.to_f/10
    @fall_top_speed = 12.0
    @misc_friction = 0.4 # Determines the friction for non-ground collisions.
  end

  class Solid_Collisions
    def pre_solve (player_s, solid_s, contact)
       # The player can stand on something if the contact direction
       # is at most around 45° from flat
      if contact.normal(0).y > 0.7  # A little less than sqrt(2)/2
        if (!player_s.object.ground)
          player_s.object.walk_start = player_s.body.pos.x
        end
        player_s.object.ground = solid_s.object
        contact.u = 0.0
      end
       # fall damage handler
      if player_s.object.ground
        falldamagethreshold = 37 + (2*player_s.object.agility)
        if (player_s.object.fall_timer > falldamagethreshold)
          player_s.object.modifyHP(-((player_s.object.fall_timer - falldamagethreshold) / 2))
        end
        player_s.object.fall_timer = 0
      end
      return true  # Go through with this collision
    end
    def separate (player_s, solid_s, contact)
      if player_s.object.ground == solid_s.object
        player_s.object.ground = nil
      end
    end
  end

  def act ()
     # Basic motion control
    if game.button_down?(Gosu::KbEnter) || game.button_down?(Gosu::KbReturn)
      if @previctory == true
        self.victory
      end
    end 
    if game.button_down?(Gosu::KbLeft) && !game.button_down?(Gosu::KbRight) && @previctory == false
      if @ground
        @direction = :left
        if @body.vel.x > -@ground_top_speed
          @body.apply_impulse(Vec2.new((@body.vel.x > 0 ? -@skid_decel : -@ground_accel), 0), Vec2.new(0, 0))
          if @body.vel.x < -@ground_top_speed
            @body.vel = Vec2.new(-@ground_top_speed, @body.vel.y);
          end
        end
      else
        if @body.vel.x > -@air_top_speed
          @body.apply_impulse(Vec2.new(-@air_accel, 0), Vec2.new(0, 0))
          if @body.vel.x < -@air_top_speed
            @body.vel = Vec2.new(-@air_top_speed, @body.vel.y)
          end
        end
      end
    elsif game.button_down?(Gosu::KbRight) && @previctory == false
      if @ground
        @direction = :right
        if @body.vel.x < @ground_top_speed
          @body.apply_impulse(Vec2.new((@body.vel.x < 0 ? @skid_decel : @ground_accel), 0), Vec2.new(0, 0))
          if @body.vel.x > @ground_top_speed
            @body.vel.x = @ground_top_speed
          end
        end
      else
        if @body.vel.x < @air_top_speed
          @body.apply_impulse(Vec2.new(@air_accel, 0), Vec2.new(0, 0))
          if @body.vel.x > @air_top_speed
            @body.vel.x = @air_top_speed
          end
        end
      end
    else
      if @ground
        if @body.vel.x > 0
          @body.apply_impulse(Vec2.new(-@stop_decel, 0), Vec2.new(0, 0))
          if @body.vel.x < 0
            @body.vel.x = 0
          end
        elsif @body.vel.x < 0
          @body.apply_impulse(Vec2.new(@stop_decel, 0), Vec2.new(0, 0))
          if @body.vel.x > 0
            @body.vel.x = 0
          end
        end
      else
        if @body.vel.y > @fall_top_speed
          @body.vel.y = @fall_top_speed
        end
      end
    end
    if (game.button_down?(Gosu::KbUp) || game.button_down?(Gosu::KbSpace)) && previctory == false
      if @ground
        @body.apply_impulse(Vec2.new(0, -@jump_impulse), Vec2.new(0, 0))
        @ground = nil
      end
    end
  end

  def react ()
    game.camera.attend(@body.pos)
    if (@body.pos.y >= @death) || (@currentHP <= 0)
      self.die
    end
    if (@currentHP > @MAX_HP)
      @currentHP = @MAX_HP
    end
    if @body.vel.x.abs < 0.1
      @walk_start = @body.pos.x
    end
    if !@ground && @body.vel.y > 0
      @fall_timer += 1
    end
    if @invuln_timer > 0
      @invuln_timer -= 1
    end
  end
  
  def draw ()
    screen_pos = game.camera.to_screen(@body.pos)
    x_scale = @direction == :left ? 1.0 : -1.0
    frame = @@jump
    if @ground
      if @body.vel.x.abs < 0.1
        frame = @@stand
      else
        if (@body.pos.x - walk_start).abs % 50 < 25
          frame = @@walk1
        else
          frame = @@walk2
        end
      end
    else
      frame = @@jump
    end
    if (invuln_timer%10 < 5) && (invuln_timer%10 >= 0)
      frame.draw_rot(screen_pos.x, screen_pos.y, ZOrder::PLAYER, @body.a, 0.5, 0.5, x_scale)
    end
    #game.main_font.draw(@body.pos.x, 8, Game::SCREEN_HEIGHT - 68, ZOrder::HUD)
    #game.main_font.draw(@body.pos.y, 8, Game::SCREEN_HEIGHT - 48, ZOrder::HUD)
    game.main_font.draw_rel("HP: #{@currentHP}", Game::SCREEN_WIDTH - 5, 5, ZOrder::HUD, 1, 0, 1, 1, 0xFFFF1111)
    #game.main_font.draw("#{@invuln_timer}", 8, Game::SCREEN_HEIGHT - 108, ZOrder::HUD, 1, 1, 0xFFFF0000)
    game.main_font.draw_rel("Lives: #{@LIVES}", Game::SCREEN_WIDTH - 5, 25, ZOrder::HUD, 1, 0, 1, 1, 0xFFFFFF66)
    if @message_timer > 0
      game.main_font.draw_rel(@message, screen_pos.x, screen_pos.y - 30, ZOrder::HUD, 0.5, 1, 1, 1, @message_color)
      @message_timer -= 1 
    end
    if @previctory == true
      game.main_font.draw_rel("You win! Press [Enter] to continue.", game.width/2, Game::SCREEN_HEIGHT - 20, ZOrder::HUD, 0.5, 1, 1, 1, 0xFF00FF00)
    end
  end

  def victory
    game.victorystate = :win
    game.state = :main_menu
    game.unload_level
  end
  def defeat
    game.victorystate = :lose
    game.state = :main_menu
    game.unload_level
  end
  def modifyHP(amount)
    if amount <= -1
      if @invuln_timer == 0
        actualdamage = (amount + defense/2).to_i
        if actualdamage > 0
          actualdamage = 0
        end
        @currentHP += actualdamage
        #@@wow.play
        if actualdamage < 0
          @message = "#{actualdamage} HP"
        elsif actualdamage == 0
          @message = "No damage"
        end
        @message_color = 0xFFFF1111
        @message_timer = 40
        @invuln_timer = 26 + (@defense * 2)
      end
    end
    if amount >= 1
      @currentHP += amount
      @message = "+#{amount} HP"
      @message_color = 0xFF00FFFF
      @message_timer = 40
    end
  end
  def die
    #@@wow.play
    @body.pos = @reset_point
    @body.vel = Vec2.new(0, 0)
    @currentHP = @savedHP
    @fall_timer = 0
    @LIVES -= 1
    @message_timer = 45
    @message_color = 0xFFFF0000
    @message = "-1 Life!"
    @game.objects.each { |o| o.reset() }
    if @LIVES == 0
      self.defeat
    end
  end

  def click_area
    Rect.new(@start.x - 17, @start.y - 25, @start.x + 17, @start.y + 25)
  end

  def unload ()
    game.space.remove_shape @shape
  end
  def reset()
  end

end
