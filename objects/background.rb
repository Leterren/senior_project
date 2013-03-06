require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Background
  attr_accessor :game

  include GameObject

  def to_a
    [@pos.x, @pos.y, @image_filename, @scroll_factor]
  end

  def initialize (game, x, y, image_filename = 'dark-bg.png', scroll_factor = 0.5)
    @game = game
    @image_filename = image_filename
    @image = Gosu::Image.new(game, "#{BACKGROUNDS_DIR}/#{image_filename}", true)
    @pos = Vec2.new(x, y)
    @scroll_factor = scroll_factor
  end

  def draw ()
    @image.draw(*game.camera.to_screen(@pos, @scroll_factor).to_a, ZOrder::BACKGROUND)
  end
end
