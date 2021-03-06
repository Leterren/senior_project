require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

# This represents a single platform.  Its physical size takes on the dimensions of its image.

class Buff
  attr_accessor :game, :image_filename, :pickedup, :initialize
  include GameObject

  def to_a
    [@body.pos.x, @body.pos.y, @image_filename]
  end
  def initialize (game, x, y, image_filename = 'HPup.png')
    @game = game
    @image_filename = image_filename
    space = @game.space
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
    @shape.collision_type = :buff
    @shape.object = self
    @shape.sensor = true
    space.add_shape @shape
    game.space.add_collision_handler(:player, :buff, Buff_Collisions.new)

    @pickedup = false
    @loaded = true
  end

  class Buff_Collisions
    def begin (player_s, buff_s, contact)
      if buff_s.object.image_filename == 'HPup.png' && player_s.object.currentHP < player_s.object.MAX_HP
        player_s.object.modifyHP(10)
        buff_s.object.pickedup = true
      end
      if buff_s.object.image_filename == '1up.png'
        player_s.object.LIVES += 1
        player_s.object.message = "+1 Life!"
        player_s.object.message_timer = 60
        player_s.object.message_color = 0xFFFFFF00
        buff_s.object.pickedup = true
      end
      if buff_s.object.image_filename == 'STRup.png'
        player_s.object.strength += 1
        player_s.object.message = "+1 STR"
        player_s.object.message_timer = 45
        player_s.object.message_color = 0xFFFF4400
        buff_s.object.pickedup = true
      end
      if buff_s.object.image_filename == 'DEFup.png'
        player_s.object.defense += 3
        player_s.object.message = "+3 DEF"
        player_s.object.message_timer = 45
        player_s.object.message_color = 0xFFFF4400
        buff_s.object.pickedup = true
      end
      if buff_s.object.image_filename == 'AGIup.png'
        player_s.object.agility += 1
        player_s.object.physics_constants_update
        player_s.object.message = "+1 AGI"
        player_s.object.message_timer = 45
        player_s.object.message_color = 0xFFFF4400
        buff_s.object.pickedup = true
      end
      return nil  # Go through with this collision
    end
  end

  def react ()
    if @pickedup
      self.unload()
    end
  end

  def unload ()
    game.space.remove_shape @shape
  end
  def reset()
    if @image_filename == 'HPup.png'
      @pickedup = false
      game.space.add_shape @shape
    end
  end

  def draw ()
    if !@pickedup
      @image.draw(*game.camera.to_screen(@body.pos).to_a, ZOrder::OBJECTS)
    end
  end

  def click_area
    Rect.new(@body.pos.x, @body.pos.y, @body.pos.x + @image.width, @body.pos.y + @image.height)
  end

end

