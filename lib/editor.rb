require 'yaml'

class Editor

  attr_accessor :selected_index, :selected_repr, :enabled

  def initialize
    @enabled = false
    @class_index = 0
    @selected_index = -1
    @selected_repr = nil
    @prop_index = -1
  end

  def button_down (game, id)
    if id == Gosu::KbD
      @class_index += 1
      if @class_index >= GameObject::editable_classes.length
        @class_index = 0
      end
    elsif id == Gosu::KbA
      @class_index -= 1
      if @class_index < 0
        @class_index = GameObject::editable_classes.length - 1
      end
    elsif @selected_repr and id == Gosu::KbW
      @prop_index -= 1
      if @prop_index < 0 or @prop_index >= @selected_repr.length
        @prop_index = @selected_repr.length - 1
      end
    elsif @selected_repr and id == Gosu::KbS
      @prop_index += 1
      if @prop_index >= @selected_repr.length + 1
        @prop_index = 0
      end
    elsif @prop_index >= 0 and @prop_index < @selected_repr.length and id == Gosu::KbReturn
      game.text_input = Gosu::TextInput.new
      game.text_input.text = @selected_repr[@prop_index]
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
    currect = nil
    if game.button_down? Gosu::MsLeft
      @selected_index = -1
      game.objects.each_index do |i|
        ca = game.objects[i].click_area
        if ca
           # Don't allow clicking on an object if its boundary
           #  is not visible from the camera's current position
          unless (ca + Rect.new(-12, -12, 12, 12)).contains game.camera.area
            if ca.contains world_mouse
              if !currect or ca.t > currect.t
                currect = ca
                @selected_index = i
              end
            end
          end
        end
      end
       # Save the representation so we can edit parts of it
      if @selected_index >= 0
        @selected_repr = game.objects[@selected_index].to_a.map do |o|
          yaml = YAML::dump(o)
          if yaml.match(/\A--- (.*)\n\.\.\.\n\Z/)
            $1
          else
            puts "couldn't print:\n#{yaml}"
            '(unprintable)'
          end
        end
      end
    end
  end

  def cancel_input
  end
  def commit_input
  end

  def draw (game)
    if @selected_index >= 0
      game.main_font.draw game.objects[@selected_index].class.name, 8, 8, ZOrder::HUD
      @selected_repr.each_index do |i|
        if game.text_input and @prop_index == i
          pre = game.text_input.text[0..game.text_input.caret_pos]
          game.main_font.draw(game.text_input.text, 8, 28 + 20*i, ZOrder::HUD)
          game.main_font.draw('_', 8 + game.main_font.text_width(pre), 30 + 20*i, ZOrder::HUD)
        else
          color = @prop_index == i ? Gosu::Color::YELLOW : Gosu::Color::WHITE
          game.main_font.draw @selected_repr[i].to_s, 8, 28 + 20*i, ZOrder::HUD, 1, 1, color
        end
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

