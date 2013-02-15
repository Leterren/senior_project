require 'gosu'
require 'chipmunk'

require './objects/player'
require './objects/walls'
require './objects/platform'
require './objects/background'

require './lib/constants'
require './lib/utility'
require './lib/utility'
require './lib/camera'
require './lib/level'
require './lib/mouse'
include Utility

class GameWindow < Gosu::Window
  attr_accessor :space, :platforms, :backgrounds, :GameState, :victory
  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT, false
    
    self.caption = "Libra Dev Build"
    @titleFont = Gosu::Font.new(self, "Helvetica", 30)
    yDrawPos = 2 * (self.height / 8)
    yIncrement = self.height / 8
    xDrawPos = 120
    @menuItems = []
    @menuTitles = ["Start Game (Enter)", "Exit (Escape)"]
    @menuTitles.each do |title|
      @menuItems << [title, xDrawPos, yDrawPos]
      yDrawPos += yIncrement
    end

    @GameState = :menu
    @displaytimer = 0
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    # initialize background objects array
    @backgrounds = Array.new

    # Time increment over which to apply a physics step
    @dt = (1.0/60.0)

    # Chipmunk space setup
    @space = CP::Space.new
    @space.gravity = Vec2.new(0.0, 19.6) # twice "normal" gravity

    # camera init
    @camera = Camera.new(0,0)

    # create walls
    Walls.new(self, WORLD_WIDTH, WORLD_HEIGHT)

    # create player
    @player = Player.new(self, 0, 0)

    # setup mouse cursor
    @mouse = Mouse.new(self)


    # create platforms array
    @platforms = Array.new

    # load level (platforms and background objects TODO : update as new things added
    @level = Level.new
    @level.load(self, "levels/#{LEVEL}.yml")

    @which_level = true
  end

  def update
    # (for each main update, we actually step the physics engine several (CP_SUBSTEPS) times)

    # ... control stuff that doesn't directly affect physics ...
    if @player.victory == true
      @GameState = :menu
    end
    if @GameState == :game
      update_camera
     # turns on and off and implements editing mode
     editing_mode_checks

      CP_SUBSTEPS.times do
       # ... control stuff that affects physics ...
       @player.update(Gosu::milliseconds,(button_down? Gosu::KbLeft), (button_down? Gosu::KbRight), ((button_down? Gosu::KbUp) || (button_down? Gosu::KbSpace)))

        @space.step(@dt)
      end
    end
  end

  def draw
    if @GameState == :menu
      @titleFont.draw("Libra", (self.width/2) - @titleFont.text_width("Libra")/2, self.height/8, 0)
      if @player.victory == true
        @font.draw("Level Complete!", (self.width/2) - @font.text_width("Level Complete!")/2, self.height/8 + 30, 0)
        @menuItems[0][0] = "Restart Game (Enter)"
      end
      @menuItems.each do |i|
        @font.draw(i[0], i[1], i[2], 1)
      end
      #@font.draw("Press Enter for game", 10, 10, ZOrder::HUD, 1.0, 1.0, 0xffffff00)
      #@font.draw("Press Escape for exit", 10, 30, ZOrder::HUD, 1.0, 1.0, 0xffffff00)
    elsif @GameState == :game
      @font.draw(@player.pos.x.to_s, 10, 30, ZOrder::HUD, 1.0, 1.0, 0xffffff00)
      @font.draw(@player.pos.y.to_s, 10, 45, ZOrder::HUD, 1.0, 1.0, 0xffffff00)
      #@background_image.draw(*@camera.world_to_screen(CP::Vec2.new(0,0)).to_a,ZOrder::Background)
      @backgrounds.each {|b| b.draw(@camera) }
      @platforms.each {|p| p.draw(@camera) }
      @player.draw(@camera)
      if @editing_mode
        @font.draw("Editing Mode On", 10, 10, ZOrder::HUD, 1.0, 1.0, 0xffffff00)
        @mouse.draw(mouse_x, mouse_y)
      end
    end
  end

  # Escape closes the game
  def button_down(id)
    if id == Gosu::KbEscape
      if @GameState == :game
        @level.save("levels/#{LEVEL}.yml") if @level_edited
        @GameState = :menu
      elsif @GameState == :menu
        close
      end
    end

    if id == Gosu::KbEnter || id == Gosu::KbReturn
      if @player.victory == true
        @player.victoryset(false)
        @menuItems[0][0] = "Resume Game (Enter)"
      end
      if @GameState == :menu
        @menuItems[0][0] = "Resume Game (Enter)"
        @GameState = :game
      end
    end
  end

  private
  ### helpful functions ###
  
  def update_camera
    @camera.parax = @player.body.p.x
    @camera.paray = @player.body.p.y

    if CAMERA_BEHAVIOR==:stop_at_world_edge
      if (@player.body.p.x - SCREEN_WIDTH / 2 < 0)
        @camera.x = 0
      elsif (@player.body.p.x + SCREEN_WIDTH / 2 > WORLD_WIDTH)
        @camera.x = WORLD_WIDTH - SCREEN_WIDTH
      else
        @camera.x = @player.body.p.x - SCREEN_WIDTH / 2
      end
    else
      @camera.x = @player.body.p.x - SCREEN_WIDTH / 2
    end

    if (@player.body.p.y - SCREEN_HEIGHT / 2 < 0)
      @camera.y = 0
    elsif (@player.body.p.y + SCREEN_HEIGHT / 2 > WORLD_HEIGHT)
      @camera.y = WORLD_HEIGHT - SCREEN_HEIGHT
    else
      @camera.y = @player.body.p.y - SCREEN_HEIGHT / 2
    end
  end

  def editing_mode_checks
    if (button_down? Gosu::KbLeftControl) && (button_down? Gosu::KbE) && !@e_still_pressed
      @editing_mode = !@editing_mode
      @e_still_pressed = true
    elsif !(button_down? Gosu::KbE)
      @e_still_pressed = false
    end
    if @editing_mode
      # destroy platforms with right mouse click
      mouse_in_world = @camera.screen_to_world(CP::Vec2.new(mouse_x, mouse_y))
      doomed_shape = @space.point_query_first(mouse_in_world, CP::ALL_LAYERS, CP::NO_GROUP)
      @doomed_shape_pos = doomed_shape.body.p if doomed_shape
      if doomed_shape && !(doomed_shape.body.object.is_a? Player) && (button_down? Gosu::MsRight) && !@still_clicking_right
        @space.remove_body(doomed_shape.body)
        @space.remove_shape(doomed_shape)
        @platforms.delete(doomed_shape.body.object)
        @level.hash[:Objects][:Platforms].delete_if do |p| 
          p[0]==doomed_shape.body.p.x && p[1]==doomed_shape.body.p.y
        end
        @level_edited = true
        @still_clicking_right = true
      elsif !(button_down? Gosu::MsRight)
        @still_clicking_right = false
      end

      # create platforms with left mouse click
      if (button_down? Gosu::MsLeft) && !@still_clicking_left
        platform_spec = [mouse_in_world.x, mouse_in_world.y, "#{LEVEL}blocks.png"]
        @platforms << Platform.new(self, *platform_spec)
        #@level.hash[:Objects][:Platforms] << platform_spec
        @level.add_platform(@platforms.last)
        @level_edited = true
        @still_clicking_left = true
      elsif !(button_down? Gosu::MsLeft)
        @still_clicking_left = false
      end
    end
  end
end
