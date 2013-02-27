require 'gosu'
require 'chipmunk'
require 'yaml'

require './lib/utility'
include Utility

require './lib/camera.rb'
require './lib/z_order.rb'
require './lib/editor.rb'

class Game < Gosu::Window

   # Game-specific
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600

   # I think if space is measured in pixels, time should be in frames.
  FRAME = 1.0
   # This shouldn't be necessary, but oh well.
   # Changing this value should not affect timing on the large scale.
  PHYSICS_SUBSTEPS = 6

  GRAVITY = 0.4

  INITIAL_LEVEL = 'dark'

  attr_accessor :window, :space, :objects, :state, :camera, :main_font, :editor

  def needs_cursor?
    true
  end

  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT, false
    self.caption = "Libra Dev Build"

    @title_font = Gosu::Font.new(self, "Helvetica", 30)
    @main_font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @state = :main_menu
    @editor = Editor.new

    @objects = []
    @space = CP::Space.new
    @space.gravity = Vec2.new(0.0, GRAVITY)

    @camera = Camera.new(SCREEN_WIDTH, SCREEN_HEIGHT)

  end

  def update
    @camera.reset
    if @state == :level
      @objects.each { |o| o.act(self) }
      PHYSICS_SUBSTEPS.times { @space.step FRAME / PHYSICS_SUBSTEPS }
      @objects.each { |o| o.react(self) }
      if @editor.enabled
        @editor.update self
      end
    end
  end

  def button_down (id)

    if self.text_input
      if id == Gosu::KbEscape
        editor.cancel_input self
        self.text_input = nil
      elsif id == Gosu::KbReturn
        editor.commit_input self
        self.text_input = nil
      end
    else

      if @state == :main_menu ##############
        if id == Gosu::KbEnter || id == Gosu::KbReturn
          load_level(INITIAL_LEVEL)
          @state = :level
        end
        if id == Gosu::KbEscape
          close
        end
      elsif @state == :level ##############
        if id == Gosu::KbE
          editor.toggle(self)
        end
        if id == Gosu::KbEscape
          @state = :pause_menu
        end
        if @editor.enabled
          @editor.button_down self, id
        end
      elsif @state == :pause_menu ##############
        if id == Gosu::KbEscape
          close
        end
        if id == Gosu::KbEnter || id == Gosu::KbReturn
          @state = :level
        end 
      end

    end
  end

  def draw
    @main_font.draw(@state.to_s, 8, self.height - 28, ZOrder::HUD)
    if @state == :level
      self.caption = "Get to the Warp Point!"
      if @editor.enabled
        @objects.each_index { |i| @objects[i].debug_draw(self, i == @editor.selected_index) }
        @editor.draw self
      else
        @objects.each { |o| o.draw(self) }
      end
    elsif @state == :main_menu
      @title_font.draw_rel("Libra", self.width/2, self.height/8, ZOrder::HUD, 0.5, 1)
      @main_font.draw("Start Game (Enter)", self.width/8, self.height/4, 0)
      @main_font.draw("Exit Game (Escape)", self.width/8, self.height/3, 0)
    elsif @state == :pause_menu
      @title_font.draw_rel("Paused", self.width/2, self.height/8, ZOrder::HUD, 0.5, 1)
      @main_font.draw("Resume Game (Enter)", self.width/8, self.height/4, 0)
      @main_font.draw("Exit Game (Escape)", self.width/8, self.height/3, 0)
    end
  end

  def unload_level
    @objects.each { |o| o.unload }
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

end

