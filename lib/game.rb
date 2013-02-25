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

  attr_accessor :window, :space, :objects, :state, :camera, :main_font, :editing, :editor

  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT, false
    self.caption = "Libra Dev Build"

    @title_font = Gosu::Font.new(self, "Helvetica", 30)
    @main_font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @state = :main_menu
    @editing = false
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
    end
  end

  def button_down (id)

    if self.text_input
      if id == Gosu::KbEscape
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
          @editing = !@editing
        end
        if id == Gosu::KbEscape
          @state = :pause_menu
        end
        if @editing
          @editor.button_down id
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
    @main_font.draw(@state.to_s, 2, self.height - 20, ZOrder::HUD)
    if @state == :level
      if @editing
        @objects.each_index { |i| @objects[i].debug_draw(self, i == @editor.selected_index) }
        @editor.draw self
      else
        @objects.each { |o| o.draw(self) }
      end
    elsif @state == :main_menu
      @title_font.draw("Libra", self.width/2 - @title_font.text_width("Libra")/2, self.height/8, ZOrder::HUD)
      @main_font.draw("Start Game (Enter)", self.width/8, self.height/4, 0)
      @main_font.draw("Exit Game (Escape)", self.width/8, self.height/3, 0)
    elsif @state == :pause_menu
      @title_font.draw("Paused", self.width/2 - @title_font.text_width("Paused")/2, self.height/8, ZOrder::HUD)
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
    File.open("levels/#{name}.yml") do |f|
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

end

