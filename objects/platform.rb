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
  def initialize (game, x, y, image_filename)
    @image_filename = image_filename
    space = game.space
    @tileset = Gosu::Image.load_tiles(game, "#{IMAGES_DIR}/#{image_filename}", 60, 60, true)
     # physicsy stuff
    w = @tileset[0].width
    h = @tileset[0].height
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
    @tileset[0].draw(*game.camera.to_screen(@body.pos).to_a, ZOrder::BACK)
  end

  def click_area
    Rect.new(@body.pos.x, @body.pos.y, @body.pos.x + @tileset[0].width, @body.pos.y + @tileset[0].height)
  end

end

