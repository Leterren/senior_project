require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

# This represents a single platform.  Its physical size takes on the dimensions of its image.

class Platform
  include GameObject

  def to_a
    [@body.pos.x, @body.pos.y, @image_filename]
  end
  def initialize (game, x, y, image_filename = 'dirtblocks.png')
    @image_filename = image_filename
    space = game.space
    @image = Gosu::Image.new(game, "#{IMAGES_DIR}/#{image_filename}", false)
     # physicsy stuff
    w = @image.width
    h = @image.height
    @body = CP::Body.new_static
    @body.pos = Vec2.new(x, y)
    @body.object = self

    poly = [Vec2.new(0, 0), Vec2.new(0, h), Vec2.new(w, h), Vec2.new(w, 0)]
    @shape = CP::Shape::Poly.new(@body, poly, Vec2.new(0, 0))
     # Player can stand on this
    @shape.collision_type = :solid
    @shape.object = self
    space.add_shape @shape
  end

  def unload (game)
    game.space.remove_shape @shape
  end

  def draw (game)
    @image.draw(*game.camera.to_screen(@body.pos).to_a, ZOrder::BACK)
  end

  def click_area
    Rect.new(@body.pos.x, @body.pos.y, @body.pos.x + @image.width, @body.pos.y + @image.height)
  end

end

