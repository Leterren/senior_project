require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class TacticalBackground
  attr_accessor :game

  include GameObject

  def to_a
    [@image_filename]
  end

  def initialize (game, image_filename = "gridbackground.png")
    @game = game
    @image_filename = image_filename
    @image = Gosu::Image.new(game, "#{BACKGROUNDS_DIR}/#{image_filename}", true)
  end

  def draw ()
    @image.draw(0, 0, ZOrder::BACKGROUND)
  end
  def reset()
  end 
end
