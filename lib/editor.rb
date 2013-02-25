
class Editor

  attr_accessor :selected_index

  def initialize
    @class_index = 0
    @selected_index = -1
  end

  def button_down (id)
    if id == Gosu::Kb0
      @class_index += 1
      if @class_index >= GameObject::editable_classes.length
        @class_index = 0
      end
    elsif id == Gosu::Kb9
      @class_index -= 1
      if @class_index < 0
        @class_index = GameObject::editable_classes.length
      end
    end
  end

  def draw (game)
    @selected_index = 0
    if @selected_index >= 0
      game.main_font.draw game.objects[@selected_index].class.name, 8, 8, ZOrder::HUD
      repr = game.objects[@selected_index].to_a
      repr.each_index do |i|
        game.main_font.draw repr[i].to_s, 8, 28 + 20*i, ZOrder::HUD
      end
    end
    classname = GameObject::editable_classes[@class_index].name
    game.main_font.draw(
      classname,
      Game::SCREEN_WIDTH - 8 - game.main_font.text_width(classname),
      8,
      ZOrder::HUD
    )
  end

end

