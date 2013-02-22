require './lib/utility'
include Utility

module GameObject
  def unload (game)
  end
  def act (game)
  end
  def react (game)
  end
  def draw (game)
  end
  def debug_draw (game)
    draw(game)
    ca = click_area
    if ca
      calt = game.camera.to_screen ca.lt
      carb = game.camera.to_screen ca.rb
      game.draw_line(calt.x, calt.y, Gosu::Color::WHITE, carb.x, calt.y, Gosu::Color::WHITE, ZOrder::HUD)
      game.draw_line(carb.x, calt.y, Gosu::Color::WHITE, carb.x, carb.y, Gosu::Color::WHITE, ZOrder::HUD)
      game.draw_line(carb.x, carb.y, Gosu::Color::WHITE, calt.x, carb.y, Gosu::Color::WHITE, ZOrder::HUD)
      game.draw_line(calt.x, carb.y, Gosu::Color::WHITE, calt.x, calt.y, Gosu::Color::WHITE, ZOrder::HUD)
    end
  end
  def click_area
    nil
  end
  def to_a
    []
  end
end


