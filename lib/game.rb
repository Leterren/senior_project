require 'gosu'
require 'chipmunk'
require 'yaml'

require './lib/utility'
include Utility

require './lib/camera.rb'
require './lib/z_order.rb'

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

  attr_accessor :window, :space, :objects, :state, :camera, :main_font

  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT, false
    self.caption = "Libra Dev Build"

    @title_font = Gosu::Font.new(self, "Helvetica", 30)
    @main_font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @state = :main_menu

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
    if id == Gosu::KbEscape
      close
    end
    if @state == :main_menu
      if id == Gosu::KbEnter || id == Gosu::KbReturn
        load_level(INITIAL_LEVEL)
        @state = :level
      end
    end
  end

  def draw
    if @state == :level
      @objects.each { |o| o.draw(self) }
    elsif @state == :main_menu
      @title_font.draw("Libra", self.width/2 - @title_font.text_width("Libra")/2, self.height/8, 0)
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

