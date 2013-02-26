
class Editor

  attr_accessor :selected_index, :enabled

  def initialize
    @enabled = false
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

  def enable (game)
    @enabled = true
    game.camera.free = true
  end
  def disable (game)
    game.camera.free = false
    @enabled = false
  end
  def toggle (game)
    if @enabled
      disable(game)
    else
      enable(game)
    end
  end

  SCROLL_THRESHOLD = 100
  SCROLL_DIVISOR = SCROLL_THRESHOLD / 10

  def update (game)
    if game.mouse_x > 0 && game.mouse_x < SCROLL_THRESHOLD
      game.camera.pos.x -= (SCROLL_THRESHOLD - game.mouse_x) / SCROLL_DIVISOR
    elsif game.mouse_x > game.width - SCROLL_THRESHOLD && game.mouse_x < game.width
      game.camera.pos.x += (game.mouse_x - game.width + SCROLL_THRESHOLD) / SCROLL_DIVISOR
    end
    if game.mouse_y > 0 && game.mouse_y < SCROLL_THRESHOLD
      game.camera.pos.y -= (SCROLL_THRESHOLD - game.mouse_y) / SCROLL_DIVISOR
    elsif game.mouse_y > game.height - SCROLL_THRESHOLD && game.mouse_y < game.height
      game.camera.pos.y += (game.mouse_y - game.height + SCROLL_THRESHOLD) / SCROLL_DIVISOR
    end
    world_mouse = game.camera.from_screen(Vec2.new(game.mouse_x, game.mouse_y))
    if game.button_down? Gosu::MsLeft
      @selected_index = -1
      game.objects.each_index do |i|
        ca = game.objects[i].click_area
        if ca
           # Don't allow clicking on an object if its boundary
           #  is not visible from the camera's current position
          unless (ca + Rect.new(-12, -12, 12, 12)).contains game.camera.area
            if ca.contains world_mouse
              @selected_index = i
              return
            end
          end
        end
      end
    end
  end

  def draw (game)
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
      game.width - 8 - game.main_font.text_width(classname),
      8,
      ZOrder::HUD
    )
  end

end

