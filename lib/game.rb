require 'gosu'
require 'chipmunk'
require 'yaml'

require './lib/utility'
include Utility

require './lib/camera.rb'
require './lib/z_order.rb'
require './lib/editor.rb'

class Game < Gosu::Window

  attr_accessor :game
   # Game-specific
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600

   # I think if space is measured in pixels, time should be in frames.
  FRAME = 1.0
   # This shouldn't be necessary, but oh well.
   # Changing this value should not affect timing on the large scale.
  PHYSICS_SUBSTEPS = 6

  GRAVITY = 0.4

  #INITIAL_LEVEL = 'light'
  LEVEL_HASH = {
    0 => 'dark',
    1 => 'light'
  }
  NUM_LEVELS = 2

  attr_accessor :window, :space, :objects, :state, :camera, :main_font, :editor, :victorystate, :player
  attr_accessor :load_combat, :combatgrid, :currentenemy, :printgrid, :tobjects

  def needs_cursor?
    true
  end

  def initialize
    $game = self
    super SCREEN_WIDTH, SCREEN_HEIGHT, false
    self.caption = "Libra Dev Build"

    @title_font = Gosu::Font.new(self, "Helvetica", 40)
    @main_font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @state = :main_menu
    @editor = Editor.new(self)

    @levelcounter = 0
    @objects = []

    @currentenemy
    @space = CP::Space.new
    @space.gravity = Vec2.new(0.0, GRAVITY)

    # making a 6x6 grid populated by things
    @combatgrid = []
    # initialize the grid, you can populate the grid from this point
    #   by checking the current coords against the current x,y or
    #   simply assign the values to their proper locations afterward
    #   I recommend the latter
    6.times do |x|
      row = []
      6.times do |y|
        # you now have the x,y of your location in the grid
        row << nil
      end
      @combatgrid << row
    end
    @tBackground = TacticalBackground.new(self)
    @tobjects = []

    @camera = Camera.new(SCREEN_WIDTH, SCREEN_HEIGHT)
    @exitareyousure = false
    @victorystate = :neutral
  end

  def update
    @camera.reset
    if @state == :level
      @objects.each { |o| o.act() }
      PHYSICS_SUBSTEPS.times { @space.step FRAME / PHYSICS_SUBSTEPS }
      @objects.each { |o| o.react() }
      if @editor.enabled
        @editor.update
      end
    end
    if @state == :combat
      while @tobjects[@current_turn].take_turn
        @current_turn += 1
        if @current_turn >= @tobjects.length
          @current_turn = 0
        end
      end
      pflag = false
      eflag = false
      @tobjects.each do |o|
        if o.class == Tenemy
          eflag = true
        end
        if o.class == Tplayer
          pflag = true
        end
      end
      if pflag == false
        self.lose_combat
      elsif eflag == false
        self.win_combat
      end
    end
  end

  def button_down (id)
    if self.text_input
      if id == Gosu::KbEscape
        editor.cancel_input
        self.text_input = nil
      elsif id == Gosu::KbReturn
        editor.commit_input
        self.text_input = nil
      end
    else

      if @state == :main_menu ##############
        if id == Gosu::KbEnter || id == Gosu::KbReturn
          if @victorystate == :win
            @levelcounter += 1
          end
          if (@levelcounter > NUM_LEVELS - 1) || @victorystate == :lose
            @levelcounter = 0
          end
          load_level(LEVEL_HASH[@levelcounter])
          @state = :level
        end
        if id == Gosu::KbEscape
          close
        end
      elsif @state == :level ##############
        if id == Gosu::KbE
          editor.toggle()
        end
        if id == Gosu::KbEscape
          @state = :pause_menu
        end
        if @editor.enabled
          @editor.button_down id
        end
      elsif @state == :pause_menu ##############
        if id == Gosu::KbEscape
          if @exitareyousure == false
            @exitareyousure = true
          else
            @state = :main_menu
            @levelcounter = 0
            @victorystate = :neutral
            @exitareyousure = false
          end
        end
        if id == Gosu::KbEnter || id == Gosu::KbReturn
          if @exitareyousure == false
            @state = :level
          else
            @exitareyousure = false
          end
        end 
      elsif @state == :combat ####################################
        @tobjects[@current_turn].button_down(id)
        if id == Gosu::KbV
          self.win_combat
        end
        if id == Gosu::KbEscape
          self.lose_combat
        end
      end

    end
  end

  def draw
    #@main_font.draw(@state.to_s, 8, self.height - 28, ZOrder::HUD)
    if @state == :level
      self.caption = "Get to the Warp Gate!"
      if @editor.enabled
        @objects.each_index { |i| @objects[i].debug_draw(i == @editor.selected_index) }
        @editor.draw
      else
        @objects.each { |o| o.draw() }
      end
    elsif @state == :main_menu
      if victorystate == :neutral
        draw_quad(0, self.height/2, 0xFF000000, self.width, self.height/2, 0xFF000000, self.width, self.height, 0xFF777777, 0, self.height, 0xFF777777)
        @title_font.draw_rel("Libra", self.width/2, self.height/7, ZOrder::HUD, 0.5, 1, 1, 1, 0xff999999)
        @main_font.draw("Start Game [Enter]", self.width/8, self.height/4, ZOrder::HUD, 1, 1, 0xff888888)
        @main_font.draw("Exit Game [Escape]", self.width/8, self.height/3, ZOrder::HUD, 1, 1, 0xff888888)
      elsif victorystate == :win
        draw_quad(0, self.height/2, 0xFF000000, self.width, self.height/2, 0xFF000000, self.width, self.height, 0xFF777777, 0, self.height, 0xFF777777)
        @title_font.draw_rel("Victory!", self.width/2, self.height/7, ZOrder::HUD, 0.5, 1, 1, 1, 0xff999999)
        if @levelcounter == NUM_LEVELS - 1
          @main_font.draw("Restart Game [Enter]", self.width/8, self.height/4, ZOrder::HUD, 1, 1, 0xff888888)
        else
          @main_font.draw("Next Level [Enter]", self.width/8, self.height/4, ZOrder::HUD, 1, 1, 0xff888888)
        end
        @main_font.draw("Exit Game [Escape]", self.width/8, self.height/3, ZOrder::HUD, 1, 1, 0xff888888)
      elsif victorystate == :lose
        draw_quad(0, self.height/2, 0xFF000000, self.width, self.height/2, 0xFF000000, self.width, self.height, 0xFF777777, 0, self.height, 0xFF777777)
        @title_font.draw_rel("Game Over!", self.width/2, self.height/7, ZOrder::HUD, 0.5, 1, 1, 1, 0xff999999)
        @main_font.draw("Restart Game [Enter]", self.width/8, self.height/4, ZOrder::HUD, 1, 1, 0xff888888)
        @main_font.draw("Exit Game [Escape]", self.width/8, self.height/3, ZOrder::HUD, 1, 1, 0xff888888)
      end
    elsif @state == :pause_menu
      @title_font.draw_rel("Paused", self.width/2, self.height/7, ZOrder::HUD, 0.5, 1, 1, 1, 0xFF888888)
      if @exitareyousure == false
        @main_font.draw("Resume Game [Enter]", self.width/8, self.height/4, 0.5, 1, 1, 0xFF666666)
        @main_font.draw("Return to Main Menu [Escape]", self.width/8, self.height/4 + 50, 0.5, 1, 1, 0xFF777777)
        draw_quad(self.width/8 - 10, self.height/4 + 90, 0xFF111111, 
                  7*self.width/8 + 10, self.height/4 + 90, 0xFF111111, 
                  7*self.width/8 + 10, self.height/4 + 250, 0xFF111111, 
                  self.width/8 - 10, self.height/4 + 250, 0xFF111111, 
                  ZOrder::BACKGROUND, mode = :default)
        @main_font.draw("STATS:", self.width/8, self.height/4 + 100, 0.5, 1, 1, 0xFF777777)
        @main_font.draw("Lives: #{@player.LIVES}", self.width/8 + 20, self.height/4 + 120, 0.5, 1, 1, 0xFF777777)
        @main_font.draw("Maximum HP: #{@player.MAX_HP}", self.width/8 + 20, self.height/4 + 140, 0.5, 1, 1, 0xFF777777)
        @main_font.draw("Current HP: #{@player.currentHP}", self.width/8 + 20, self.height/4 + 160, 0.5, 1, 1, 0xFF777777)
        @main_font.draw("Strength: #{@player.damage}", self.width/8 + 20, self.height/4 + 180, 0.5, 1, 1, 0xFF777777)
        @main_font.draw("Defense: #{@player.armor}", self.width/8 + 20, self.height/4 + 200, 0.5, 1, 1, 0xFF777777)
        @main_font.draw("Agility: #{@player.move_max}", self.width/8 + 20, self.height/4 + 220, 0.5, 1, 1, 0xFF777777)

      end
      if @exitareyousure == true
        @main_font.draw("Are you sure you want to exit to menu? Progress will be lost.", self.width/8, self.height/4, 0, 1, 1, 0xFF666666)
        @main_font.draw("-> Yes [Escape]", self.width/8, self.height/4 + 30, 0, 1, 1, 0xFF666666)
        @main_font.draw("-> No [Enter]", self.width/8, self.height/4 + 60, 0, 1, 1, 0xFF666666)
      end
    elsif @state == :combat
      self.caption = "Defeat the Enemies!"
      @tBackground.draw
      @title_font.draw_rel("Combat!", 700, 20, ZOrder::HUD, 0.5, 0, 1, 1, 0xFFAAAAAA)
      @main_font.draw("Next Turn [Enter]", 620, self.height - 30, ZOrder::HUD, 1, 1, 0xFFAAAAAA)
      @tobjects.each { |to| to.draw }
      # print "wat"
      return nil
    end
  end

  def reset
    @state = :main_menu
    unload_level
  end

  def unload_level
    @objects.each { |o| o.unload() }
    @objects = []
    @current_level = nil
  end

  def load_level (name)
    if @current_level
      unload_level
    end
    puts "Loading level: #{name}"
    data = nil
    File.open "levels/#{name}.yml" do |f|
      data = YAML::load(f.read)
    end
    @current_level = name
    data[:objects].each do |kv|
      kv.each do |key, val|
         # Find class by name
        cl = Object
        key.split('::').each do |name|
          cl = cl.const_get(name)
        end
         # Create it.
        @objects << cl.new(self, *val)
      end
    end
  end

  def save_level
    puts "Saving level: #{@current_level}"
    data = {
      objects: @objects.map do |o|
        { o.class.name => o.to_a }
      end
    }
    File.open "levels/#{@current_level}.yml", 'w' do |f|
      f.print YAML::dump(data)
    end
  end

  def load_combat
    puts "Loading combat"
    @state = :combat
    x = rand(6)
    y = rand(6)
    tp = Tplayer.new(self, @player, x, y)
    combatgrid[y][x] = tp
    @tobjects << tp
    @current_turn = 0
    3.times do |i|
      x = rand(6)
      y = rand(6)
      while combatgrid[y][x] != nil
        x = rand(6)
        y = rand(6)
      end
      te = Tenemy.new(self, tp, x, y)
      combatgrid[y][x] = te
      @tobjects << te
    end
    #printgrid
  end
  def win_combat
    @state = :level
    @player.message_timer = 60
    @player.message_color = 0xFF0066FF
    @player.message = "You win!"
    @player.currentHP -= 0
    @currentenemy.combatresolved = true
    self.unload_combat
  end
  def lose_combat
    @state = :level
    @player.die
    self.unload_combat
  end
  def unload_combat
    for i in 0..5
      for j in 0..5
        @combatgrid[i][j] = nil
      end
    end
    @tobjects = []
  end
  def spot_clear? (x, y)
    return 0 <= y && y < @combatgrid.length && 0 <= x && x < @combatgrid[y].length && @combatgrid[y][x] == nil
  end
  def spot_occupied? (x, y)
    return 0 <= y && y < @combatgrid.length && 0 <= x && x < @combatgrid[y].length && @combatgrid[y][x] != nil
  end
  # print the grid nicely so we can see it
  def printgrid
    print "*\n"
    @combatgrid.each do |row|
      print "{"
      row.each do |cell|
        print "[#{cell}]"
      end
      print "}\n"
    end
    print "*\n"
  end
end
