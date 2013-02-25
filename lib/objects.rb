require './lib/utility'
include Utility

module GameObject

  @@editable_classes = []
  def self.editable_classes
    @@editable_classes
  end
  def self.included (cl)
    @@editable_classes << cl
  end

  def unload (game)
  end
  def act (game)
  end
  def react (game)
  end
  def draw (game)
  end
  def debug_draw (game, is_selected)
    draw(game)
    ca = click_area
    if ca
      calt = game.camera.to_screen ca.lt
      carb = game.camera.to_screen ca.rb
      color = is_selected ? Gosu::Color::GREEN : Gosu::Color::WHITE
      game.draw_line(calt.x, calt.y, color, carb.x, calt.y, color, ZOrder::HUD)
      game.draw_line(carb.x, calt.y, color, carb.x, carb.y, color, ZOrder::HUD)
      game.draw_line(carb.x, carb.y, color, calt.x, carb.y, color, ZOrder::HUD)
      game.draw_line(calt.x, carb.y, color, calt.x, calt.y, color, ZOrder::HUD)
    end
  end
  def click_area
    nil
  end
  def to_a
    []
  end
end


