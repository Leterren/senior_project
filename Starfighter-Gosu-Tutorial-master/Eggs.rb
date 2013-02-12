#Egg Dropping Game
#besmith.lab19.rb
#Made on this Thursday the Eighteenth of November, Year of Our Lord Two-Thousand Ten
########
#Notes from the Part One grading:
#The background image is 1024x713, so the window size should now match
#Apparently I don't have enough constants, but looking through my code, what other constants do I need?
## All the recurring numbers herein are based off of those four. There are a couple other numbers,
## but they are only ever used once and so does that really merit a universal constant?
########

#Sets up Gems
require 'rubygems'
require 'gosu'

#Some constants
WIDTH = 1024
HEIGHT = 713
FALLSPEED = 16
MOVESPEED = 32

#Makes the "eggs" and the properties thereof
class Egg
  attr_reader :caught, :missed

  def initialize(window) #Defines the basic properties of the egg as it is called
    @x = rand(WIDTH)
    @y = 0
    @image = Gosu::Image.new(window, "egg.png", false)
    @beep = Gosu::Sample.new(window, "meow.wav")
    @caught = 0
    @missed = 0
  end

  def draw #Draws the egg
    @image.draw_rot(@x, @y, 1, 0)
  end

  def fall(player) #Causes the egg to fall and be caught by the basket
    @y += FALLSPEED
    if @y >= HEIGHT-35
      if Gosu::distance(@x, 0, player.x, 0) <= 85 then
        @caught += 1
        @beep.play
        true
      elsif Gosu::distance(@x, 0, player.x, 0) > 85 then
        @missed += 1
        true
      end
      @y = 0
      @x = rand(WIDTH)
    end
  end
end


#Makes the player and the properties thereof
class Player
  attr_reader :x, :y

  def initialize(window) #Defines the basic properties of the basket as it is called
    @x = WIDTH/2
    @y = HEIGHT-30
    @image = Gosu::Image.new(window, "basket.png", false)
  end

  def draw #Draws the basket
    @image.draw_rot(@x, @y, 1, 0)
  end

  def move_left #Defines the leftward movement for the button command (Line 98)
    @x -= MOVESPEED if @x > 73
  end

  def move_right #Defines the rightward movement for the button command (Line 101)
    @x += MOVESPEED if @x < WIDTH-73    
  end

end

#Defines the game field and calls the other object-classes for interaction
class GameWindow < Gosu::Window
  def initialize #Defines the basic properties of the window for it to actually exist
    super(WIDTH, HEIGHT, false)
    self.caption = "Bowling for Burgers"
    @background_image = Gosu::Image.new(self, "background.png", false)
    @egg = Egg.new(self)
    @player = Player.new(self)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    #@background_music = Gosu::Sample.new(self, "stupid.mp3")
  end

  def draw #Defines how the window can be called
    @background_image.draw(0, 0, 0)
    @player.draw
    @egg.draw
    @font.draw("Meals: #{@egg.caught}", 10, HEIGHT-22, 0)
    @font.draw("Unsatisfied Customers: #{@egg.missed}", 110, HEIGHT-22, 0)
    @font.draw("Press Escape to Exit", WIDTH-190, 5, 0)
  end

  def update #Refreshes certain methods
    @egg.fall(@player)
    if button_down? Gosu::KbLeft then
      @player.move_left
    end
    if button_down? Gosu::KbRight then
      @player.move_right
    end
  end


  def button_down(id) #Allows button commands for programming miscellanea
    if id == Gosu::KbEscape
      close
    end
    #if id == Gosu::KbM
    #  @background_music.play
    #end
  end
end

#Actually draws the game field
window = GameWindow.new
window.show